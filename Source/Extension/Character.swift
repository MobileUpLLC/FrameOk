//
//  Character.swift

//
//  Created by Dmitry Smirnov on 22.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Foundation

public extension Character {
    
    var code: Int {
        get {
            let s = String(self).unicodeScalars
            return Int(s[s.startIndex].value)
        }
    }
}
