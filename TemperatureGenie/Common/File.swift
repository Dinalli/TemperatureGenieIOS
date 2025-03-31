//
//  File.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 27/03/2025.
//

import Foundation

public extension String {
    /// returns the String as a Date given a date format
    func toDate( dateFormat format: String ) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: self)
    }
}

public extension Date {
    /// easy conversion of date to string with a format
    func toString( dateFormat format: String ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: self)
    }
}
