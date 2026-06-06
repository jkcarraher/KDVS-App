//
//  ShowService.swift
//  KDVS
//
//  Created by John Carraher on 5/18/26.
//

import Foundation

final class ShowService {

    func getCurrentShow() -> Show {
        return Show(
            id: "",
            name: "",
            djName: "",
            playlistImageURL: URL(string: "https://")!,
            startTime: TimeOfDay(hour: 0, minute: 0, second: 0),
            endTime: TimeOfDay(hour: 0, minute: 0, second: 0),
            alternates: false,
            DOTW: "",
            dates: [],
            firstShowDate: Date(),
            lastShowDate: Date()
        )
    }
}

private extension ShowService {

    func flexibleDateDecoder(_ decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)

        let formats = ["HH:mm:ss", "yyyy-MM-dd"]

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Unsupported date format: \(dateString)"
        )
    }
}


enum ShowServiceError: Error {
    case invalidBody
    case invalidHTML
}
