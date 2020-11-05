//
//  String.swift

//
//  Created by Dmitry Smirnov on 27.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit
import PhoneNumberKit

// MARK: - String

public extension String {
    
    // MARK: - Public properties

    static var bundle: Bundle = Constants.bundle
    
    var localize: String { return String.bundle.localizedString(forKey: self, value: "", table: nil) }
    
    // MARK: - Public properties
    
    static var currentLocale: Locale = Locale.current
    
    static let ruLocale: Locale = .russian
    
    // MARK: - Private properties
    
    private static let dateFormatter1 = DateFormatter()
    
    private static let dateFormatter2 = DateFormatter()
    
    private static let numberFormatter = NumberFormatter()
    
    private static let numberFormatter2 = NumberFormatter()
    
    private static let phoneNumberFormatter = PhoneNumberKit()
    
    // MARK: - Public methods
    
    func format(to: NumberFormatter.Style) -> String {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = to
        
        return formatter.string(from: NSNumber(value: Int(self) ?? 0)) ?? "0"
    }
    
    static func format(
        
        time  : TimeInterval,
        style : DateComponentsFormatter.UnitsStyle = .positional,
        pad   : DateComponentsFormatter.ZeroFormattingBehavior = .pad,
        units : NSCalendar.Unit = [.hour, .minute, .second]
        
    ) -> String {
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = units
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: time) ?? ""
    }
    
    static func format(date: Date?, style: [DateFormatter.Style]) -> String {
        
        guard let date = date else { return "" }
        
        let dateFormatter = String.dateFormatter1
        dateFormatter.dateStyle = style[0]
        dateFormatter.timeStyle = style[1]
        
        return dateFormatter.string(from: date)
    }
    
    static func format(date: Date?, format: String = "d MMM, HH:mm", timeZone: TimeZone? = nil, serverFormat: Bool = false, locale: Locale = currentLocale) -> String {
        
        guard let date = date else { return "" }
        
        let dateFormatter = String.dateFormatter2
        
        var format = format
        
        dateFormatter.locale = locale
        
        if let formatter = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: locale), formatter.contains("a"), !serverFormat {
            
            format = format.replacingOccurrences(of: "HH", with: "h")
            
            if !format.contains("a") {
                
                format.append(" a")
            }
        }
        
        dateFormatter.dateFormat = format
        
        if let timeZone = timeZone {
            
            dateFormatter.timeZone = timeZone
        }
        
        return dateFormatter.string(from: date)
    }
    
    static func format(price: Double) -> String? {
        
        guard currentLocale == ruLocale else {
            
            return format(rub: price)
        }
        
        let formatter = numberFormatter2
        
        formatter.locale      = currentLocale
        formatter.numberStyle = .currency
        
        return formatter.string(from: NSNumber(value: price))
    }
    
    static func format(rub price: Double) -> String? {
        
        let formatter = numberFormatter2
        
        formatter.numberStyle    = .currency
        formatter.currencySymbol = "₽"
        
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: price))
    }
    
    static func format(eth value: Double, minMantissa: Int = 0, maxMantissa: Int = 4) -> String {
        
        numberFormatter.minimumFractionDigits = minMantissa
        numberFormatter.maximumFractionDigits = maxMantissa
        numberFormatter.minimumIntegerDigits  = 1
        
        numberFormatter.decimalSeparator = "."
        
        if value > 0 && value <= 0.01 {
            
            return String(format: "%@ FINNEY", numberFormatter.string(from: NSNumber(value: value * 1000)) ?? "0")
        } else {
            return String(format: "%@ ETH", numberFormatter.string(from: NSNumber(value: value)) ?? "0")
        }
    }
    
    static func format(number value: Double, minMantissa: Int = 0, maxMantissa: Int = 4, decimalSeparator: String = ".", bigMinus: Bool = false) -> String {
        
        numberFormatter.minimumFractionDigits = minMantissa
        numberFormatter.maximumFractionDigits = maxMantissa
        numberFormatter.minimumIntegerDigits  = 1
        
        numberFormatter.decimalSeparator = decimalSeparator
        
        if bigMinus {
            
            let numberString = numberFormatter.string(from: NSNumber(value: abs(value))) ?? "0"
            
            return value < 0 ? "–" + numberString : numberString
        } else {
            return numberFormatter.string(from: NSNumber(value: value)) ?? "0"
        }
    }
    
    static func format(phone: String) -> String {
        
        return PartialFormatter().formatPartial(phone)
    }
    
    static func format(phone: String, to type: PhoneNumberFormat, onlyNumbers: Bool = false) -> String? {
        
        guard let phoneNumber = try? phoneNumberFormatter.parse(phone) else { return nil }
        
        let phone = phoneNumberFormatter.format(phoneNumber, toType: type)
        
        if onlyNumbers {
            
            return phone.replace(pattern: "[^0-9]+", with: "")
        } else {
            return phone
        }
    }
    
    func onlyNumber() -> String {
        
        return replace(pattern: "[^0-9]+", with: "")
    }
    
    static var currentPhoneCoutryCode: String {
        
        return PhoneNumberKit().countryCode(for: Locale.current.languageCode ?? "")?.description ?? ""
    }
    
    static func randomStringFrom(array: [String], lowercased: Bool = false) -> String {
        
        let randomIndex = Int.rand(min: 0, max: array.count - 1)
        
        let randomLetter = array[randomIndex]
        
        return lowercased == true ? randomLetter.lowercased() : randomLetter
    }
    
    func toDictionary() -> [String: Any]? {
        
        guard let data = self.data(using: .utf8) else { return nil }
        
        do {
            
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
        } catch let error {
            
            Log.error("error: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func convertToDictionaty() -> [String: Any]? {
        
        guard
            
            let data = data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else { return nil }
        
        return json as? [String: Any]
    }    
    
    func replace(pattern: String, with replaceString: String = "") -> String {
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive) else {
            
            return self
        }
        
        let range = NSMakeRange(0, count)
        
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceString)
    }
    
    static func mask(template: String, value: String) -> String {
        
        var result = ""
        
        let templateArray = Array(template)
        
        var charArray = Array(value)
        
        for templateChar in templateArray {
            
            var resultChar = templateChar
            
            if templateChar == ".", let currentChar = charArray.first {
                
                resultChar = currentChar
                
                charArray.removeFirst()
            }
            
            result += "\(resultChar)"
        }
        
        return result
    }
    
    func matches(for regex: String) -> [String] {
        
        guard let regex = try? NSRegularExpression(pattern: regex) else { return [] }
        
        let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
        
        return results.map { String(self[Range($0.range, in: self)!]) }
    }
    
    static func check(value: String, regexp: String) -> Bool {
        
        return NSPredicate(format:"SELF MATCHES %@", regexp).evaluate(with: value)
    }
}

// MARK: - String

extension String {
    
    subscript (bounds: CountableClosedRange<Int>) -> String {
        
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        
        let end = index(startIndex, offsetBy: bounds.upperBound)
        
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        
        let end = index(startIndex, offsetBy: bounds.upperBound)
        
        return String(self[start..<end])
    }
}

// MARK: - Trimming

extension String {
    
    func substring(to: Int) -> String {
        
        guard count > to else { return self }
        
        return (self as NSString).substring(to: to)
    }
    
    func substring(last: Int) -> String {
        
        guard count > last else { return self }
        
        return (self as NSString).substring(from: count - last)
    }
    
    func whiteSpaceTrimmed() -> String {
        
        return trimmingCharacters(in: CharacterSet(charactersIn:" "))
    }
}
