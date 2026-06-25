//
//  Show.swift
//  KDVS
//
//  Created by John Carraher on 5/18/26.
//

import Foundation
import SwiftUI

struct Show: Codable, Identifiable, Hashable{
    //General Show Info
    var id: String
    var name: String
    var djName: String
    var playlistImageURL: URL?
    var showColor: String?
    var startTime: TimeOfDay
    var endTime: TimeOfDay
    var alternates: Bool
    var timezone: TimeZone
    
    var DOTW: String //Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
    
    var dates: [Date]
    var firstShowDate: Date
    var lastShowDate: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case djName = "dj_name"
        case playlistImageURL = "playlist_image_url"
        case showColor
        case startTime = "start_time"
        case endTime = "end_time"
        case DOTW = "current_dotw"
        case alternates
        case timezone
        case dates
        case firstShowDate = "first_show_date"
        case lastShowDate = "last_show_date"
    }
    
    // Custom initializer for manual creation of a Show instance with parameters
    init(id: String, name: String, djName: String, playlistImageURL: URL, startTime: TimeOfDay, endTime: TimeOfDay, alternates: Bool, timezone: TimeZone, DOTW: String, dates: [Date], firstShowDate: Date, lastShowDate: Date) {
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
        self.timezone = timezone
        self.playlistImageURL = playlistImageURL
    }
}

extension Show {
    var color: Color {
        Color(hex: showColor ?? "#000000")!
    }
}

func getShowDates(for show: Show) -> Set<DateComponents> {
    let calendar = Calendar.current
    let dates = Set(show.dates.map { calendar.dateComponents([.year, .month, .day], from: $0) })
    return dates
}
