//
//  ContentView.swift
//  KDVS App
//
//  Created by John Carraher on 2/17/23.
//

import SwiftUI
import AVKit
import MediaPlayer
import SwiftSoup

struct ContentView: View {
    let streamURL = URL(string: "https://archives.kdvs.org/stream")!
    @State var audioPlayer = AVPlayer()
    @State private var isRemindPresented = false
    @State private var isSettingsPresented = false
    @State private var isLoading = false
    @State private var isPlaying = false
    @State private var audioSessionInterruptionObserver: NSObjectProtocol?
    @State private var timer: Timer?
    @State private var show = Show(
        name: " ",
        djName: " ",
        playlistImageURL: URL(string: "https://library.kdvs.org/static/core/images/kdvs-image-placeholder.jpg"),
        alternatingType: 0,
        startTime: Date(),
        endTime: Date(),
        showDates: [],
        seasonStartDate: Date(),
        seasonEndDate: Date()
    )
    
    @State private var currentSeasonShows: [Show] = []
    
    var body: some View {
        NavigationView {
            VStack {
                myHeader(openCredit: $isSettingsPresented, currentScheduleList: $currentSeasonShows)
                Spacer()
                PlayerView(openRemind: $isRemindPresented, show: $show, audioPlayer: $audioPlayer, isLoading: $isLoading, isPlaying: $isPlaying)
                Spacer()            
            }
            .frame(maxWidth: .infinity)
            .background(Color("BackgroundColor"))
            .sheet(isPresented: $isRemindPresented) {
                SheetView(show: $show)
                    .environment(\.colorScheme, .dark)
                    .presentationDetents([.height(450), .large])
                    .background(Color("RemindBackground")) // Set the color of the sheet
                
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView()
                    .environment(\.colorScheme, .dark)
                    .presentationDetents([.height(500), .large])
                    .background(Color("RemindBackground"))
            }
        }.onAppear{
            //wipeAllShows()
            //wipeAllScheduledNotifications()
            isLoading = true
            scrapeHomeData(completion: { scrapedShow in
                scrapeScheduleData { shows in
                    self.currentSeasonShows = shows
                    findShowWithName(shows, showName: scrapedShow.name) { scheduleShow in
                        self.show = scheduleShow!
                        setupNowPlaying()
                        startTimer()
                        self.isLoading = false

                    }
                    
                }
                let playerItem = AVPlayerItem(url: streamURL)
                //playerItem.preferredForwardBufferDuration = 5.0
                try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                audioPlayer.replaceCurrentItem(with: playerItem)
                
                audioSessionInterruptionObserver = NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance(), queue: .main) { notification in
                    guard let userInfo = notification.userInfo,
                          let interruptionTypeRawValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                          let interruptionType = AVAudioSession.InterruptionType(rawValue: interruptionTypeRawValue) else {
                        return
                    }
                    switch interruptionType {
                    case .began:
                        // Audio session interrupted. Pause the player.
                        audioPlayer.pause()
                        isPlaying = false
                        disconnectToSocket()
                    case .ended:
                        // Audio session interruption ended. Resume playback if appropriate.
                        guard let optionsRawValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                            return
                        }
                        let options = AVAudioSession.InterruptionOptions(rawValue: optionsRawValue)
                        if options.contains(.shouldResume) {
                            audioPlayer.play()
                            isPlaying = true
                            connectToSocket()
                        }
                    @unknown default:
                        return
                    }
                }
                
                // Start the timer to call ScrapeHomeData() every minute
                self.timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                    scrapeHomeData(completion: { show in
                    self.show = show
                })
                }
                self.timer?.tolerance = 5.0 // Set a tolerance of 5 seconds for better energy efficiency
            })
        }
        .onDisappear() {
            if let observer = audioSessionInterruptionObserver {
                NotificationCenter.default.removeObserver(observer, name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
                audioSessionInterruptionObserver = nil
            }
        }
    }
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
            DispatchQueue.global(qos: .background).async {
                UIApplication.shared.beginBackgroundTask(withName: "PlayerViewTimer") {
                    // Handle any cleanup needed for the background task here
                }
                // Code to run every minute while app is in background
                scrapeHomeData(completion: { show in
                    self.show = show
                    setupNowPlaying()
                })
                UIApplication.shared.endBackgroundTask(UIBackgroundTaskIdentifier.invalid)
            }
        }
    }
    func setupNowPlaying() {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        
        nowPlayingInfoCenter.nowPlayingInfo = [
            MPMediaItemPropertyTitle: show.name,
            MPMediaItemPropertyArtist: show.djName!,
            
            MPMediaItemPropertyMediaType: MPMediaType.anyAudio.rawValue,
            MPNowPlayingInfoPropertyIsLiveStream: true,
            MPNowPlayingInfoPropertyPlaybackRate: 1.0
        ]
        
        if let url = show.playlistImageURL {
                let session = URLSession.shared
                let task = session.dataTask(with: url) { data, response, error in
                    if let error = error {
                        print("Error fetching image: \(error)")
                        return
                    }
                    
                    if let data = data, let image = UIImage(data: data) {
                        // Create a new image that is a square crop of the original image
                        let imageSize = image.size
                        let shorterSide = min(imageSize.width, imageSize.height)
                        let squareRect = CGRect(x: (imageSize.width - shorterSide) / 2, y: (imageSize.height - shorterSide) / 2, width: shorterSide, height: shorterSide)
                        if let croppedImage = image.cgImage?.cropping(to: squareRect) {
                            let squareImage = UIImage(cgImage: croppedImage)
                            
                            var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
                            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 300, height: 300)) { _ in
                                return squareImage
                            }
                            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                        }
                    }
                }
                
                task.resume()
            }
        
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [audioPlayer] _ in
            audioPlayer.play()
            isPlaying = true
            connectToSocket()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [audioPlayer] _ in
            audioPlayer.pause()
            isPlaying = false
            disconnectToSocket()
            return .success
        }
    }
}

struct myHeader: View {
    @Binding var openCredit: Bool
    @Binding var currentScheduleList: [Show]

    let launchCount = UserDefaults.standard.integer(forKey: "LaunchCount")
    var shouldDisplayAlternateImage: Bool {
        return false
        //launchCount % 5 == 0 // Display alternate image every 5 launches
    }
    var body: some View {
        HStack {
            Button(action: {
                openCredit = true
            }, label: {
                Image(shouldDisplayAlternateImage ? "KDVS_Icon_2" : "KDVS_Icon_1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
            })
            Spacer().frame(width: 5)
            Text("KDVS - 90.3 FM")
                .font(shouldDisplayAlternateImage ?
                    .custom("HoeflerText-BlackItalic", size: 20) :
                    .system(size: 20, weight: .bold))
                .foregroundColor(shouldDisplayAlternateImage ? Color("HeaderTextColor_2") : Color.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            NavigationLink(destination: ScheduleView(shows: $currentScheduleList)) {
                Image(systemName: "calendar")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20) // Adjust the size of the icon as needed
                    .foregroundColor(Color(.white)) // Set the color of the icon
            }
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        .background(Color("BackgroundColor"))
        .onAppear {
            printAllExistingNotifications()
            UserDefaults.standard.set(launchCount + 1, forKey: "LaunchCount")
        }
    }
}

struct SheetView: View {
    @Binding var show : Show
    @State var remindLabel = "CURRENT SHOW"

    var body: some View {
        VStack{
            Spacer()
            Text("Now Playing")
                .font(.system(size: 30, weight: .bold))
                .environment(\.colorScheme, .dark)
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.horizontal, .top], 20)
            RemindView(show: $show, label: $remindLabel)
            NowPlayingView()
            Spacer()
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SettingsView: View {
    var body: some View {
        Spacer()
        Text("Settings")
            .font(.system(size: 30, weight: .bold))
            .environment(\.colorScheme, .dark)
            .foregroundColor(Color.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 25)
            .padding(.vertical, 15)
        ReminderManagerView()
        CreditView()
        Spacer()
    }
}
