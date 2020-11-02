//
//  MUCacheManager.swift
//
//  Created by Dmitry Smirnov on 1/02/2019.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Foundation

// MARK: - MUCacheError

public enum MUCacheError: Error {
    
    case parsingError
    case unknownError
}

// MARK: - MUCacheManager

open class MUCacheManager: NSObject {
    
    // MARK: - Private methods
    
    private static var excludedKeysForNonCachingObjects: [String] = []
    
    static private var keysToCachedFilesArray: [String] {
        
        set { MUCacheManager.setKeysToCachedFiles(array: newValue) }
        get { return MUCacheManager.getAllKeysToCachedFiles() }
    }
    
    // MARK: - Public methods
    
    public class func addExcludedNonCachingObject(with key: String) {
        
        if !MUCacheManager.excludedKeysForNonCachingObjects.contains(key) {
            
            MUCacheManager.excludedKeysForNonCachingObjects.append(key)
        }
    }
    
    public class func cache(objects: [MUCodable], forKey key: String, failure: ((Error) -> Void)? = nil) {
        
        guard let encodedObjects = encode(objects: objects) else {
            
            failure?(MUCacheError.parsingError)
            return
        }
        
        guard NSKeyedArchiver.archiveRootObject(encodedObjects, toFile: getPath(forKey: key)) else {
            
            failure?(MUCacheError.unknownError)
            return
        }
        
        if !keysToCachedFilesArray.contains(key) && !MUCacheManager.excludedKeysForNonCachingObjects.contains(key) {
            
            keysToCachedFilesArray.append(key)
        }
    }
    
    public class func read<Object: MUCodable>(forKey key: String, to objectsType: Object.Type) -> [Object]? {
        
        guard let items = NSKeyedUnarchiver.unarchiveObject(withFile: getPath(forKey: key)) as? [[String: Any]]  else {
            
            return nil
        }
        
        guard let result = decode(items: items, to: objectsType) else {
            
            return nil
        }
        
        return result
    }
    
    public class func delete(forKey key: String) {
        
        let path = getPath(forKey: key)
        
        guard FileManager.default.fileExists(atPath: path) else { return }
        
        try? FileManager.default.removeItem(atPath: path)
    }
    
    public class func deleteAll() {
        
        for key in keysToCachedFilesArray {
            
            MUCacheManager.delete(forKey: key)
        }
        
        MUCacheManager.delete(forKey: String(describing: self))
    }
    
    // MARK: - Private methods
    
    class private func getPath(forKey key: String) -> String {
        
        return FileManager.getPath(to: key)
    }
    
    class private func encode(objects: [MUCodable]) -> [Any]? {
        
        var encodedObjects: [Any] = []
        
        for object in objects {
            
            guard let dictionary = object.dictionary else {
                
                return nil
            }
            
            encodedObjects.append(dictionary)
        }
        
        return encodedObjects
    }
    
    class private func decode<Object: MUCodable>(items: [[String: Any]], to objectsType: Object.Type) -> [Object]? {
        
        var result: [Object] = []
        
        for item in items {
            
            guard let decodedObject = MUSerializationManager.decode(item: item, to: objectsType) else { return nil }
            
            result.append(decodedObject)
        }
        
        return result
    }
    
    class private func getAllKeysToCachedFiles() -> [String] {
        
        let result = NSKeyedUnarchiver.unarchiveObject(withFile: getPath(forKey: String(describing: self)))
        
        return (result as? [String]) ?? []
    }
    
    class private func setKeysToCachedFiles(array: [String]) {
        
        NSKeyedArchiver.archiveRootObject(array, toFile: getPath(forKey: String(describing: self)))
    }
}

// MARK: - NSKeyedArchiver

public extension NSKeyedArchiver {
    
    class func archiveRootObject(with objects: Any, toFile filePath: String, completion: @escaping (Bool) -> Void) {
        
        DispatchQueue.global(qos: .utility).async {
            
            let result = NSKeyedArchiver.archiveRootObject(objects, toFile: filePath)
            
            DispatchQueue.main.async {
                
                completion(result)
            }
        }
    }
}
