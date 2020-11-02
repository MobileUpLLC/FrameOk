//
//  UILabel.swift

//
//  Created by Dmitry Smirnov on 26.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

public extension UILabel {
    
    var aText: String {
        
        set { setAText(newValue: newValue) }
        get { return text ?? "" }
    }
    
    func setAttributedText(color: UIColor) {
        
        attributedText = attributedText?.addAttribute(name: .foregroundColor, value: color)
    }
    
    // MARK: - Private methods
    
    private func setAText(newValue: String) {
        
        let newValue = newValue.replacingOccurrences(of: "\\n", with: "\n")
        
        if let newAttributedText = attributedText {
            
            let mutableAttributedText = newAttributedText.mutableCopy()
            
            (mutableAttributedText as AnyObject).mutableString.setString(newValue)
            
            attributedText = mutableAttributedText as? NSAttributedString
        }
    }
}
