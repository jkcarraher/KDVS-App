//
//  SongIdentificationService.swift
//  KDVS
//
//  Created by John Carraher on 6/20/26.
//

actor SongIdentificationService {

    private let sampler: AACtoPCMService = AACtoPCMService(streamURL: Stream.kdvsArchive)
    private let shazam: ShazamService = ShazamService()


    func identifyCurrentSong() async throws -> ShazamSong? {

        let buffer = try await sampler.captureSample()

        return try await shazam.identify(from: buffer)
    }
}
