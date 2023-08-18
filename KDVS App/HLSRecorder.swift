//
//  HLSRecorder.swift
//  KDVS
//
//  Created by John Carraher on 6/29/23.
//

import Foundation
import AVFoundation

class HLSRecorder {
    private var assetWriter: AVAssetWriter?
    private var assetWriterInput: AVAssetWriterInput?
    private var assetReader: AVAssetReader?
    private var trackOutput: AVAssetReaderTrackOutput?
    private var recordingURL: URL?
    
    func startRecording(fromURL url: URL) {
        guard let asset = AVAsset(url: url) as? AVURLAsset else {
            print("Failed to create asset.")
            return
        }
        
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let outputURL = tempDirectoryURL.appendingPathComponent("livestream_recording.wav")
        
        do {
            assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: .wav)
        } catch {
            print("Failed to create asset writer: \(error.localizedDescription)")
            return
        }
        
        let settings = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 32,
            AVLinearPCMIsFloatKey: false, // Use integer LPCM
            AVLinearPCMIsNonInterleaved: false,
            AVLinearPCMIsBigEndianKey: false
        ] as [String: Any]
        
        assetWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: settings)
        assetWriter?.add(assetWriterInput!)
        
        guard let audioTrack = asset.tracks(withMediaType: .audio).first else {
            print("No audio track found in the asset.")
            return
        }
        
        trackOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
        
        do {
            assetReader = try AVAssetReader(asset: asset)
            assetReader?.add(trackOutput!)
        } catch {
            print("Failed to create asset reader: \(error.localizedDescription)")
            return
        }
        
        assetWriter?.startWriting()
        assetWriter?.startSession(atSourceTime: .zero)
        
        assetReader?.startReading()
        
        let queue = DispatchQueue(label: "com.example.recordingQueue")
        assetWriterInput?.requestMediaDataWhenReady(on: queue) {
            while self.assetWriterInput?.isReadyForMoreMediaData ?? false {
                guard let sampleBuffer = self.trackOutput?.copyNextSampleBuffer() else {
                    self.assetWriterInput?.markAsFinished()
                    self.assetWriter?.finishWriting { [weak self] in
                        if self?.assetWriter?.status == .completed {
                            self?.recordingURL = outputURL
                            print("Recording completed successfully.")
                        } else {
                            print("Recording failed with error: \(self?.assetWriter?.error?.localizedDescription ?? "")")
                        }
                    }
                    return
                }
                
                self.assetWriterInput?.append(sampleBuffer)
            }
        }
    }
    
    func stopRecording(completion: @escaping () -> Void) {
        assetReader?.cancelReading()
        assetWriterInput?.markAsFinished()
        
        assetWriter?.finishWriting {
            if self.assetWriter?.status == .completed {
                print("Recording completed successfully.")
            } else {
                print("Recording failed with error: \(self.assetWriter?.error?.localizedDescription ?? "")")
            }
            self.recordingURL = nil
            completion()
        }
    }
    
    func getAudioFileURL() -> URL? {
        return recordingURL
    }
}

