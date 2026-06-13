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
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
    }
    
    func play() {
        guard let url = url else { return }
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        
        player.play()
        isPlaying = true
        updateNowPlaying()
    }
    
    func stop() {
        player.pause()
        player.replaceCurrentItem(with: nil)
        isPlaying = false
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
    
    private func updateNowPlaying() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: "KDVS 90.3 FM",
            MPMediaItemPropertyArtist: "Live Radio",
            MPNowPlayingInfoPropertyIsLiveStream: true,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]
    }
    
    private func observePlayer() {
        statusObserver = player.observe(\.timeControlStatus, options: [.new]) { [weak self] player, _ in
            DispatchQueue.main.async {
                guard let self else { return }

                switch player.timeControlStatus {
                case .playing:
                    self.isPlaying = true
                    self.updateNowPlaying()

                case .paused, .waitingToPlayAtSpecifiedRate:
                    self.isPlaying = false
                    self.updateNowPlaying()

                @unknown default:
                    self.isPlaying = false
                }
            }
        }
    }
}
