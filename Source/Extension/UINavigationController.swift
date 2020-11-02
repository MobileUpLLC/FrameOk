//
//  UINavigationController.swift

//
//  Created by Dmitry Smirnov on 28.04.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

public extension UINavigationController {
    
    func checkExists<T: UIViewController>(sameAs controller: T.Type) -> Bool {
        
        for controller in viewControllers {
            
            if controller.isKind(of: T.self) {
                
                return true
            }
        }
        
        return false
    }
    
    func checkExists(controller: UIViewController) -> Bool {
        
        return viewControllers.contains(controller)
    }
    
    func get<T: UIViewController>(sameAs controller: T.Type) -> UIViewController? {
        
        for controller in viewControllers {
            
            if controller.isKind(of: T.self) {
                
                return controller
            }
        }
        
        return nil
    }
    
    func insert(controller: UIViewController, at index: Int) {
        
        var viewControllers = self.viewControllers
        
        viewControllers.insert(controller, at: index)
        
        setViewControllers(viewControllers, animated: false)
    }
    
    func remove<T: UIViewController>(sameAs controller: T.Type) {
        
        var viewControllers = self.viewControllers
        
        for (index,controller) in viewControllers.enumerated() {
            
            if controller.isKind(of: T.self) {
                
                viewControllers.remove(at: index)
                
                setViewControllers(viewControllers, animated: false)
                
                return
            }
        }
    }
    
    func removeAll<T: UIViewController>(sameAs controller: T.Type) {
        
        var viewControllers: [UIViewController] = []
        
        for controller in self.viewControllers {
            
            if controller.isKind(of: T.self) == false {
                
                viewControllers.append(controller)
            }
        }
        
        setViewControllers(viewControllers, animated: false)
    }
    
    func remove(controller targetController: UIViewController) {
        
        var viewControllers = self.viewControllers
        
        for (index,controller) in viewControllers.enumerated() {
            
            if controller == targetController {
                
                viewControllers.remove(at: index)
                
                setViewControllers(viewControllers, animated: false)
                
                return
            }
        }
    }
    
    func pushViewController(_ instantiate: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        
        guard let completion = completion else {
            
            pushViewController(instantiate, animated: animated)
            
            return
        }
        
        CATransaction.begin()
        
        CATransaction.setCompletionBlock(completion)
        
        pushViewController(instantiate, animated: animated)
        
        CATransaction.commit()
    }
    
    func popViewController(animated: Bool, completion: (() -> Void)? = nil) {
        
        guard let completion = completion else {
            
            popViewController(animated: animated)

            return
        }
        
        CATransaction.begin()
        
        CATransaction.setCompletionBlock(completion)
        
        popViewController(animated: animated)
        
        CATransaction.commit()
    }
    
    func popToRootViewController(animated: Bool, completion: (() -> Void)? = nil) {
        
        guard let completion = completion else {
            
            popToRootViewController(animated: animated)
            
            return
        }
        
        CATransaction.begin()
        
        CATransaction.setCompletionBlock(completion)
        
        popToRootViewController(animated: animated)
        
        CATransaction.commit()
    }
    
    func popToViewController(with controller: UIViewController, completion: (() -> Void)? = nil) {
        
        CATransaction.begin()
        
        CATransaction.setCompletionBlock(completion)
        
        popToViewController(controller, animated: true)
        
        CATransaction.commit()
    }

    func getPrevious<T>(as type: T.Type) -> T? {

        guard let previousController = viewControllers[safe: viewControllers.count - 2] as? T else {

            return nil
        }

        return previousController
    }
}
