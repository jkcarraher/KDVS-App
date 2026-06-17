//
//  NowPlayingViewModel.swift
//  KDVS
//
//  Created by John Carraher on 5/18/26.
//

import Foundation
import Combine
import UIKit

@MainActor
final class NowPlayingViewModel: ObservableObject {
    @Published var analyzedSong: ShazamSong?
    @Published var isLoading = false
    @Published var artworkImage: UIImage?

    private let recorder = AudioStreamRecorderService()
    private let shazamService = ShazamService()
    
    func loadArtwork(url: URL?) async {
        guard let url else {
            artworkImage = nil
            return
        }

        artworkImage = await ImageCacheService.shared.loadImage(from: url)
    }

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
