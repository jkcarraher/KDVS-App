//
//  PlayerViewModel.swift
//  KDVS
//
//  Created by John Carraher on 5/10/26.
//

import Foundation

@MainActor
final class PlayerViewModel: ObservableObject {
    @Published private(set) var isPlaying = false
    @Published var showReminderSheet = false
    @Published var isLoading = false
    @Published var show: Show = Show(
        id: "0",
        name: " ",
        djName: " ",
        playlistImageURL: URL(string: "https://library.kdvs.org/static/core/images/kdvs-image-placeholder.jpg")!,
        startTime: "1:1:1".toTimeOfDay()!,
        endTime: "1:1:1".toTimeOfDay()!,
        alternates: false,
        DOTW: "Funday",
        dates: [],
        firstShowDate: Date(),
        lastShowDate: Date()
    )
    
    private let playerService: AudioPlayerService
    private let socketService: SocketService
    private let showService: ShowService
    
    init(
        playerService: AudioPlayerService,
        socketService: SocketService,
        showService: ShowService
    ){
        // Link Services
        self.playerService = playerService
        self.socketService = socketService
        self.showService = showService
        
        // Load livestream to shared PLAYER_SERVICE
        let streamURL = Stream.kdvsArchive
        playerService.load(url: streamURL)
        
        // Link isPlaying state to playerService
        playerService.$isPlaying
            .assign(to: &$isPlaying)
    }
    
    func loadCurrentShow() async {
        isLoading = true
        
        do {
            show = try await showService.getCurrentShow()
        } catch {
            print("Failed to load current show - ", error)
        }
        
        isLoading = false
    }
    
    func togglePlayback() {
        if isPlaying {
            playerService.pause()
            socketService.disconnect()
        } else {
            playerService.play()
            socketService.connect()

        }
    }
    
    func openReminderSheet() {
        showReminderSheet = true
    }
    
    func closeReminderSheet() {
        showReminderSheet = false
    }
}
