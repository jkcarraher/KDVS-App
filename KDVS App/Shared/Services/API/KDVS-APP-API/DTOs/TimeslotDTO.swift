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
    func toModel() -> Show {
        Show(
            id: id,
            name: show.name,
            djName: personas.map{ $0.name }.joined(separator: ", "),
            playlistImageURL: URL(string: show.image_url)!,
            startTime: start_time.toTimeOfDay()!,
            endTime: end_time.toTimeOfDay()!,
            alternates: <#T##Bool#>,
            DOTW: DayOfWeek(rawValue: weekday)!.displayName,
            dates: <#T##[Date]#>,
            firstShowDate: season.start_date,
            lastShowDate: season.start_date)
    }
}

enum DayOfWeek: Int {
    case sunday = 0
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6

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
