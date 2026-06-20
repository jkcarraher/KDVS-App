import AVFAudio
import ShazamKit

actor ShazamService {

    func identify(
        from buffer: AVAudioPCMBuffer
    ) async throws -> ShazamSong? {
        let session = SHSession()
        let generator = SHSignatureGenerator()

        do {
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
                print(error)
                throw error
            }

        } catch {
            print(error)
            throw error
        }
    }
}
