//
//  ShowService.swift
//  KDVS
//
//  Created by John Carraher on 5/18/26.
//

import Foundation

final class ShowService {
    private let apiService: KDVSAPIService
    
    init (apiService: KDVSAPIService) {
        self.apiService = apiService
    }

    func getCurrentShow() async throws -> Show {
        try await apiService.fetchCurrentShow()
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
