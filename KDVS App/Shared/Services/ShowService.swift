//
//  ShowService.swift
//  KDVS
//
//  Created by John Carraher on 5/18/26.
//
import Foundation
import SwiftSoup
import UIKit
import SwiftUI

final class ShowService {

    func getCurrentShow() async throws -> Show {
        guard let url = URL(
            string: "https://sl2yinqpd0.execute-api.us-west-1.amazonaws.com/current-show/current-show"
        ) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Decode the outer JSON object
        let responseDict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
        guard let bodyString = responseDict?["body"] as? String,
              let bodyData = bodyString.data(using: .utf8) else {
            throw ShowServiceError.invalidBody
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(flexibleDateDecoder)
        
        return try decoder.decode(Show.self, from: bodyData)
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
