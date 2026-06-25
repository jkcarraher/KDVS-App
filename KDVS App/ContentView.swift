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
    @EnvironmentObject private var notificationService: NotificationService
    let audioService = AudioPlayerService()
    let socketService = SocketService()
    let showService: ShowService
    
    init(showService: ShowService) {
        self.showService = showService
    }
    
    let streamURL = Stream.kdvsArchive
    @State var audioPlayer = AVPlayer()
    @State private var isRemindPresented = false
    @State private var isSettingsPresented = false
    @State private var isLoading = false
    @State private var isPlaying = false
    @State private var audioSessionInterruptionObserver: NSObjectProtocol?
    @State private var timer: Timer?
    
    var body: some View {
        NavigationStack {
            VStack {
                myHeader(openCredit: $isSettingsPresented)
                Spacer()
                PlayerView(audioService: audioService, socketService: socketService, showService: showService)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(Color("BackgroundColor"))
            .sheet(isPresented: $isSettingsPresented) {
                SettingsSheetView()
                    .environmentObject(notificationService)
                    .environment(\.colorScheme, .dark)
                    .presentationDetents([.height(500), .large])
                    .background(Color("RemindBackground"))
            }
        }
        }
    }

struct myHeader: View {
    @EnvironmentObject private var showService: ShowService
    @Binding var openCredit: Bool

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
                ScheduleGridView(showService: showService)
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
            UserDefaults.standard.set(launchCount + 1, forKey: "LaunchCount")
        }
    }
}
