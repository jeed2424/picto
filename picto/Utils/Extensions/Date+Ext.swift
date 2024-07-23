//
//  Date+Ext.swift
//  picto
//
//  Created by Jay on 2024-07-16.
//

import Foundation

extension Date {
    func toYearMonthDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: self)
        
        return dateString
    }
    
    func dateAndTimeToString() -> String {        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.string(from: self)
        
        return date
    }
    
}
 
extension String {
    func removeNumbersAfterPeriod() -> String {
        self.components(separatedBy: ".")[0]
    }
    
    func fromYearMonthDay() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let dateFromString = dateFormatter.date(from: self) {
            return dateFromString
        } else {
            return Date()
        }
    }
    
    func dateAndTimeFromString() -> Date {
        let string = self.removeNumbersAfterPeriod()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: string) ?? Date()
        
        return date
    }
    
    func localToUTC() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm:ss"
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeZone = TimeZone.current
        
        if let date = dateFormatter.date(from: self) {
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.dateFormat = "HH:mm:ss"
        
            return dateFormatter.string(from: date)
        }
        return nil
    }

    func utcToLocal() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: self) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "HH:mm:ss"
        
            return dateFormatter.string(from: date)
        }
        return nil
    }
}
