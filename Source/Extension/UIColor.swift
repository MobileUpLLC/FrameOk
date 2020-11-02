//
//  UIColor.swift

//
//  Created by Dmitry Smirnov on 09.04.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

public extension UIColor {
    
    convenience init(hex: String, alpha: Double? = nil) {
        
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        
        Scanner(string: hex).scanHexInt32(&int)
        
        let a, r, g, b: UInt32
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
        
        if let alpha = alpha {
            
            self.withAlphaComponent(CGFloat(alpha))
        }
    }
    
    func disableColor() -> UIColor {
        
        return self.withAlphaComponent(0.3)
    }
    
    func highlightedColor() -> UIColor {
        
        return self.withAlphaComponent(0.8)
    }
    
    class func errorColor() -> UIColor {
        
        return UIColor(hex: "FE2828")
    }
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        
        return adjust(by: abs(percentage) )
    }
    
    func darker(by percentage :CGFloat = 30.0) -> UIColor? {
        
        return adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        
        var red   : CGFloat = 0
        var green : CGFloat = 0
        var blue  : CGFloat = 0
        var alpha : CGFloat = 0
        
        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            
            return nil
        }
        
        return UIColor(
            red   : min(red + percentage / 100, 1.0),
            green : min(green + percentage / 100, 1.0),
            blue  : min(blue + percentage / 100, 1.0),
            alpha : alpha
        )
    }
}
