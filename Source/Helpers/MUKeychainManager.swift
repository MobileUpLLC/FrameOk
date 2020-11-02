//
//  MUKeychainManager.swift
//
//  Created by Dmitry Smirnov on 1/02/2019.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Foundation
import Security

// MARK: - MUKeychainManager

open class MUKeychainManager {
    
    public static let shared = MUKeychainManager()
    
    // MARK: - Public properties
    
    open var lastResultCode: OSStatus?
    
    open var accessGroup: String?
    
    open var synchronizable: Bool = false
    
    // MARK: - Public methods
    
    open func set(key: String, value: String) {
        
        delete(key: key)
        
        guard let data = value.data(using: String.Encoding.utf8) else { return }
        
        let query = getQuery(params: [
            
            kSecClass          : kSecClassGenericPassword,
            kSecAttrAccount    : key,
            kSecValueData      : data
        ])
        
        lastResultCode = SecItemAdd(query, nil)
    }
    
    open func get(key: String) -> String? {
        
        let query = getQuery(params: [
            
            kSecClass       : kSecClassGenericPassword,
            kSecAttrAccount : key,
            kSecReturnData  : kCFBooleanTrue!,
            kSecMatchLimit  : kSecMatchLimitOne
        ])
        
        var result: AnyObject?
        
        lastResultCode = withUnsafeMutablePointer(to: &result) {
            
            SecItemCopyMatching(query, UnsafeMutablePointer($0))
        }
        
        guard let data = result as? Data else {
            
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    open func delete(key: String) {
        
        let query = getQuery(params: [
            
            kSecClass       : kSecClassGenericPassword,
            kSecAttrAccount : key
        ])
        
        lastResultCode = SecItemDelete(query)
    }
    
    // MARK: - Private methods
    
    private func getQuery(params: [CFString : Any]) -> CFDictionary {
        
        var params = params
        
        if let group = accessGroup {
            
            params[kSecAttrAccessGroup] = group
        }
        
        if synchronizable {
            
            params[kSecAttrSynchronizable] = kSecAttrSynchronizableAny
        }
        
        return params as CFDictionary
    }
}
