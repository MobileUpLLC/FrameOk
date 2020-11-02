//
//  Date.swift
//  
//
//  Created by IF on 21/08/2019.
//  Copyright © 2019 MobileUp. All rights reserved.
//

import Foundation

// MARK: - Date

public extension Date {
    
    static let defaultCalendar = Calendar(identifier: .gregorian)
    
    static var currentYear: Int { return Calendar.current.component(.year, from: Date()) }
    
    // MARK: - Public methods
    
    static func format(string: String, format: String) -> Date? {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = format
        
        return formatter.date(from: string)
    }
    
    static func interval(components: Set<Calendar.Component>, from startDate: Date, to endDate: Date) -> DateComponents {
        
        return Date.defaultCalendar.dateComponents(components, from: startDate, to: endDate)
    }
    
    func humanize(format: String) -> String {
        
        let days = Date.interval(components: [.day], from: self, to: Date()).day ?? 0
        
        switch days {
        case 0  : return "Сегодня".localize
        case 1  : return "Вчера".localize
        default : return String.format(date: self, format: format)
        }
    }
    
    func getMonth() -> String {
        
        let month = Calendar.current.component(.month, from: self)
        
        return Date.getMonthName(with: month)
    }
    
    static func getMonthName(with month: Int) -> String {
        
        switch month {
        case 1  : return "Январь".localize
        case 2  : return "Февраль".localize
        case 3  : return "Март".localize
        case 4  : return "Апрель".localize
        case 5  : return "Май".localize
        case 6  : return "Июнь".localize
        case 7  : return "Июль".localize
        case 8  : return "Август".localize
        case 9  : return "Сентябрь".localize
        case 10 : return "Октябрь".localize
        case 11 : return "Ноябрь".localize
        case 12 : return "Декабрь".localize
        default : return ""
        }
    }
    
    static func days(from fromDate: Date, to toDate: Date) -> [Date] {
        
        var dates: [Date] = []
        
        var date = fromDate
        
        while date <= toDate {
            
            dates.append(date)
            
            guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            
            date = newDate
        }
        
        return dates
    }
    
    static func months(from fromDate: Date, to toDate: Date) -> [Date] {
        
        var dates: [Date] = []
        
        var date = fromDate
        
        while date <= toDate {
            
            dates.append(date)
            
            guard let newDate = Calendar.current.date(byAdding: .month, value: 1, to: date) else { break }
            
            date = newDate
        }
        
        return dates
    }
}
