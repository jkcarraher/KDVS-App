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

//Returns a list of all existing Shows
func scrapeHomeData(completion: @escaping (Show) -> Void) {
    guard let url = URL(string: "https://kdvs.org/") else { return }
    let session = URLSession.shared
    
    let task = session.dataTask(with: url) { data, response, error in
        guard error == nil else {
            print("Error: \(error!)")
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("No response from server")
            return
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            print("Server error: \(httpResponse.statusCode)")
            return
        }
        
        if let data = data, let html = String(data: data, encoding: .utf8) {
            do {
                let doc: Document = try SwiftSoup.parse(html)
                var show = Show(
                    name: "--------",
                    djName: "------",
                    playlistImageURL: URL(string: "https://library.kdvs.org/static/core/images/kdvs-image-placeholder.jpg"),
                    alternatingType: 0,
                    startTime: Date(),
                    endTime: Date(),
                    showDates: [],
                    seasonStartDate: {
                        let calendar = Calendar(identifier: .gregorian)
                        var dateComponents = DateComponents()
                        dateComponents.year = 2023
                        dateComponents.month = 6
                        dateComponents.day = 19
                        dateComponents.timeZone = TimeZone(identifier: "America/Los_Angeles")
                        return calendar.date(from: dateComponents)!
                    }(),
                    seasonEndDate: {
                        // Set the desired end date for the show using the same approach
                        let calendar = Calendar(identifier: .gregorian)
                        var dateComponents = DateComponents()
                        dateComponents.year = 2023
                        dateComponents.month = 9
                        dateComponents.day = 21
                        dateComponents.timeZone = TimeZone(identifier: "America/Los_Angeles")
                        return calendar.date(from: dateComponents)!
                    }()
                )
                
                if let showElem = try doc.select("#whats_on_now-2 > div:nth-child(1) > a > div.redtitle.fleft.clr").first() {
                    show.name = try showElem.text()
                }
                
                if let djElem = try doc.select("#whats_on_now-2 > div:nth-child(1) > a > div:nth-child(3)").first() {
                    show.djName = try djElem.text()
                }
                    
                if let playlistImageDiv = try doc.select("#whats_on_now-2 > div:nth-child(1) > a > div:nth-child(1) > div").first(),
                   let styleAttr = try? playlistImageDiv.attr("style") {
                    let pattern = "background:\\s*url\\(['\"]?([^'\"]+)['\"]?\\)"
                    let regex = try NSRegularExpression(pattern: pattern, options: [])
                    let matches = regex.matches(in: styleAttr, options: [], range: NSRange(location: 0, length: styleAttr.utf16.count))
                    if let match = matches.first, match.numberOfRanges == 2 {
                        let playlistImageUrlString = String(styleAttr[Range(match.range(at: 1), in: styleAttr)!])
                        show.playlistImageURL = URL(string: playlistImageUrlString)
                    }
                }
                
                if let timeElem = try doc.select("#whats_on_now-2 > div:nth-child(1) > a > div:nth-child(5)").first() {
                    let timeString = try timeElem.text()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "h:mma"
                    
                    let times = timeString.split(separator: "-").map { String($0) }
                    if times.count == 2 {
                        let startTime = formatter.date(from: times[0].trimmingCharacters(in: .whitespacesAndNewlines))
                        let endTime = formatter.date(from: times[1].trimmingCharacters(in: .whitespacesAndNewlines))
                        show.startTime = startTime ?? Date()
                        show.endTime = endTime ?? Date()
                    }
                }
                
                DispatchQueue.main.async {
                    completion(show)
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    task.resume()
}

func scrapeShowPageData(show: Show, completion: @escaping (Show) -> Void) {
    guard let showURL = show.showURL else {
        completion(show)
        return
    }
    
    URLSession.shared.dataTask(with: showURL) { data, _, error in
        guard error == nil,
              let data = data,
              let showPageHtmlString = String(data: data, encoding: .utf8)
        else {
            completion(show)
            return
        }
        
        do {
            let showPageDoc = try SwiftSoup.parse(showPageHtmlString)
            let djName = try showPageDoc.select("p.dj-name").text()
            let showcaseImageStyle = try showPageDoc.select("div.showcase-image").attr("style")
            let showcaseImageURL = showcaseImageStyle.components(separatedBy: "url('")[1].components(separatedBy: "')")[0]
            
            var updatedShow = show
            updatedShow.djName = djName
            updatedShow.playlistImageURL = URL(string: showcaseImageURL)
            
            // Scrape upcoming show dates and add them to the show's showdates list
            let upcomingPlaylistsLink = try showPageDoc.select("a:contains(Upcoming Playlists)").attr("href")
            let upcomingPlaylistsURL = URL(string: upcomingPlaylistsLink)
            scrapeUpcomingPlaylistsPage(upcomingPlaylistsURL!) { showdates in
                updatedShow.showDates = showdates
                
                // Fetch the image from the URL
                guard let imageUrl = updatedShow.playlistImageURL else {
                    completion(updatedShow) // No image URL, complete immediately
                    return
                }
                
                URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                    guard let data = data, error == nil else {
                        completion(updatedShow) // Error fetching image, complete with the current state
                        return
                    }
                    
                    if let uiImage = UIImage(data: data) {
                        if let averageColor = uiImage.averageColor {
                            let adjustedColor = averageColor.adjusted(
                                brightnessFactor: 0.6,
                                saturationFactor: 10
                            )
                            DispatchQueue.main.async {
                                updatedShow.showColor = Color(adjustedColor)
                                completion(updatedShow) // Complete after setting the color
                            }
                        }
                    }
                    
                }.resume()
            }
            
        } catch {
            print("Error parsing show page HTML: \(error)")
            completion(show)
        }
        
    }.resume()
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
