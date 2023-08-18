//
//  aactowav.swift
//  KDVS
//
//  Created by John Carraher on 7/21/23.
//


//
//  aactowav.swift
//  KDVS
//
//  Created by John Carraher on 7/21/23.
//

import Foundation
import AVFoundation


func fileExists(at url: URL) -> Bool {
    let fileManager = FileManager.default
    return fileManager.fileExists(atPath: url.path)
}

func readRawAudioFile(url: URL) -> Data? {
    do {
        let fileData = try Data(contentsOf: url)
        return fileData
    } catch {
        print("Error reading raw audio file: \(error)")
        return nil
    }
}

func convertAACtoWAV(inputURL: URL, outputURL: URL, completion: @escaping (Error?) -> Void) {
    deleteBeforeMarkerFFF1(inputURL: inputURL) {
        var error: OSStatus = noErr

        var destinationFile: ExtAudioFileRef? = nil
        var sourceFile: ExtAudioFileRef? = nil

        var srcFormat: AudioStreamBasicDescription = AudioStreamBasicDescription()
        var dstFormat: AudioStreamBasicDescription = AudioStreamBasicDescription()
            
        do {
            error = ExtAudioFileOpenURL(inputURL as CFURL, &sourceFile)
            if error != noErr {
                throw NSError(domain: NSOSStatusErrorDomain, code: Int(error), userInfo: nil)
            }
            
            var thePropertySize: UInt32 = UInt32(MemoryLayout.stride(ofValue: srcFormat))
                
            ExtAudioFileGetProperty(sourceFile!,
                                        kExtAudioFileProperty_FileDataFormat,
                                        &thePropertySize, &srcFormat)
                
            dstFormat.mSampleRate = 44100 // Set sample rate
            dstFormat.mFormatID = kAudioFormatLinearPCM
            dstFormat.mChannelsPerFrame = 1
            dstFormat.mBitsPerChannel = 16
            dstFormat.mBytesPerPacket = 2 * dstFormat.mChannelsPerFrame
            dstFormat.mBytesPerFrame = 2 * dstFormat.mChannelsPerFrame
            dstFormat.mFramesPerPacket = 1
            dstFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger

            // Create destination file
            error = ExtAudioFileCreateWithURL(
                outputURL as CFURL,
                kAudioFileWAVEType,
                &dstFormat,
                nil,
                AudioFileFlags.eraseFile.rawValue,
                &destinationFile)

            error = ExtAudioFileSetProperty(sourceFile!,
                                            kExtAudioFileProperty_ClientDataFormat,
                                            thePropertySize,
                                            &dstFormat)

            error = ExtAudioFileSetProperty(destinationFile!,
                                            kExtAudioFileProperty_ClientDataFormat,
                                            thePropertySize,
                                            &dstFormat)

            let bufferByteSize: UInt32 = 32768
            var srcBuffer = [UInt8](repeating: 0, count: Int(bufferByteSize))
            var sourceFrameOffset: ULONG = 0
            while true {
                var fillBufList = AudioBufferList(
                    mNumberBuffers: 1,
                    mBuffers: AudioBuffer(
                        mNumberChannels: 2,
                        mDataByteSize: bufferByteSize,
                        mData: srcBuffer.withUnsafeMutableBytes { $0.baseAddress }
                    )
                )
                var numFrames: UInt32 = 0

                if dstFormat.mBytesPerFrame > 0 {
                    numFrames = bufferByteSize / dstFormat.mBytesPerFrame
                }

                error = ExtAudioFileRead(sourceFile!, &numFrames, &fillBufList)

                if numFrames == 0 {
                    error = noErr
                    break
                }

                sourceFrameOffset += numFrames
                error = ExtAudioFileWrite(destinationFile!, numFrames, &fillBufList)
            }

            error = ExtAudioFileDispose(destinationFile!)
            error = ExtAudioFileDispose(sourceFile!)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}


func deleteBeforeMarkerFFF1(inputURL: URL, completion: @escaping () -> Void) {
    do {
        // Read the AAC audio file as binary data
        var inputData = try Data(contentsOf: inputURL)

        // Find the position of the marker "FFF1"
        guard let markerRange = inputData.range(of: Data([0xFF, 0xF1])) else {
            completion()
            return
        }

        // Remove all data before the marker "FFF1"
        let trimmedData = inputData.subdata(in: markerRange.lowerBound..<inputData.endIndex)

        // Replace the original binary data with the modified binary data
        inputData = trimmedData

        // Write the modified binary data back to the AAC audio file
        try inputData.write(to: inputURL)

        completion()
    } catch {
        // Handle the error here
        print("Error: \(error)")
        completion()
    }
}
