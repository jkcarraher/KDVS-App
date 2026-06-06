//
//  Timeslot.swift
//  KDVS
//
//  Created by John Carraher on 6/5/26.
//

import Foundation

struct TimeslotDTO: Decodable {
    let id: String
    let show: ShowDTO
    let personas: [PersonaDTO]
    let season: SeasonDTO
    let weekday: Int
    let start_time: String
    let end_time: String
    let recurrence_interval_weeks: Int
    let recurrence_offset: Int
    let timezone: String
    let anchor_date: String
    let created_at: String
    let updated_at: String
}

extension TimeslotDTO {
    func toShow() -> Show {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let targetTimeZone = TimeZone(identifier: self.timezone)
        dateFormatter.timeZone = targetTimeZone
        
        let parsedFirstShowDate = dateFormatter.date(from: season.start_date) ?? Date()
        let parsedLastShowDate = dateFormatter.date(from: season.end_date) ?? Date()

        let imageURL = URL(string: show.image_url) ?? URL(string: "https://kdvs.org/placeholder.png")!

        return Show(
            id: id,
            name: show.name,
            djName: personas.map { $0.name }.joined(separator: ", "),
            playlistImageURL: imageURL,
            
            startTime: start_time.toTimeOfDay()!,
            endTime: end_time.toTimeOfDay()!,
            
            alternates: recurrence_interval_weeks > 1,
            DOTW: DayOfWeek(rawValue: weekday)?.displayName ?? "Unknown Day",
            dates: [],
            
            firstShowDate: parsedFirstShowDate,
            lastShowDate: parsedLastShowDate
        )
    }
}

enum DayOfWeek: Int {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var displayName: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
}
