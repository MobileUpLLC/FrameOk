//
//  Dictionary.swift

//
//  Created by Dmitry Smirnov on 05.04.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Foundation

func += <K, V> (left: inout [K:V], right: [K:V]) {
    for (k, v) in right {
        left[k] = v
    }
}

public extension Dictionary {
    
    func convertNumberStringValuesToInt() -> Any {
        
        guard var result = self as? [String: Any] else { return self }
        
        for (key,value) in result {
            
            if let valueString = value as? String, let valueInt = Int(valueString) {
                
                result[key] = valueInt
                
                continue
            }
            
            if let valueArray = value as? [[String: Any]] {
                
                result[key] = valueArray.map( { $0.convertNumberStringValuesToInt() } )
                
                continue
            }
            
            if let valueDict = value as? [String: Any] {
                
                result[key] = valueDict.convertNumberStringValuesToInt()
                
                continue
            }
        }
        
        return result
    }
    
    func convertNumbersToString() -> Any {
        
        guard var result = self as? [String: Any] else { return self }
        
        for (key,value) in result {
            
            if let valueString = value as? String {
                
                result[key] = valueString
                
                continue
            }
            
            if let valueArray = value as? [[String: Any]] {
                
                result[key] = valueArray.map( { $0.convertNumberStringValuesToInt() } )
                
                continue
            }
            
            if let valueDict = value as? [String: Any] {
                
                result[key] = valueDict.convertNumberStringValuesToInt()
                
                continue
            }
        }
        
        return result
    }
}
