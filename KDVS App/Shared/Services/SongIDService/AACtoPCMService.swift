//
//  AudioConvertService.swift
//  KDVS
//
//  Created by John Carraher on 6/20/26.
//

import Foundation
import AVFAudio

final class AACtoPCMService {

    private let streamURL: URL
    private let duration: TimeInterval

    init(
        streamURL: URL,
        duration: TimeInterval = 5
    ) {
        self.streamURL = streamURL
        self.duration = duration
    }

    func captureSample() async throws -> AVAudioPCMBuffer {
        let recorder = AudioStreamRecorder()

        recorder.startRecording {}

        try await Task.sleep(
            for: .seconds(duration)
        )

        return try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<AVAudioPCMBuffer, Error>) in

            recorder.stopRecording { error in

                if let error {
                    continuation.resume(
                        throwing: error
                    )
                    return
                }

                do {

                    guard let fileURL =
                        recorder.getAudioFileURL()
                    else {

                        throw AACtoPCMServiceError
                            .recordingURLMissing
                    }

                    let audioFile = try AVAudioFile(
                        forReading: fileURL
                    )

                    let format =
                        audioFile.processingFormat

                    guard let buffer = AVAudioPCMBuffer(
                        pcmFormat: format,
                        frameCapacity:
                            AVAudioFrameCount(
                                audioFile.length
                            )
                    ) else {
                        throw AACtoPCMServiceError
                            .bufferCreationFailed
                    }

                    try audioFile.read(into: buffer)

                    continuation.resume(
                        returning: buffer
                    )

                } catch {
                    print(error)

                    continuation.resume(
                        throwing: error
                    )
                }
            }
        }
    }
}

enum AACtoPCMServiceError: Error {
    case recordingFailed
    case recordingURLMissing
    case bufferCreationFailed
}
