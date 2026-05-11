//
//  AudioService.swift
//  KDVS
//
//  Created by John Carraher on 5/10/26.
//

import AVFoundation

final class AudioPlayerService {
    private let player = AVPlayer()
    
    func load(url: URL) {
        player.replaceCurrentItem(
            with: AVPlayerItem(url: url)
        )
    }
    
    func play() {
        player.play()
    }
    func pause() {
        player.pause()
    }
}
