//
//  ShazamService.swift
//  KDVS
//
//  Created by John Carraher on 5/18/26.
//

import Foundation
import ShazamKit
import AVFAudio

final class ShazamService: NSObject {
    
    private let session = SHSession()
    
    // Turns livestream url into an AVBuffer OBJ which we can identify a song with
    func scanStream(audioURL: URL) async throws -> ShazamSong? {
        let recordedFile = try AVAudioFile(forReading: audioURL)
        let sourceFormat = recordedFile.processingFormat
        
        // Create the output format as 16-bit PCM with a sample rate matching the source format
        guard let outputFormat = AVAudioFormat(
            commonFormat: .pcmFormatInt16,
            sampleRate: sourceFormat.sampleRate,
            channels: sourceFormat.channelCount,
            interleaved: false
        ) else {
            throw ShazamServiceError.invalidOutputFormat
        }
        
        // Create an AVAudioConverter
        guard let converter = AVAudioConverter(
            from: sourceFormat,
            to: outputFormat
        ) else {
            throw ShazamServiceError.converterCreationFailed
        }

        // Determine the number of frames for conversion
        let sourceFrameCount = AVAudioFrameCount(recordedFile.length)

        // Allocate buffer for reading the source file
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: sourceFormat,
            frameCapacity: sourceFrameCount)
        else {
            throw ShazamServiceError.bufferCreationFailed
        }

        // Read the audio file into the buffer
        try recordedFile.read(into: buffer)

        // Allocate buffer for the converted output
        guard let outputBuffer = AVAudioPCMBuffer(
            pcmFormat: outputFormat,
            frameCapacity: sourceFrameCount
        ) else {
            throw ShazamServiceError.outputBufferCreationFailed
        }

        var conversionError: NSError?

        let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
            outStatus.pointee = .haveData
            return buffer
        }

        let status = converter.convert(
            to: outputBuffer,
            error: &conversionError,
            withInputFrom: inputBlock
        )

        if let conversionError {
            throw conversionError
        }

        guard status != .error else {
            throw ShazamServiceError.audioConversionFailed
        }

        return try await identifySong(with: outputBuffer)
    }
    
    func identifySong(
            with buffer: AVAudioPCMBuffer
    ) async throws -> ShazamSong? {

        let generator = SHSignatureGenerator()

        try generator.append(buffer, at: nil)

        let signature = generator.signature()

        let result = await session.result(from: signature)

        switch result {

        case .match(let match):

            guard let item = match.mediaItems.first else {
                return nil
            }

            return ShazamSong(
                title: item.title ?? "Unknown",
                artist: item.artist ?? "Unknown",
                artworkURL: item.artworkURL
            )

        case .noMatch:
            return nil

        case .error(let error, _):
            throw error
        }
    }
}


enum ShazamServiceError: Error {
    case invalidOutputFormat
    case converterCreationFailed
    case bufferCreationFailed
    case outputBufferCreationFailed
    case audioConversionFailed
}

struct ShazamSong {
    let title: String
    let artist: String
    let artworkURL: URL?
}
