//
//  MUReusableControllerProvaider.swift
//  
//
//  Created by Nikolai on 21.11.2019.
//  Copyright © 2019 MobileUp. All rights reserved.
//

import UIKit

// MARK: - MUReusableController

public protocol MUReusableController {
    
    func prepareForReuse()
    
    func setup(with object: MUModel?, sender: Any?)
}

// MARK: - MUReusableControllerProvaider

public protocol MUReusableControllerProvider: AnyObject {
    
    var unusedControllers: [String: Set<MUViewController>] { get set }
    
    var usedControllers: [String: [IndexPath: MUViewController]] { get set }
    
    var reusedControllerTypes: [String: MUViewController.Type] { get set }
}

public extension MUReusableControllerProvider {
    
    // MARK: - Private methods
    
    private func getController(withIdentifier id: String, for indexPath: IndexPath) -> MUViewController {
        
        if let controller = getUsedController(withIdentifier: id, for: indexPath) {
            
            return controller
            
        } else if let controller = popUnusedController(withIdentifier: id) {
            
            return controller
        
        } else {
            
            return initiateController(withIdentifier: id)
        }
    }
    
    private func popUnusedController(withIdentifier id: String) -> MUViewController? {
        
        return unusedControllers[id]?.popFirst()
    }
    
    private func initiateController(withIdentifier id: String) -> MUViewController {
        
        let type = getControllerClass(forIdentifier: id)
        
        guard let controller = type.getInstance() else {
            
            fatalError("Unable to initialize controller with class: \(type) for reuse identifier: \(id)")
        }
        
        return controller
    }
    
    private func getControllerClass(forIdentifier id: String) -> MUViewController.Type {
        
        guard let type = reusedControllerTypes[id] else {
            
            fatalError("Controller type for identifier: \(id) not found. Register controller class for controller reuse identifier")
        }
        
        return type
    }
    
    private func addToUsed(_ controller: MUViewController, withIdentifier id: String, for indexPath: IndexPath) {
        
        if usedControllers[id] != nil {
            
            usedControllers[id]?[indexPath] = controller
        } else {
            usedControllers[id] = [indexPath: controller]
        }
    }
    
    private func removeControllerFromUsed(withIdentifier id: String, for indexPath: IndexPath) {
        
        usedControllers[id]?[indexPath] = nil
    }
    
    private func addToUnused(_ controller: MUViewController, withIdentifier id: String) {
        
        if unusedControllers[id] != nil {
            
            unusedControllers[id]?.insert(controller)
        } else {
            unusedControllers[id] = [controller]
        }
    }
    
    // MARK: - Public methods
    
    func dequeueReusableController(withIdentifier id: String, for indexPath: IndexPath) -> MUViewController {
        
        let controller = getController(withIdentifier: id, for: indexPath)
        
        addToUsed(controller, withIdentifier: id, for: indexPath)
        
        return controller
    }
    
    func getUsedController(withIdentifier id: String, for indexPath: IndexPath) -> MUViewController? {
        
        guard let controllers = usedControllers[id] else {
            
            return nil
        }
        
        return controllers[indexPath]
    }
    
    func register(_ controllerClass: MUViewController.Type, forControllerReuseIdentifier id: String) {
        
        reusedControllerTypes[id] = controllerClass
    }
    
    func endUsingController(withIdentifier id: String, for indexPath: IndexPath) {
        
        guard let controller = usedControllers[id]?[indexPath] else {
            
            assertionFailure("Controller with identifier: \(id) for indexPath: \(indexPath) not found among visible controllers during ending controller use")
            
            return
        }
        
        removeControllerFromUsed(withIdentifier: id, for: indexPath)
        
        addToUnused(controller, withIdentifier: id)
    }
}
