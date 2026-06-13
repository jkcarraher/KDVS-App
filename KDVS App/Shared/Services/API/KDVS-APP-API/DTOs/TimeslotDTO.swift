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
        
        let parsedSeasonStartDate = dateFormatter.date(from: season.start_date) ?? Date()
        let parsedSeasonEndDate = dateFormatter.date(from: season.end_date) ?? Date()

        let imageURL = URL(string: show.image_url!) ?? URL(string: "https://kdvs.org/placeholder.png")!
        
        let anchor = dateFormatter.date(from: anchor_date) ?? parsedSeasonStartDate

        let dates = generateShowDates(
            weekday: weekday,
            seasonStart: parsedSeasonStartDate,
            seasonEnd: parsedSeasonEndDate,
            anchorDate: anchor,
            intervalWeeks: recurrence_interval_weeks,
            offset: recurrence_offset,
        )

        return Show(
            id: show.id,
            name: show.name,
            djName: personas.map { $0.name }.joined(separator: ", "),
            playlistImageURL: imageURL,
            
            startTime: start_time.toTimeOfDay()!,
            endTime: end_time.toTimeOfDay()!,
            
            alternates: recurrence_interval_weeks > 1,
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
    intervalWeeks: Int,
    offset: Int,
    timeZone: TimeZone = .current
) -> [Date] {

    var results: [Date] = []

    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = timeZone

    // Find first occurrence of target weekday on/after season start
    let weekdayComponent = backendWeekdayToCalendarWeekday(weekday)
    var current = seasonStart

    while cal.component(.weekday, from: current) != weekdayComponent {
        guard let next = cal.date(byAdding: .day, value: 1, to: current) else { break }
        current = next
    }

    // Move backward to the anchor-aligned week boundary
    let anchorWeekStart = cal.dateInterval(of: .weekOfYear, for: anchorDate)?.start ?? anchorDate

    while current <= seasonEnd {

        guard let weekStart = cal.dateInterval(of: .weekOfYear, for: current)?.start else {
            break
        }

        let weeksSinceAnchor = cal.dateComponents([.weekOfYear],
                                                   from: anchorWeekStart,
                                                   to: weekStart).weekOfYear ?? 0

        if intervalWeeks == 1 {
            // Every week
            results.append(current)
        } else {
            if (weeksSinceAnchor + offset) % intervalWeeks == 0 {
                results.append(current)
            }
        }

        // Jump forward one week at a time (same weekday)
        guard let next = cal.date(byAdding: .weekOfYear, value: 1, to: current) else {
            break
        }
        current = next
    }

    return results
}

func backendWeekdayToCalendarWeekday(_ weekday: Int) -> Int {
    weekday == 7 ? 1 : weekday + 1
}
