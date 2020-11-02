//
//  Int.swift

//
//  Created by Dmitry Smirnov on 19.04.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

public extension Int {
    
    static func rand(min: Int, max: Int) -> Int {
        
        return Int(arc4random_uniform(UInt32(max - min + 1)) + UInt32(min))
    }
}
