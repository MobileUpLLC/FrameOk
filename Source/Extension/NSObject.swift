//
//  NSObject+ClassName.swift

//
//  Created by Maxim Aliev on 03/05/2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Foundation

public extension NSObject {
    
    var className: String {
        
        return description.components(separatedBy: ":").first ?? ""
    }
}
