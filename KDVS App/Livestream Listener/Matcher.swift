//
//  Matcher.swift
//  KDVS
//
//  Created by John Carraher on 6/24/23.
//

import Foundation
import ShazamKit


class ShazamManager: NSObject, SHSessionDelegate, ObservableObject {
    
    private let session = SHSession()
    @Published var analyzedSong: ShazamSong? = nil
    var completionHandler: ((String?, String?, URL?) -> Void)?

    override init() {
        super.init()
        session.delegate = self
    }
    
    func identifySong(with buffer: AVAudioPCMBuffer, completion: @escaping (String?, String?, URL?) -> Void) {
        completionHandler = completion

        let signatureGenerator = SHSignatureGenerator()

        do {
            try signatureGenerator.append(buffer, at: nil)
        } catch {
            print("Error appending audio buffer to signature generator: \(error.localizedDescription)")
            completion(nil, nil, nil)
            return
        }

        guard let signature = try? signatureGenerator.signature() else {
            print("Error generating signature")
            completion(nil, nil, nil)
            return
        }

        print("PCM Buffer:")
        print("Number of channels: \(buffer.format.channelCount)")
        print("Length in seconds: \(Double(buffer.frameLength) / buffer.format.sampleRate)")
        
        
        session.match(signature)
    }

    func session(_ session: SHSession, didFind match: SHMatch) {
        print("CalledA")
        let mediaItems = match.mediaItems

        if mediaItems.isEmpty {
            print("No match found")
            completionHandler?(nil, nil, nil)
            return
        }

        for matchedMediaItem in mediaItems {
            let songName = matchedMediaItem.title
            let artist = matchedMediaItem.artist
            let artworkURL = matchedMediaItem.artworkURL

            print("Matched Song: \(songName ?? "Unknown")")
            print("Artist: \(artist ?? "Unknown")")
            
            completionHandler?(songName, artist, artworkURL)
        }
    }

    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        print("CalledB")
        if let error = error {
            print("Error matching signature: \(error.localizedDescription)")
        } else {
            print("No match found")
        }

        completionHandler?(nil, nil, nil)
    }

    func analyzeSegment(audioURL: URL, completion: @escaping () -> Void) {
        print("Analyzing Stream")
        
        // Create an AVAudioFile for the recorded audio file
        let recordedFile: AVAudioFile
        do {
            recordedFile = try AVAudioFile(forReading: audioURL)
        } catch {
            print("Error creating AVAudioFile: \(error.localizedDescription)")
            return
        }
        
        // Determine the source file format
        let sourceFormat = recordedFile.processingFormat
        
        // Create the output format as 16-bit PCM with a sample rate matching the source format
        let outputFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: sourceFormat.sampleRate, channels: sourceFormat.channelCount, interleaved: false)
        
        guard let unwrappedOutputFormat = outputFormat else {
            print("Error creating output format")
            return
        }
        
        // Create an AVAudioConverter
        guard let converter = AVAudioConverter(from: sourceFormat, to: unwrappedOutputFormat) else {
            print("Error creating AVAudioConverter")
            return
        }

        // Determine the number of frames for conversion
        let sourceFrameCount = AVAudioFrameCount(recordedFile.length)

        // Allocate buffer for reading the source file
        guard let buffer = AVAudioPCMBuffer(pcmFormat: sourceFormat, frameCapacity: sourceFrameCount) else {
            print("Failed to create buffer")
            return
        }

        // Read the audio file into the buffer
        do {
            try recordedFile.read(into: buffer)
        } catch {
            print("Error reading audio file: \(error.localizedDescription)")
            return
        }

        // Allocate buffer for the converted output
        let outputFrameCapacity = AVAudioFrameCount(sourceFrameCount)
        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: unwrappedOutputFormat, frameCapacity: outputFrameCapacity) else {
            print("Failed to create output buffer")
            return
        }

        // Convert the buffer to the desired output format
        var error: NSError?

        let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
            outStatus.pointee = AVAudioConverterInputStatus.haveData
            return buffer
        }

        let status = converter.convert(to: outputBuffer, error: &error, withInputFrom: inputBlock)

        if let error = error {
            print("Error converting audio format: \(error.localizedDescription)")
            return
        }

        if status == .error {
            print("Error converting audio format")
            return
        }

        // Use the converted outputBuffer for analysis or further processing
        identifySong(with: outputBuffer) { songName, artist, artworkURL in
            DispatchQueue.main.async { // Perform the update on the main thread
                if let songName = songName, let artist = artist {
                    let analyzedSong = ShazamSong(title: songName, artist: artist, artworkURL: artworkURL)
                    self.analyzedSong = analyzedSong
                    completion()
                } else {
                    self.analyzedSong = nil
                    completion()
                }
            }
        }
    }
}

struct ShazamSong {
    let title: String
    let artist: String
    let artworkURL: URL?
}
