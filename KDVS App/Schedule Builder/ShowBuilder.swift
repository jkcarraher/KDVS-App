//
//  ShowBuilder.swift
//  KDVS
//
//  Created by John Carraher on 8/11/23.
//

import Foundation
import SwiftSoup
import UIKit
import SwiftUI

func getCurrentShow(completion: @escaping (Show?) -> Void) {
    guard let url = URL(string: "https://sl2yinqpd0.execute-api.us-west-1.amazonaws.com/current-show/current-show") else {
        print("Invalid URL")
        completion(nil)
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print("Error fetching current show: \(error?.localizedDescription ?? "Unknown error")")
            completion(nil)
            return
        }

        do {
            // Decode the outer JSON object
            let responseDict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            // Ensure the body is a valid string containing JSON
            if let bodyString = responseDict?["body"] as? String,
               let bodyData = bodyString.data(using: .utf8) {
                
                // Decode the inner body JSON into the Show object
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    let formats = ["HH:mm:ss", "yyyy-MM-dd"]
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
                
                let show = try decoder.decode(Show.self, from: bodyData)
                DispatchQueue.main.async {
                    completion(show)
                }
            } else {
                print("Body is missing or not a valid string")
                completion(nil)
            }
        } catch {
            print("Error decoding JSON: \(error)")
            completion(nil)
        }
    }
    task.resume()
}


func scrapeUpcomingPlaylistsPage(_ url: URL, completion: @escaping ([Date]) -> Void) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error fetching data: \(error)")
            return
        }
        
        guard let data = data, let html = String(data: data, encoding: .utf8) else {
            print("No data received from the server")
            return
        }
        
        do {
            let doc = try SwiftSoup.parse(html)
            
            var showDates: [Date] = []
            
            let tbody = try doc.select("tbody")

            let rows = try tbody.select("tr")
            for row in rows {
                let dateString = try row.select("td").text()

                // Regular expression pattern to match the date and start time
                let pattern = #"(\d{1,2}/\d{1,2}/\d{4}) @ (\d{1,2}:\d{2}[AP]M)"#
                if let range = dateString.range(of: pattern, options: .regularExpression) {
                    let extractedDate = String(dateString[range])
                    //print("\(extractedDate)")
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "M/dd/yyyy' @ 'h:mma"  // Adjusted date format
                    dateFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles") // Set PST time zone

                    
                    if let date = dateFormatter.date(from: extractedDate) {
                        showDates.append(date)
                    }
                } else {
                    print("Date pattern not found in the input string")
                }
            }
            
            completion(showDates)
        } catch {
            print("Error parsing HTML: \(error)")
        }
    }.resume()
}

private func setAverageColor(show: inout Show) {
    
}
