//
//  DateExtensions.swift
//  KDVS
//
//  Created by John Carraher on 6/13/26.
//

import Foundation

extension Date {
    func dayOfWeek() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
}
