//
//  MUBehaviorManager.swift
//
//  Created by Dmitry Smirnov on 04/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MUBehaviorManager

open class MUBehaviorManager: NSObject {
    
    // MARK: - Public properties
    
    open var options: [String] = []
    
    // MARK: - Private properties
    
    private var numberOfRuns: [String: Int] = [:] { didSet { runWaitingOptions() } }
    
    private var waitingOptions: [String: (() -> Void)] = [:]
    
    // MARK: - Public methods
    
    open func checkIsExist(with option: String, asProcessed: Bool) -> Bool {
        
        guard options.contains(option) else { return false }
        
        if asProcessed {
            
            run(with: option)
        }
        
        return true
    }
    
    open func run(with behaviour: String) {
    
        numberOfRuns[behaviour] = numberOfRuns[behaviour] ?? 0 + 1
    }
    
    open func checkIsNotRun(with options: [String]) -> Bool {
        
        for option in options {
            
            if numberOfRuns[option] ?? 0 > 0 {
                
                return true
            }
        }
        
        return false
    }
    
    open func getNumberOfRuns(withBehaviour option: String) -> Int {
        
        return numberOfRuns[option] ?? 0
    }
    
    open func wait(for option: String, completion: @escaping () -> Void) {
        
        waitingOptions[option] = completion
    }
    
    open func wait(for options: [String], completion: @escaping () -> Void) {
        
        for option in options {
            
            waitingOptions[option] = { [weak self] in
                
                self?.waitForOtherOptions(with: options) {
                    
                    completion()
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    private func runWaitingOptions() {
        
        let waitingOptions = self.waitingOptions
        
        for (option,completion) in waitingOptions {
            
            if numberOfRuns[option] ?? 0 > 0 {
                
                completion()
                
                self.waitingOptions.removeValue(forKey: option)
            }
        }
    }
    
    private func waitForOtherOptions(with options: [String], completion: @escaping () -> Void) {
        
        var isAllProcessed = true
        
        for option in options {
            
            if numberOfRuns[option] ?? 0 == 0 {
                
                isAllProcessed = false
            }
        }
        
        if isAllProcessed {
            
            completion()
        }
    }
}
