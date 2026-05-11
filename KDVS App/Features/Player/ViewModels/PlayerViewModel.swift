//
//  PlayerViewModel.swift
//  KDVS
//
//  Created by John Carraher on 5/10/26.
//

import Foundation

@MainActor
final class PlayerViewModel: ObservableObject {
    @Published var showReminderSheet = false
    @Published var isLoading = false
    @Published var show: Show
    
    var isPlaying: Bool {
        playerService.isPlaying
    }
    
    private let playerService: AudioPlayerService
    private let socketService: SocketService
    
    init(
        playerService: AudioPlayerService,
        socketService: SocketService
    ){
        // Link Services
        self.playerService = playerService
        self.socketService = socketService
        
        // Load livestream to shared PLAYER_SERVICE
        let streamURL = URL(string: "https://archives.kdvs.org/stream")!
        playerService.load(url: streamURL)
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
