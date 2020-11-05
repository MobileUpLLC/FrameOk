//
//  MUBehaviorController.swift
//
//  Created by Dmitry Smirnov on 04/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MUBehaviorController

open class MUBehaviorController: NSObject {
    
    // MARK: - Public properties
    
    open var behaviorManager = MUBehaviorManager()
    
    // MARK: - Public methods
    
    open func check(behavior: String, processed: Bool = true) -> Bool {
        
        return behaviorManager.checkIsExist(with: behavior, asProcessed: processed)
    }
    
    open func checkIsNotRun(behavior: String) -> Bool {
        
        return behaviorManager.checkIsNotRun(with: [behavior])
    }
    
    open func checkIsNotRun(behaviors: [String]) -> Bool {
        
        return behaviorManager.checkIsNotRun(with: behaviors)
    }
    
    open func getNumberOfRuns(behavior: String) -> Int {
        
        return behaviorManager.getNumberOfRuns(withBehaviour: behavior)
    }
    
    open func waitFor(behavior: String, completion: @escaping () -> Void) {
        
        return behaviorManager.wait(for: behavior, completion: completion)
    }
    
    open func waitFor(behaviors: String, completion: @escaping () -> Void) {
        
        return behaviorManager.wait(for: behaviors, completion: completion)
    }
}
