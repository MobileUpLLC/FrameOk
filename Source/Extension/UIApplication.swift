//
//  UIApplication.swift

//
//  Created by Dmitry Smirnov on 10.04.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit
import SafariServices

public extension UIApplication {
    
    class func presentedViewController() -> UIViewController? {
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            
            while let presentedViewController = topController.presentedViewController {
                
                topController = presentedViewController
            }
            
            if let navigationController = topController as? UINavigationController {
                
                return navigationController.viewControllers.last
            }
            
            return topController
        }
        
        return nil
    }
    
    class func open(link: String) {
        
        guard let url = URL(string: link) else { return }
        
        if #available(iOS 10.0, *) {
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

    class func open(in controller: UIViewController, link: String) {

        guard let url = URL(string: link)
            else { return }

        let safaryController = SFSafariViewController(url: url)

        controller.present(safaryController, animated: true, completion: nil)
    }
}
