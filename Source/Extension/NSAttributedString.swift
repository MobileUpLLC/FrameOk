//
//  NSAttributedString.swift

//
//  Created by Dmitry Smirnov on 26.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

public extension NSAttributedString {
    
    func addAttribute(
        
        name            : NSAttributedString.Key,
        value           : Any,
        strings         : [String] = [],
        caseSensitivity : Bool = true
        
        ) -> NSMutableAttributedString {
        
        let attrs = NSMutableAttributedString(attributedString: self)
        
        if strings.count > 0 {
            
            let ranges = getRanges(of: strings, in: self.string, caseSensitivity: caseSensitivity)
            
            ranges.forEach { attrs.addAttribute(name, value: value, range: $0) }
            
        } else {
            
            attrs.addAttribute(name, value: value, range: NSRange(location: 0, length: attrs.length))
        }
        
        return attrs
    }
    
    func removeAttribute(name: NSAttributedString.Key) -> NSMutableAttributedString {
        
        let attrs = NSMutableAttributedString(attributedString: self)
        
        attrs.removeAttribute(name, range: NSRange(location: 0, length: attrs.length))
        
        return attrs
    }
    
    // MARK: - Private methods
    
    private func getRanges(of occurrencies: [String], in text: String, caseSensitivity: Bool = true) -> [NSRange] {
        
        var ranges: [NSRange] = []
        
        let text = caseSensitivity ? text : text.lowercased()
        
        for occurrence in occurrencies {
            
            let occurrence = caseSensitivity ? occurrence : occurrence.lowercased()
            
            var position = text.startIndex
            
            while let range = text.range(of: occurrence, range: position..<text.endIndex) {
                
                let location = text.distance(from: text.startIndex, to: range.lowerBound)
                
                ranges.append(NSRange(location: location, length: occurrence.count))
                
                let offset = occurrence.distance(from: occurrence.startIndex, to: occurrence.endIndex) - 1
                
                guard let after = text.index(range.lowerBound, offsetBy: offset, limitedBy: text.endIndex) else { break }
                
                position = text.index(after: after)
            }
        }
        
        return ranges
    }
    
    func addAttribute(name: NSAttributedString.Key, value: Any, string: String) -> NSMutableAttributedString {
        
        let attrs = NSMutableAttributedString(attributedString: self)
        
        let range = (self.string as NSString).range(of: string)
        
        attrs.addAttribute(name, value: value, range: range)
        
        return attrs
    }
    
    func addAttribute(name: NSAttributedString.Key, value: Any, strings: [String] = []) -> NSMutableAttributedString {
        
        let attrs = NSMutableAttributedString(attributedString: self)
        
        if strings.count > 0 {
            
            let ranges = getRanges(of: strings, in: self.string)
            
            ranges.forEach { attrs.addAttribute(name, value: value, range: $0) }
            
        } else {
            
            attrs.addAttribute(name, value: value, range: NSRange(location: 0, length: attrs.length))
        }
        
        return attrs
    }
    
    func addAttribute(name: NSAttributedString.Key, value: Any, from: Int, length: Int) -> NSMutableAttributedString {
        
        let attributedString = NSMutableAttributedString(attributedString: self)
        
        attributedString.addAttribute(name, value: value, range: NSRange(location: from, length: length))
        
        return attributedString
    }
    
    func setText(with text: String) -> NSAttributedString? {
        
        let mutableAttributedText = self.mutableCopy()
        
        (mutableAttributedText as AnyObject).mutableString.setString(text)
        
        return mutableAttributedText as? NSAttributedString
    }
    
    func setFont(for string: String, font: UIFont) -> NSAttributedString {
        
        let attributedString = NSMutableAttributedString(attributedString: self)
        
        let range = (attributedString.string as NSString).range(of: string)
        
        attributedString.addAttributes([NSAttributedString.Key.font: font], range: range)
        
        return attributedString
    }

    func getRange(of substring: String) -> NSRange? {

        getRanges(of: [substring], in: string).first
    }
    
    // MARK: - Private methods
    
    private func getRanges(of occurrencies: [String], in text: String) -> [NSRange] {
        
        var ranges: [NSRange] = []
        
        for occurrence in occurrencies {
            
            var position = text.startIndex
            
            while let range = text.range(of: occurrence, range: position..<text.endIndex) {
                
                let location = text.distance(from: text.startIndex, to: range.lowerBound)
                
                ranges.append(NSRange(location: location, length: occurrence.count))
                
                let offset = occurrence.distance(from: occurrence.startIndex, to: occurrence.endIndex) - 1
                
                guard let after = text.index(range.lowerBound, offsetBy: offset, limitedBy: text.endIndex) else { break }
                
                position = text.index(after: after)
            }
        }
        
        return ranges
    }
}
