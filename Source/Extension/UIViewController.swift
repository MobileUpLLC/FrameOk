//
//  UIViewController.swift

//
//  Created by Dmitry Smirnov on 09.06.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    func removeFromParentAndSuperview() {
        
        willMove(toParent: nil)
        
        view.removeFromSuperview()
        
        removeFromParent()
    }
    
    func isPresented() -> Bool {
        
        guard let lastController = navigationController?.children.last else {
            
            return false
        }
        
        return lastController == self || lastController == parent
    }
    
    func getTopSafeAreaHeight() -> CGFloat {
        
        var topSafeArea: CGFloat
        
        if #available(iOS 11.0, *) {
            
            topSafeArea = view.safeAreaInsets.top
        } else {
            topSafeArea = topLayoutGuide.length
        }
        
        return topSafeArea
    }
    
    func getBottomSafeAreaHeight() -> CGFloat {
        
        var bottomSafeArea: CGFloat
        
        if #available(iOS 11.0, *) {
            
            bottomSafeArea = view.safeAreaInsets.bottom
        } else {
            bottomSafeArea = bottomLayoutGuide.length
        }
        
        return bottomSafeArea
    }
}
