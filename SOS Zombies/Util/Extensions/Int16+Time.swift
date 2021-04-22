//
//  Int16+Time.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 22/4/21.
//

import Foundation

extension Int16 {
    
    var userFriendlyTime: String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.numberStyle = .decimal
        let day: Double = 60 * 24
        let hour: Double = 60
        let time = Double(self)
        if time > day {
            let days = time / day
            let formattedDays = formatter.string(from: NSNumber(value: days)) ?? ""
            return String(format: "%@ %@", formattedDays, NSLocalizedString("general.days", comment: ""))
        } else if time > hour {
            let hours = time / hour
            let formattedHours = formatter.string(from: NSNumber(value: hours)) ?? ""
            return String(format: "%@ %@", formattedHours, NSLocalizedString("general.hours", comment: ""))
        } else {
            return String(format: "%d %@", self, NSLocalizedString("general.minutes", comment: ""))
        }
    }
}
