//
//  scheduleBuilder.swift
//  KDVS
//
//  Created by John Carraher on 8/1/23.
//

import Foundation
import SwiftSoup

func fetchShows(completion: @escaping ([Show]) -> Void) {
    guard let url = URL(string: "https://sl2yinqpd0.execute-api.us-west-1.amazonaws.com/shows") else {
        print("Invalid URL")
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print("Error fetching shows: \(error?.localizedDescription ?? "Unknown error")")
            return
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)

                let formats = [
                    "HH:mm:ss",
                    "yyyy-MM-dd"
                ]

                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")

                for format in formats {
                    dateFormatter.dateFormat = format
                    if let date = dateFormatter.date(from: dateString) {
                        return date
                    }
                }

                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Date string '\(dateString)' does not match any known format."
                )
            }

            let responseDict = try JSONSerialization.jsonObject(with: data) as? [String: Any]

            if let body = responseDict?["body"] as? String,
               let bodyData = body.data(using: .utf8) {
                let shows = try decoder.decode([Show].self, from: bodyData)
                print("SHOWS: \(shows)")
                DispatchQueue.main.async {
                    completion(shows)
                }
            } else {
                print("Body is missing or not a string")
            }
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
    task.resume()
}


func sortShowsByTimeAndDay(_ shows: inout [Show]) {
    let calendar = Calendar.current
    shows.sort(by: { (show1, show2) -> Bool in
        let dayOfWeek1 = (show1.DOTW == "Sunday" ? 0 : calendar.weekdaySymbols.firstIndex(of: show1.DOTW) ?? 0)
        let dayOfWeek2 = (show2.DOTW == "Sunday" ? 0 : calendar.weekdaySymbols.firstIndex(of: show2.DOTW) ?? 0)
        
        let timeAndDay1 = dayOfWeek1 * 24 * 60 + show1.startTime.totalMinutesSinceMidnight
        let timeAndDay2 = dayOfWeek2 * 24 * 60 + show2.startTime.totalMinutesSinceMidnight
        
        return timeAndDay1 < timeAndDay2
    })
}

extension String {
    func toDate(format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
}

extension Date {
    var totalMinutesSinceMidnight: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: self)
        return components.hour! * 60 + components.minute!
    }
}
