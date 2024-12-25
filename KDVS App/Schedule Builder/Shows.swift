//
//  Shows.swift
//  KDVS
//
//  Created by John Carraher on 4/18/23.
//

import Foundation
import SwiftUI
import SwiftSoup



struct Show : Codable, Identifiable, Hashable {
    //General Show Info
    var id: Int
    var name: String
    var djName: String
    var playlistImageURL: URL?
    var showColor: Color?
    var startTime: Date
    var endTime: Date
    var alternates: Bool
    
    var DOTW: String //Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
    
    var dates: [Date]
    var firstShowDate: Date
    var lastShowDate: Date
    
    // Custom initializer for manual creation of a Show instance with parameters
    init(id: Int, name: String, djName: String, playlistImageURL: URL, startTime: Date, endTime: Date, alternates: Bool, DOTW: String, dates: [Date], firstShowDate: Date, lastShowDate: Date) {
        self.id = id
        self.name = name
        self.djName = djName
        self.startTime = startTime
        self.endTime = endTime
        self.DOTW = DOTW
        self.dates = dates
        self.firstShowDate = firstShowDate
        self.lastShowDate = lastShowDate
        self.alternates = alternates
        self.playlistImageURL = playlistImageURL
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case djName = "dj_name"
        case playlistImageURL = "playlist_image_url"
        case showColor
        case startTime = "start_time"
        case endTime = "end_time"
        case DOTW = "current_dotw"
        case alternates = "alternates"
        case dates = "dates"
        case firstShowDate = "first_show_date"
        case lastShowDate = "last_show_date"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        // Decode all fields
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decode(Date.self, forKey: .endTime)
        DOTW = try container.decode(String.self, forKey: .DOTW)
        
        let dateStrings = try container.decode([String].self, forKey: .dates)
        dateFormatter.dateFormat = "MM/dd/yyyy"
        self.dates = dateStrings.compactMap { dateFormatter.date(from: $0) }

        firstShowDate = try container.decode(Date.self, forKey: .firstShowDate)
        lastShowDate = try container.decode(Date.self, forKey: .lastShowDate)
        alternates = try container.decode(Bool.self, forKey: .alternates)
        
        if let playlistImageUrlString = try? container.decode(String.self, forKey: .playlistImageURL) {
            playlistImageURL = URL(string: playlistImageUrlString)
        } else {
            playlistImageURL = nil
        }
        // Decode djName with fallback
        djName = try container.decodeIfPresent(String.self, forKey: .djName) ?? "Unknown DJ"
    }
}

func containsMatchingShow(shows: [Show], show: Show) -> Bool {
    for item in shows {
        if item.name == show.name {
            return true
        }
    }
    return false
}

func removeMatchingShow(from shows: inout [Show], showToRemove: Show) {
    shows.removeAll { show in
        return show.name == showToRemove.name
    }
}

struct ShowArt : View {
    var show : Show
    
    var body: some View {
        ZStack(alignment: .bottom, content: {
            AsyncImage(url: show.playlistImageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(width: 290, height: 290, alignment: .center)
            } placeholder: {
                ProgressView()
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("\(show.startTime.formattedTime(endTime: show.endTime))")
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .bold))
                        .padding(.all, 5)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(5)
                }
            }
            .padding(.all, 10)
        })
        .frame(width: 290, height: 290, alignment: .top)
        .background(Color.white)
        .cornerRadius(5)
    }
}

extension Date {
    func formattedTime(endTime: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm"
        let startMM = formatter.string(from: self)
        let endMM = formatter.string(from: endTime)
        
        formatter.dateFormat = "h"
        let startHour = formatter.string(from: self)
        let endHour = formatter.string(from: endTime)
        
        formatter.dateFormat = "a"
        let startAmpm = formatter.string(from: self)
        let endAmpm = formatter.string(from: endTime)
        
        if startAmpm != endAmpm {
            if startMM != "00" || endMM != "00" {
                if startMM != "00" && endMM != "00" {
                    return "\(startHour):\(startMM) \(startAmpm) - \(endHour):\(endMM) \(endAmpm)"
                } else if startMM != "00" && endMM == "00" {
                    return "\(startHour):\(startMM) \(startAmpm) - \(endHour) \(endAmpm)"
                } else if startMM == "00" && endMM != "00" {
                    return "\(startHour) \(startAmpm) - \(endHour):\(endMM) \(endAmpm)"
                } else {
                    return "error"
                }
            }else{
                return "\(startHour) \(startAmpm) - \(endHour) \(endAmpm)"
            }
        } else if startMM != "00" || endMM != "00" {
            if startMM != "00" && endMM != "00" {
                return "\(startHour):\(startMM) - \(endHour):\(endMM) \(endAmpm)"
            } else if startMM != "00" && endMM == "00" {
                return "\(startHour):\(startMM) - \(endHour) \(endAmpm)"
            } else if startMM == "00" && endMM != "00" {
                return "\(startHour) - \(endHour):\(endMM) \(endAmpm)"
            } else {
                return "error"
            }
        } else {
            return "\(startHour) - \(endHour) \(endAmpm)"
        }
    }
    
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
}

func getProgramDateRange(for currentDate: Date) -> (startDate: Date, endDate: Date)? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    let programmingPeriods: [(startDate: Date, endDate: Date)] = [
        (dateFormatter.date(from: "2023-06-20")!, dateFormatter.date(from: "2023-09-24")!),
        (dateFormatter.date(from: "2023-09-25")!, dateFormatter.date(from: "2024-01-07")!),
        (dateFormatter.date(from: "2024-01-08")!, dateFormatter.date(from: "2024-03-31")!),
        (dateFormatter.date(from: "2024-04-01")!, dateFormatter.date(from: "2024-06-16")!)
    ]
    
    for period in programmingPeriods {
        if currentDate >= period.startDate && currentDate <= period.endDate {
            return period
        }
    }
    
    return nil // Programming schedule not available for the current date
}
