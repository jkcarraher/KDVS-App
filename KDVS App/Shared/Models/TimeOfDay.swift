//
//  Time.swift
//  KDVS
//
//  Created by John Carraher on 6/6/26.
//

struct TimeOfDay {
    let hour: Int
    let minute: Int
    let second: Int
}

extension String {
    func toTimeOfDay() -> TimeOfDay? {
        let parts = self.split(separator: ":")

        guard parts.count == 3,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]),
              let second = Int(parts[2]),
              (0...23).contains(hour),
              (0...59).contains(minute),
              (0...59).contains(second)
        else {
            return nil
        }

        return TimeOfDay(
            hour: hour,
            minute: minute,
            second: second
        )
    }
}
