//
//  NowPlayingViewModel.swift
//  KDVS
//
//  Created by John Carraher on 5/18/26.
//

import Foundation

@MainActor
final class NowPlayingViewModel: ObservableObject {

    @Published var analyzedSong: ShazamSong?
    @Published var isLoading = false

    private let recorder = AudioStreamRecorderService()
    private let shazamService = ShazamService()

    func recognizeCurrentSong() async {
        isLoading = true

        defer {
            isLoading = false
        }

        do {

            let url = try await recorder.recordSnippet()

            analyzedSong = try await shazamService.scanStream(
                audioURL: url
            )

        } catch {
            print("Recognition failed:", error)
            analyzedSong = nil
        }
    }
}
