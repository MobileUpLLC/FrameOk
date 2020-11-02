//
//  UIAlertController.swift

//
//  Created by Dmitry Smirnov on 06.06.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    func addAction(title: String, style: UIAlertAction.Style = .default, handler: (() -> Void)?) {
        
        let action = UIAlertAction(
            
            title   : title,
            style   : style,
            handler : { _ in handler?() }
        )
        
        addAction(action)
    }
}
