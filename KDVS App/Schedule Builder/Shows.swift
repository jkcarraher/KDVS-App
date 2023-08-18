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
    var id = UUID()
    var name: String
    var djName: String?
    var showURL: URL?
    var playlistImageURL: URL?
    var showColor: Color?
    
    var alternatingType: Int? // 1 = show every week, 2 = show every 2 weeks...
    var alternatingPos: Int?
        
    var startTime: Date
    var endTime: Date
    
    var colSize: Int?
    var DOTW: String? //Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
    
    var showDates: [Date]
    var seasonStartDate: Date
    var seasonEndDate: Date
    
    enum CodingKeys: String, CodingKey {
            case name
            case showURL
            case playlistImageURL
            case showColor
            case alternatingType
            case alternatingPos
            case colSize
            case startTime
            case endTime
            case DOTW
            case showDates
            case seasonStartDate
            case seasonEndDate
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
