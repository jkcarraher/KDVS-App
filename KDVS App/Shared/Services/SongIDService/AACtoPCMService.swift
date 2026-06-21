//
//  AudioConvertService.swift
//  KDVS
//
//  Created by John Carraher on 6/20/26.
//

import Foundation
import AVFAudio

final class AACtoPCMService {
    
    func convertAACtoPCM(aacFileURL: URL) throws -> AVAudioPCMBuffer {
        
        let inputFile = try AVAudioFile(forReading: aacFileURL)
        
        let inputFormat = inputFile.processingFormat
        
        let outputFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: inputFormat.sampleRate,
            channels: inputFormat.channelCount,
            interleaved: false
        )!
        
        let converter = AVAudioConverter(
            from: inputFormat,
            to: outputFormat
        )!
        
        let frameCapacity = AVAudioFrameCount(inputFile.length)
        
        guard let outputBuffer = AVAudioPCMBuffer(
            pcmFormat: outputFormat,
            frameCapacity: frameCapacity
        ) else {
            throw AACtoPCMServiceError.bufferCreationFailed
        }
        
        var error: NSError?
        
        let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
            if inputFile.framePosition >= inputFile.length {
                outStatus.pointee = .endOfStream
                return nil
            }
            
            let buffer = AVAudioPCMBuffer(
                pcmFormat: inputFormat,
                frameCapacity: 1024
            )
            
            try? inputFile.read(into: buffer!)
            
            outStatus.pointee = .haveData
            return buffer
        }
        
        converter.convert(
            to: outputBuffer,
            error: &error,
            withInputFrom: inputBlock
        )
        
        if let error {
            throw error
        }
        
        return outputBuffer
    }
}

enum AACtoPCMServiceError: Error {
    case recordingFailed
    case recordingURLMissing
    case bufferCreationFailed
}
