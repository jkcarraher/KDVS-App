//
//  AudioStreamRecorder.swift
//  KDVS
//
//  Created by John Carraher on 6/29/23.
//
import Foundation
import AVFoundation

class AudioStreamRecorder {
    private var audioFile: AVAudioFile?
    private var recordingURL: URL?
    private var isRecording: Bool = false
    private var cachingPlayerItem: CachingPlayerItem?
    private var player: AVPlayer? // Add AVPlayer
    
    func startRecording (completion: @escaping () -> Void) {
        // Create the CachingPlayerItem with the stream URL
        let streamURL = URL(string: "https://archives.kdvs.org/stream")!
        cachingPlayerItem = CachingPlayerItem(url: streamURL, recordingName: "recording.aac") // Use CachingPlayerItem
        
        // Create the AVPlayer with the CachingPlayerItem
        player = AVPlayer(playerItem: cachingPlayerItem!)
        
        // Start playing the audio
        player?.play()
        isRecording = true
        print("Audio recording started")
        completion()
    }
    
    func stopRecording(completion: @escaping (Error?) -> Void) {
        // Stop playing the audio
        player?.pause()
        
        // Stop downloading for CachingPlayerItem
        //JUWAAAA~!
        cachingPlayerItem?.stopDownloading {
            let aacRecordingURL = self.cachingPlayerItem?.getDownloadedFileURL()
            let wavRecordingURL = aacRecordingURL?.deletingPathExtension().appendingPathExtension("wav")
            print("AAC@: \(String(describing: aacRecordingURL)) WAV@: \(String(describing: wavRecordingURL))")
            
            self.cachingPlayerItem = nil
            
            self.isRecording = false
            print("Audio recording stopped")
            
            convertAACtoWAV(inputURL: aacRecordingURL!, outputURL: wavRecordingURL!){ error in
                // Handle the error, if any
                if let error = error {
                    print("Error converting AAC to WAV: \(error.localizedDescription)")
                    //completion with error, return an error
                    completion(error)
                } else {
                    print("AAC to WAV conversion completed successfully")
                }
            }
            self.recordingURL = wavRecordingURL
            print("Conversion successful!")
            completion(nil)
        }
    }
    
    func getAudioFileURL() -> URL? {
        print("Fetched URL @:\(recordingURL!)")
        return recordingURL
    }
}
