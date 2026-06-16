//
//  PlayerViewModel.swift
//  KDVS
//
//  Created by John Carraher on 5/10/26.
//

import Foundation
import MediaPlayer


@MainActor
final class PlayerViewModel: ObservableObject {
    @Published private(set) var isPlaying = false
    @Published var showReminderSheet = false
    @Published var isLoading = false
    @Published var show: Show?
    @Published var showImage: UIImage?
    

    private let playerService: AudioPlayerService
    private let socketService: SocketService
    private let showService: ShowService

    private var showRefreshTask: Task<Void, Never>?
    private var safetyRefreshTask: Task<Void, Never>?

    init(
        playerService: AudioPlayerService,
        socketService: SocketService,
        showService: ShowService
    ) {
        self.playerService = playerService
        self.socketService = socketService
        self.showService = showService

        let streamURL = Stream.kdvsArchive
        playerService.load(url: streamURL)

        playerService.$isPlaying
            .assign(to: &$isPlaying)
    }

    deinit {
        showRefreshTask?.cancel()
        safetyRefreshTask?.cancel()
    }

    func start() async {
        await loadCurrentShow()
        startSafetyRefresh()
    }

    func loadCurrentShow() async {
        do {
            guard let newShow = try await showService.getCurrentShow() else {
                if show != nil {
                    isLoading = true
                }

                self.show = nil
                self.showImage = nil

                isLoading = false
                return
            }

            if let current = show, current.id == newShow.id {
                return
            }

            isLoading = true

            self.show = newShow

            if let url = newShow.playlistImageURL {
                self.showImage = await ImageCacheService.shared.loadImage(from: url)
            } else {
                self.showImage = nil
            }

            await updateMediaCenter(for: newShow)
            scheduleRefresh(for: newShow)

            isLoading = false

        } catch {
            print("Failed to load current show:", error)
            isLoading = false
        }
    }
    
    func updateMediaCenter(for show: Show) async {
        var nowPlaying: [String: Any] = [
            MPMediaItemPropertyTitle: show.name,
            MPMediaItemPropertyArtist: show.djName,
            MPNowPlayingInfoPropertyIsLiveStream: true,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]

        if let image = showImage {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in
                image
            }

            nowPlaying[MPMediaItemPropertyArtwork] = artwork
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlaying
    }
    
    private func scheduleRefresh(for show: Show) {
        showRefreshTask?.cancel()

        guard let endDate = show.endTime.nextOccurrenceDate() else {
            return
        }

        // add 1 minute buffer after show ends
        let refreshDate = endDate.addingTimeInterval(60)

        let seconds = refreshDate.timeIntervalSinceNow
        guard seconds > 0 else {
            Task { await loadCurrentShow() }
            return
        }

        showRefreshTask = Task { [weak self] in
            do {
                try await Task.sleep(
                    nanoseconds: UInt64(seconds * 1_000_000_000)
                )

                await self?.loadCurrentShow()
            } catch {
                // cancelled
            }
        }
    }

    private func startSafetyRefresh() {
        safetyRefreshTask?.cancel()

        safetyRefreshTask = Task { [weak self] in
            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(15 * 60))
                    await self?.loadCurrentShow()
                } catch {
                    break
                }
            }
        }
    }

    func appDidBecomeActive() async {
        await loadCurrentShow()
    }
    
    func togglePlayback() {
        if isPlaying {
            playerService.stop()
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
