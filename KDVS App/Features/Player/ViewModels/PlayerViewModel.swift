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
        isLoading = true

        defer {
            isLoading = false
        }

        do {
            guard let show = try await showService.getCurrentShow() else {
                self.show = nil
                return
            }

            self.show = show

            await updateNowPlaying(for: show)
            scheduleRefresh(for: show)

        } catch {
            print("Failed to load current show:", error)
        }
    }
    
    func updateNowPlaying(for show: Show) async {
        var nowPlaying: [String: Any] = [
            MPMediaItemPropertyTitle: show.name,
            MPMediaItemPropertyArtist: show.djName,
            MPNowPlayingInfoPropertyIsLiveStream: true,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]

        if let url = show.playlistImageURL,
           let image = await loadArtwork(from: url) {

            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in
                return image
            }

            nowPlaying[MPMediaItemPropertyArtwork] = artwork
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlaying
    }
    
    private func loadArtwork(from url: URL?) async -> UIImage? {
        guard let url else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Artwork load failed:", error)
            return nil
        }
    }

    private func scheduleRefresh(for show: Show) {
        showRefreshTask?.cancel()

        guard let endDate = show.endTime.nextOccurrenceDate() else {
            return
        }

        let seconds = endDate.timeIntervalSinceNow

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
