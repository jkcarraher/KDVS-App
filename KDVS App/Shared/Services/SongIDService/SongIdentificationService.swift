//
//  SongIdentificationService.swift
//  KDVS
//
//  Created by John Carraher on 6/20/26.
//

actor SongIdentificationService {
    private let recorder: AudioStreamRecorder = AudioStreamRecorder(streamURL: Stream.kdvsArchive)
    private let converter: AACtoPCMService = AACtoPCMService()
    private let shazam: ShazamService = ShazamService()

    func identifyCurrentSong() async throws -> ShazamSong? {
        // 1. Take AAC Stream (KDVS STREAM) and record it
        let aacFile = try await recorder.recordStream(for: 5)
        
        // 2. Convert that to a PCM buffer
        let pcmBuffer = try converter.convertAACtoPCM(aacFileURL: aacFile)
        
        // 3. Give Shazam that PCM buffer
        return try await shazam.identify(from: pcmBuffer)
    }
}
