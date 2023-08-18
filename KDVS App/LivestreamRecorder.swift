//
//  LivestreamRecorder.swift
//  KDVS
//
//  Created by John Carraher on 6/23/23.
//
import Foundation
import AVFoundation

class LivestreamRecorder {
    private var recordingURL: URL?
    private var audioEngine: AVAudioEngine?
    private var audioFile: AVAudioFile?
    private var isRecording: Bool = false

    func startRecording(fromURL url: URL) {
        let session = AVAudioSession.sharedInstance()


        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("Error: \(error.localizedDescription)")
            return
        }

        let recordingFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: session.sampleRate, channels: 1, interleaved: false)

        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let audioFileURL = tempDirectoryURL.appendingPathComponent("livestream_recording.wav")

        do {
            audioFile = try AVAudioFile(forWriting: audioFileURL, settings: recordingFormat!.settings)
        } catch {
            print("Error creating audio file: \(error.localizedDescription)")
            return
        }

        audioEngine = AVAudioEngine()

        guard let playerNode = audioEngine?.inputNode else {
            print("Audio engine has no input node")
            return
        }

        playerNode.installTap(onBus: 0, bufferSize: 4096, format: recordingFormat) { buffer, time in
            do {
                try self.audioFile?.write(from: buffer)
                print("Writing audio buffer to file...")
            } catch {
                print("Error writing buffer to file: \(error.localizedDescription)")
            }
        }
        
        let playerItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: playerItem)

        let outputNode = audioEngine?.outputNode
        audioEngine?.connect(playerNode, to: outputNode!, format: recordingFormat)
        
        do {
            try audioEngine?.start()
            player.play()
            isRecording = true
            print("Recording started")
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
    }

    func stopRecording(completion: @escaping () -> Void) {
        // Stop the audio engine
        audioEngine?.stop()

        // Wait for a short delay to ensure the audio file is finished writing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isRecording = false
            self.recordingURL = self.audioFile?.url
            self.audioFile = nil
            print("Recording stopped")

            // Call the completion handler
            completion()
        }
    }

    func getAudioFileURL() -> URL? {
        return self.recordingURL
    }
}
