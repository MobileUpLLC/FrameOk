//
//  MUModel.swift
//
//  Created by Dmitry Smirnov on 03/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import Foundation

// MARK: - MUModel

open class MUModel: NSObject {
    
    // MARK: - Public properties
    
    open var primaryKey: String { return defaultKey ?? "" }
    
    open var defaultKey: String?

    // MARK: Override methods

    open override func isEqual(_ object: Any?) -> Bool {

        if let item = object as? MUModel {

            return primaryKey == item.primaryKey
        } else {
            return false
        }
    }

    // MARK: - Public methods

    func updateBeforeEncode() { }

    func updateAfterDecode() { }
}

// MARK: - MUCodable

public protocol MUCodable: Codable {
    
    func updateBeforeEncode()
    
    func updateAfterDecode()
    
    static func updateBeforeParsing( rawData: inout [String : Any])
}

// MARK: - MUCodable

public extension MUCodable {

    // MARK: - Public methods

    static func updateBeforeParsing( rawData: inout [String : Any]) { }

    func updateBeforeEncode() { }

    func updateAfterDecode() { }
}
