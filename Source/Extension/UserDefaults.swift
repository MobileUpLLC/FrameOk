//
//  UserDefaults.swift

//
//  Created by Bodygin on 05/09/2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Foundation

public extension UserDefaults {
    
    struct Timeout {
        
        let timestamp: Date = Date()
        
        let interval: TimeInterval?
    }
    
    // MARK: - Private properties
    
    static private var timeoutByKeyList: [String: Timeout] = [:]
    
    // MARK: - Public methods
    
    class func set(_ value: Any?, forKey key: String, timeout: TimeInterval? = nil) {
        
        guard let value = value else {
            
            return UserDefaults.standard.removeObject(forKey: key)
        }
        
        UserDefaults.standard.set(value, forKey: key)
        
        UserDefaults.timeoutByKeyList[key] = Timeout(interval: timeout)
    }
    
    class func get(forKey key: String) -> Any? {
        
        guard
            
            let timeout = UserDefaults.timeoutByKeyList[key],
            
            let interval = timeout.interval,
            
            Date().timeIntervalSince(timeout.timestamp) > interval
        
        else {
            
            return UserDefaults.standard.object(forKey: key)
        }
        
        UserDefaults.timeoutByKeyList.removeValue(forKey: key)
        
        UserDefaults.standard.removeObject(forKey: key)
        
        return nil
    }
    
    class func clear() {
        
        if let appDomain = Bundle.main.bundleIdentifier {
            
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
    }
}
