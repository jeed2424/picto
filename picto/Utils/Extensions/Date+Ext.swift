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
}
