//
//  DispatchQueue+Once.swift
//  MUSwiftFramework
//
//  Created by Maxim Aliev on 2/22/19
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import Foundation

public extension DispatchQueue {

    private static var _onceTracker = [String]()

    /**
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    class func once(token: String, block: () -> Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }

        if _onceTracker.contains(token) {
            return
        }

        _onceTracker.append(token)
        block()
    }
}
