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
    let audioService = AudioPlayerService()
    let socketService = SocketService()
    let showService = ShowService()
    
    let streamURL = URL(string: "https://archives.kdvs.org/stream")!
    @State var audioPlayer = AVPlayer()
    @State private var isRemindPresented = false
    @State private var isSettingsPresented = false
    @State private var isLoading = false
    @State private var isPlaying = false
    @State private var audioSessionInterruptionObserver: NSObjectProtocol?
    @State private var timer: Timer?
    @State private var show: Show = .empty
    @State private var currentSeasonShows: [Show] = []
    
    var body: some View {
        NavigationView {
            VStack {
                myHeader(openCredit: $isSettingsPresented, currentScheduleList: $currentSeasonShows)
                Spacer()
                PlayerView(audioService: audioService, socketService: socketService)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(Color("BackgroundColor"))
            .sheet(isPresented: $isRemindPresented) {
                SheetView(show: $show)
                    .environment(\.colorScheme, .dark)
                    .presentationDetents([.height(450), .large])
                    .background(Color("RemindBackground"))
                
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView()
                    .environment(\.colorScheme, .dark)
                    .presentationDetents([.height(500), .large])
                    .background(Color("RemindBackground"))
            }
        }.onAppear{
            isLoading = true
            
            self.show = showService.getCurrentShow()
                
                fetchShows { shows in
                    self.currentSeasonShows = shows
                    startTimer()
                    isLoading = false
                }
                
                let playerItem = AVPlayerItem(url: streamURL)
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
                    case .ended:
                        // Audio session interruption ended. Resume playback if appropriate.
                        guard let optionsRawValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                            return
                        }
                        let options = AVAudioSession.InterruptionOptions(rawValue: optionsRawValue)
                        if options.contains(.shouldResume) {
                            audioPlayer.play()
                            isPlaying = true
                        }
                    @unknown default:
                        return
                    }
                }
                
                self.timer?.tolerance = 5.0 // Set a tolerance of 5 seconds for better energy efficiency
            }
        }
    }
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
            DispatchQueue.global(qos: .background).async {
                UIApplication.shared.beginBackgroundTask(withName: "PlayerViewTimer") {
                    // Handle any cleanup needed for the background task here
                }
                UIApplication.shared.endBackgroundTask(UIBackgroundTaskIdentifier.invalid)
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
            NavigationLink {
                ScheduleGridView()
            } label: {
                Image(systemName: "calendar")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
                    .foregroundColor(.white)
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
