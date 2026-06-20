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
        let dtoTimezone = TimeZone(identifier: timezone)!

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = dtoTimezone
                
        let parsedSeasonStartDate = dateFormatter.date(from: season.start_date) ?? Date()
        let parsedSeasonEndDate = dateFormatter.date(from: season.end_date) ?? Date()

        let imageURL = URL(string: show.image_url!) ?? URL(string: "https://kdvs.org/placeholder.png")!
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = dtoTimezone

        let comps = anchor_date.split(separator: "-").map { Int($0)! }

        let anchor = calendar.date(
            from: DateComponents(
                year: comps[0],
                month: comps[1],
                day: comps[2]
            )
        )!

        let dates = generateShowDates(
            weekday: weekday,
            seasonStart: parsedSeasonStartDate,
            seasonEnd: parsedSeasonEndDate,
            anchorDate: anchor,
            recurrence_interval_weeks: recurrence_interval_weeks,
            timeZone: dtoTimezone
        )

        return Show(
            id: show.id,
            name: show.name,
            djName: personas.map { $0.name }.joined(separator: ", "),
            playlistImageURL: imageURL,
            
            startTime: start_time.toTimeOfDay()!,
            endTime: end_time.toTimeOfDay()!,
            
            alternates: recurrence_interval_weeks > 1,
            timezone: TimeZone(identifier: timezone)!,
            DOTW: DayOfWeek(rawValue: weekday)?.displayName ?? "Unknown Day",
            dates: dates,
            
            firstShowDate: parsedSeasonStartDate,
            lastShowDate: parsedSeasonEndDate
        )
    }
}

enum DayOfWeek: Int, CaseIterable{
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case sunday = 7


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

func generateShowDates(
    weekday: Int,
    seasonStart: Date,
    seasonEnd: Date,
    anchorDate: Date,
    recurrence_interval_weeks: Int,
    timeZone: TimeZone,
) -> [Date] {

    guard recurrence_interval_weeks > 0 else { return [] }

    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = timeZone
    cal.firstWeekday = 1

    var results: [Date] = []

    var current = anchorDate

    while current < seasonStart {
        guard let next = cal.date(byAdding: .day, value: 7 * recurrence_interval_weeks, to: current) else {
            return results
        }
        current = next
    }

    while current <= seasonEnd {
        results.append(current)

        guard let next = cal.date(byAdding: .day, value: 7 * recurrence_interval_weeks, to: current) else {
            break
        }

        current = next
    }

    return results
}

func backendWeekdayToCalendarWeekday(_ weekday: Int) -> Int {
    weekday == 7 ? 1 : weekday + 1
}
