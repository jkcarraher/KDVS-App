//
//  AudioStreamRecorder.swift
//  KDVS
//
//  Created by John Carraher on 6/29/23.
//
import Foundation
import AVFoundation

class AudioStreamRecorder {

    private let streamURL: URL

    private var audioFile: AVAudioFile?
    private var recordingURL: URL?
    private var isRecording: Bool = false
    
    private var cachingPlayerItem: CachingPlayerItem?
    private var player: AVPlayer?
    
    init(streamURL: URL) {
        self.streamURL = streamURL
    }

    func recordStream(for duration: TimeInterval) async throws -> URL {

        await startRecording()

        do {
            try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
        } catch {
            let url = try await stopRecording()
            throw error
        }

        return try await stopRecording()
    }
    
    func startRecording() async {
        let streamURL = Stream.kdvsArchive

        cachingPlayerItem = await CachingPlayerItem(
            url: streamURL,
            recordingName: "recording.aac"
        )

        guard let item = cachingPlayerItem else { return }

        player = AVPlayer(playerItem: item)
        player?.play()

        isRecording = true
    }

    func stopRecording() async throws -> URL {

        await MainActor.run {
            player?.pause()
        }

        guard let item = cachingPlayerItem else {
            throw RecorderError.missingPlayerItem
        }

        return try await withCheckedThrowingContinuation { continuation in

            Task { @MainActor in
                item.stopDownloading { [weak self] in
                    guard let self = self else {
                        continuation.resume(throwing: RecorderError.deallocated)
                        return
                    }

                    guard let aacURL = item.getDownloadedFileURL() else {
                        continuation.resume(throwing: RecorderError.missingFileURL)
                        return
                    }

                    let wavURL = aacURL
                        .deletingPathExtension()
                        .appendingPathExtension("wav")

                    self.cachingPlayerItem = nil
                    self.isRecording = false

                    convertAACtoWAV(inputURL: aacURL, outputURL: wavURL) { error in
                        if let error = error {
                            continuation.resume(throwing: error)
                            return
                        }

                        self.recordingURL = wavURL
                        continuation.resume(returning: wavURL)
                    }
                }
            }
        }
    }

    func getAudioFileURL() -> URL? {
        recordingURL
    }
}

enum RecorderError: Error {
    case missingPlayerItem
    case missingFileURL
    case deallocated
}
