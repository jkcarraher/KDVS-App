//
//  AudioService.swift
//  KDVS
//
//  Created by John Carraher on 5/10/26.
//

import AVFoundation
import Combine
import MediaPlayer

final class AudioPlayerService: ObservableObject {
    @Published private(set) var isPlaying = false
    
    private let player = AVPlayer()
    private var url: URL?
    private var statusObserver: NSKeyValueObservation?
    
    init() {
        setupAudioSession()
        setupRemoteCommands()
        observePlayer()
    }
    
    func load(url: URL) {
        self.url = url
        if player.currentItem == nil {
            player.replaceCurrentItem(with: AVPlayerItem(url: url))
        }
    }
    
    func play() {
        player.play()
    }
    
    func stop() {
        player.pause()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()

            try session.setCategory(
                .playback,
                mode: .default,
                options: []
            )

            try session.setActive(true)
        } catch {
            print("Audio session error:", error)
        }
    }
    
    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self, !self.isPlaying else { return .commandFailed }
            self.play()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self, self.isPlaying else { return .commandFailed }
            self.stop()
            return .success
        }
    }
    
    private func observePlayer() {
        statusObserver = player.observe(\.timeControlStatus, options: [.new]) { player, _ in

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }

                switch player.timeControlStatus {
                case .playing:
                    self.isPlaying = true

                case .paused, .waitingToPlayAtSpecifiedRate:
                    self.isPlaying = false

                @unknown default:
                    self.isPlaying = false
                }
            }
        }
    }
}
