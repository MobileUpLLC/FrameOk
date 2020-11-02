//
//  UIWindow.swift

//
//  Created by Maxim Aliev on 10/09/2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

public extension UIWindow {
    
    var visibleViewController: UIViewController? {
        
        return UIWindow.getVisibleViewController(from: rootViewController)
    }
    
    static func getSafeAreaHeight() -> CGFloat {
        
        var safeAreaHeight: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            
            let window = UIApplication.shared.keyWindow
            
            safeAreaHeight = window?.safeAreaInsets.bottom ?? 0
        }
        
        return safeAreaHeight
    }
    
    // MARK: - Private methods
    
    private static func getVisibleViewController(from vc: UIViewController?) -> UIViewController? {
        
        if let navigationController = vc as? UINavigationController {
            
            return UIWindow.getVisibleViewController(from: navigationController.visibleViewController)
            
        } else if let tabBarController = vc as? UITabBarController {
            
            return UIWindow.getVisibleViewController(from: tabBarController.selectedViewController)
        } else {
            if let presentedViewController = vc?.presentedViewController {
                
                return UIWindow.getVisibleViewController(from: presentedViewController)
            } else {
                return vc
            }
        }
    }
}
