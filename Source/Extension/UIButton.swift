//
//  UIButton.swift

//
//  Created by Dmitry Smirnov on 26.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

public extension UIButton {
    
    @IBInspectable var imageAlignRight: Bool {
        set { semanticContentAttribute = .forceRightToLeft }
        get { return semanticContentAttribute == .forceRightToLeft }
    }
    
    func setAttributedTitle(color: UIColor?, for state: UIControl.State) {
        
        guard let color = color else { return }
        
        let attributedText = attributedTitle(for: state)?.addAttribute(name: .foregroundColor, value: color)
        
        setAttributedTitle(attributedText, for: state)
    }
    
    func setAttributedTitle(font: UIFont?, for state: UIControl.State) {
        
        guard let font = font else { return }
        
        let attributedText = attributedTitle(for: state)?.addAttribute(name: .font, value: font)
        
        setAttributedTitle(attributedText, for: state)
    }
    
    func setAttributedTitle(text: String, for state: UIControl.State) {
        
        if let attributedText = attributedTitle(for: state) {
            
            let mutableAttributedText = attributedText.mutableCopy()
            
            (mutableAttributedText as AnyObject).mutableString.setString(text)
            
            setAttributedTitle((mutableAttributedText as! NSAttributedString), for: state)
        }
    }
    
    func setAttributedTitle(text: String, forAll: Bool) {
        
        guard forAll else {
            
            setAttributedTitle(text: text, for: .normal)
            return
        }
        
        setAttributedTitle(text: text, for: .normal)
        setAttributedTitle(text: text, for: .disabled)
        setAttributedTitle(text: text, for: .highlighted)
    }
}
