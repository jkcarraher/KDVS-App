//
//  AudioStreamRecorderService.swift
//  KDVS
//
//  Created by John Carraher on 5/18/26.
//

import Foundation
import AVFoundation

final class AudioStreamRecorderService {

    private let streamURL =
        URL(string: "https://archives.kdvs.org/stream")!

    private var cachingPlayerItem: CachingPlayerItem?

    func recordSnippet(
        duration: TimeInterval = 8
    ) async throws -> URL {

        let item = await CachingPlayerItem(
            url: streamURL,
            recordingName: "recording.aac"
        )

        self.cachingPlayerItem = item

        print("Recording started")

        try await Task.sleep(
            for: .seconds(duration)
        )

        return try await stopRecording()
    }

    private func stopRecording() async throws -> URL {

        guard let item = cachingPlayerItem else {
            throw AudioRecorderError.noActiveRecording
        }

        return try await withCheckedThrowingContinuation {
            continuation in

                Task { @MainActor in

                    item.stopDownloading {

                        guard let url = item.getDownloadedFileURL() else {
                            continuation.resume(
                                throwing: AudioRecorderError.missingRecordingURL
                            )
                            return
                        }

                        self.cachingPlayerItem = nil

                        continuation.resume(returning: url)
                    }
                }
        }
    }
}

enum AudioRecorderError: Error {
    case noActiveRecording
    case missingRecordingURL
}
