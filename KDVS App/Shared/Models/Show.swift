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
        case dates
        case firstShowDate = "first_show_date"
        case lastShowDate = "last_show_date"
    }
    
    // Custom initializer for manual creation of a Show instance with parameters
    init(id: String, name: String, djName: String, playlistImageURL: URL, startTime: TimeOfDay, endTime: TimeOfDay, alternates: Bool, DOTW: String, dates: [Date], firstShowDate: Date, lastShowDate: Date) {
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
}

extension Show {
    var color: Color {
        Color(hex: showColor ?? "#000000")
    }
}

extension Show {
    static let empty = Show(
        id: "",
        name: "",
        djName: "",
        playlistImageURL: URL(string: "https://")!,
        startTime: TimeOfDay(hour: 0, minute: 0, second: 0),
        endTime: TimeOfDay(hour: 0, minute: 0, second: 0),
        alternates: false,
        DOTW: "",
        dates: [],
        firstShowDate: Date(),
        lastShowDate: Date()
    )
}
