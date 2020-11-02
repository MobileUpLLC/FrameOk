//
//  NotificationCenter.swift

//
//  Created by Dmitry Smirnov on 29.06.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Foundation

public extension NotificationCenter {
    
    // MARK: - Public methods
    
    class func addObserver(_ observer: Any, selector: Selector, name: NSNotification.Name?) {
        
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: nil)
    }

    class func addObserver(
        
        for observer : NSObject? = nil,
        forName name : NSNotification.Name,
        block        : @escaping ((Notification) -> Void)
        
    ) {
        
        NotificationCenter.default.addObserver(
            
            forName : name,
            object  : nil,
            queue   : nil,
            using   : { notification in
            
                block(notification)
            }
        )
    }
    
    class func post(forName name: NSNotification.Name, userInfo: [String: Any] = [:]) {
        
        NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
    }
}
