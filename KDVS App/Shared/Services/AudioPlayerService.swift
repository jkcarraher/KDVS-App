//
//  AudioService.swift
//  KDVS
//
//  Created by John Carraher on 5/10/26.
//

import AVFoundation

final class AudioPlayerService {
    @Published private(set) var isPlaying = false
    
    private let player = AVPlayer()
    
    func load(url: URL) {
        player.replaceCurrentItem(
            with: AVPlayerItem(url: url)
        )
    }
    
    func play() {
        player.play()
        isPlaying = true
    }
    func pause() {
        player.pause()
        isPlaying = false
    }
}
