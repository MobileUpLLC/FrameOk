//
//  MUErrorManager.swift
//  MUSwiftFramework
//
//  Created by Dmitry Smirnov on 22/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MUErrorNotification

public struct MUErrorNotification {
    
    let error: Error
    
    let recipient: NSObject?
}

// MARK: - MUErrorNotification

public struct MUErrorClearNotification {
    
    let recipient: NSObject?
}

// MARK: - MUErrorManager

public class MUErrorManager: Error {
    
    // MARK: - Public properties
    
    public static weak var recipient: NSObject?
    
    // MARK: - Public methods
    
    public static func post(with error: Error, for recipient: NSObject? = nil) {
        
        let notification = MUErrorNotification(
            
            error     : error,
            recipient : recipient ?? MUErrorManager.recipient
        )
        
        NotificationCenter.default.post(name: .appErrorDidCome, object: nil, userInfo: [
            
            "error"        : error,
            "notification" : notification
        ])
    }
    
    public static func clear(for recipient: NSObject? = nil) {
        
        let notification = MUErrorClearNotification(
            
            recipient : recipient ?? MUErrorManager.recipient
        )
        
        NotificationCenter.default.post(name: .appErrorDidClear, object: nil, userInfo: [
            
            "notification" : notification
        ])
    }
}

// MARK: - Notification

public extension Notification.Name {
    
    static let appErrorDidCome = Notification.Name("appErrorDidCome")
    
    static let appErrorDidClear = Notification.Name("appErrorDidClear")
}
