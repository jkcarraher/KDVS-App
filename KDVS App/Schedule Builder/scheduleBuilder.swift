//
//  scheduleBuilder.swift
//  KDVS
//
//  Created by John Carraher on 8/1/23.
//

import Foundation
import SwiftSoup


func getSchedule(completion: @escaping ([Show]) -> Void) {
    guard let url = URL(string: "https://kdvs.org/programming/schedule-grid/") else {
        completion([])
        return
    }

    URLSession.shared.dataTask(with: url) { data, _, error in
        guard error == nil,
              let data = data,
              let htmlString = String(data: data, encoding: .utf8)
        else {
            completion([])
            return
        }

        do {
            let doc = try SwiftSoup.parse(htmlString)
            let tbody = try doc.select("tbody")
            var shows: [Show] = []

            let rows = try tbody.select("tr")
            for row in rows {
                let cells = try row.select("td")

                for (_, cell) in cells.enumerated() {
                    //Get showElements
                    let showNameElements = try cell.select("div.info p a")
                    let showNames = try showNameElements.map { try $0.text() }
                    let showURLs = try showNameElements.map { try $0.attr("href") }
                                            
                    if showNames.isEmpty {
                        // Create an empty show and add it to the array
                        let emptyShow = Show(name: "",
                                             djName: nil,
                                             playlistImageURL: nil,
                                             alternatingType: 0,
                                             alternatingPos: 0,
                                             startTime: Date(),
                                             endTime: Date(),
                                             colSize: 1,
                                             DOTW: "N/A",
                                             showDates: [],
                                             seasonStartDate: Date(),
                                             seasonEndDate: Date())
                        shows.append(emptyShow)
                    } else {
                        let timeString = try cell.select("div.info p.time").text()
                        let timeComponents = timeString.components(separatedBy: " - ")
                        guard timeComponents.count == 2,
                              let startTime = timeComponents[0].toDate(format: "h:mma"),
                              let endTime = timeComponents[1].toDate(format: "h:mma")
                        else {
                            continue
                        }
                        
                        // Get the show Alternating Type
                        let alternatingType = showNames.count

                        // Get the rowspan attribute value
                        let rowspanString = try cell.attr("rowspan")
                        let colsize = Int(rowspanString) ?? 1 // Default to 1 if rowspan attribute is not present
                        
                        // Get CurrentDate
                        let currentDate = Date() // Replace this with your current date
                        let programDateRange = getProgramDateRange(for: currentDate)

                        for (index, name) in showNames.enumerated() {
                            //Scrape the URL at "showURLs[index]" to get the playlistImage, & DJ Name(s)
                            let show = Show(name: name,
                                            djName: nil,
                                            showURL: URL(string: showURLs[index]),
                                            alternatingType: alternatingType,
                                            alternatingPos: index+1,
                                            startTime: startTime,
                                            endTime: endTime,
                                            colSize: colsize,
                                            DOTW: "N/A",
                                            showDates: [],
                                            seasonStartDate: programDateRange!.startDate, // Replace this with the actual season start date
                                            seasonEndDate: programDateRange!.endDate) // Replace this with the actual season end date
                            shows.append(show)
                        }
                    }
                }
            }
            addShowDOTW(listOfShows: &shows)
            sortShowsByTimeAndDay( &shows)
            
            completion(shows)
        } catch {
            print("Error parsing HTML: \(error)")
            completion([])
        }
    }.resume()
}

func addShowDOTW(listOfShows: inout [Show]) {
    let daysOfTheWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    var offsetFlag = [0, 0, 0, 0, 0, 0, 0]
    var i = 0
    
    for index in 0..<listOfShows.count {
        if offsetFlag[i] > 0 {
            // We skip this Day of the week
            while(offsetFlag[i]>0){
                offsetFlag[i] -= 1
                i+=1
                if i > 6 {
                    i = 0
                }
            }
        }
        
        listOfShows[index].DOTW = daysOfTheWeek[i]
        if let colSize = listOfShows[index].colSize, colSize > 1 {
            if( (listOfShows[index].alternatingType == listOfShows[index].alternatingPos) ){
                offsetFlag[i] = colSize - 1

            }
        }

        
        // Increment and handles if i isn't > 6
        if( (listOfShows[index].alternatingType == listOfShows[index].alternatingPos) ){
            i += 1
            if i > 6 {
                i = 0
            }
        }
        
    }
    // Remove shows with empty names
    listOfShows.removeAll { $0.name.isEmpty }
}

func sortShowsByTimeAndDay(_ shows: inout [Show]) {
    let calendar = Calendar.current
    shows.sort(by: { (show1, show2) -> Bool in
        let dayOfWeek1 = (show1.DOTW == "Sunday" ? 0 : calendar.weekdaySymbols.firstIndex(of: show1.DOTW!) ?? 0)
        let dayOfWeek2 = (show2.DOTW == "Sunday" ? 0 : calendar.weekdaySymbols.firstIndex(of: show2.DOTW!) ?? 0)
        
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
