//
//  MUCacheControl.swift
//  MUSwiftFramework
//
//  Created by Dmitry Smirnov on 03/03/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MUCacheControlProtocol

public protocol MUCacheControlProtocol {
    
    func setup(with controller: MUListController)
    
    func save()
    
    func load()
    
    func setCacheKey(with key: String?)
}

// MARK: - MUCacheControlManager

open class MUCacheControlManager {
    
    // MARK: - Public properties
    
    public static var instanceArray: [String: MUCacheControlProtocol] = [:]
    
    // MARK: - Public methods
    
    public static func get<T: MUCodable>(for model: T.Type) -> MUCacheControlProtocol {
        
        let key = "\(T.self)"
        
        if instanceArray[key] == nil  {
            
            instanceArray[key] = MUCacheControl<T>()
        }
        
        return instanceArray[key]!
    }
}

// MARK: - MUCacheControl

open class MUCacheControl<Model: MUCodable>: MUCacheControlProtocol {
    
    // MARK: - Public methods
    
    open weak var controller: MUListController?
    
    open var cacheKey: String?
    
    open var defaultKey: String { return controller?.className ?? "" }
    
    // MARK: - Public methods
    
    open func setup(with controller: MUListController) {
        
        guard controller.hasCache else { return }
        
        self.setCacheKey(with: controller.cacheKey)
        
        self.controller = controller
    }
    
    open func save() {
        
        guard let objects = controller?.objects as? [MUCodable] else { return }
        
        guard controller?.paginationControl.page == 1 else { return }
        
        MUCacheManager.cache(objects: objects, forKey: cacheKey ?? defaultKey)
    }
    
    open func load() {
        
        guard controller?.hasCache ?? false else { return }
        
        guard let objects = MUCacheManager.read(forKey: cacheKey ?? defaultKey, to: Model.self) as? [MUModel] else {
            
            return            
        }
        
        controller?.update(objects: objects)
    }
    
    open func setCacheKey(with key: String?) {
        
        cacheKey = key
    }
}
