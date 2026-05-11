//
//  PlayerViewModel.swift
//  KDVS
//
//  Created by John Carraher on 5/10/26.
//

import Foundation

@MainActor
final class PlayerViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var isLoading = false
    @Published var show: Show
    
    private let playerService: AudioPlayerService
    private let socketService: SocketService
    
    init(){
        // Load livestream to shared PLAYER_SERVICE
        let streamURL = URL(string: "https://archives.kdvs.org/stream")!
        playerService.load(url: streamURL)
    }
    
    func play() {
        playerService.play()
        socketService.connect()
    }
    
    func pause() {
        playerService.pause()
        socketService.disconnect()
    }
    
}
