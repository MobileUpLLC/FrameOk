//
//  DevelopToolsManager.swift
//  
//
//  Created by IF on 30/07/2019.
//  Copyright © 2019 MobileUp. All rights reserved.
//

import UIKit

// MARK: - MUDeveloperToolsManager

open class MUDeveloperToolsManager: NSObject {
    
    // MARK: - Public properties

    public static weak var delegate: MUDeveloperToolsDelegate?

    public static weak var customActionDelegate: MUDeveloperToolsCustomActionDelegate?
    
    public class var alwaysReturnConnectionError: Bool {
        
        set { UserDefaults.set(newValue, forKey: .alwaysReturnConnectionError) }
        get { return UserDefaults.get(forKey: .alwaysReturnConnectionError) as? Bool ?? false }
    }
    
    public class var alwaysReturnServerError: Bool {
        
        set { UserDefaults.set(newValue, forKey: .alwaysReturnServerError) }
        get { return UserDefaults.get(forKey: .alwaysReturnServerError) as? Bool ?? false }
    }
    
    public class var shouldSimulateBadConnection: Bool {
        
        set { UserDefaults.set(newValue, forKey: .shouldSimulateBadConnection) }
        get { return UserDefaults.get(forKey: .shouldSimulateBadConnection) as? Bool ?? false }
    }
    
    public class var shouldAutoCompleteForms: Bool {
        
        set { UserDefaults.set(newValue, forKey: .shouldAutoCompleteForms) }
        get { return UserDefaults.get(forKey: .shouldAutoCompleteForms) as? Bool ?? false }
    }
    
    public class var shouldShowWebLogs: Bool {
        
        set { UserDefaults.set(newValue, forKey: .shouldShowWebLogs) }
        get { return UserDefaults.get(forKey: .shouldShowWebLogs) as? Bool ?? false }
    }
}

// MARK: - Notification

public extension Notification.Name {
    
    static let deviceHaveBeenShaken = Notification.Name("deviceHaveBeenShaken")
}

// MARK: - UserDefaults

public extension String {
    
    static let alwaysReturnConnectionError = "alwaysReturnConnectionError"
    
    static let alwaysReturnServerError = "alwaysReturnServerError"
    
    static let shouldSimulateBadConnection = "shouldSimulateBadConnection"
    
    static let shouldAutoCompleteForms = "shouldAutoCompleteForms"
    
    static let shouldShowWebLogs = "shouldShowWebLogs"
}
