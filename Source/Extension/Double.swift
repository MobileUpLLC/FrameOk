//
//  Double.swift

//
//  Created by Maxim Aliev on 21/05/2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Foundation

public extension Double {
    
    func rounded(to places: Int) -> Double {
        
        let divisor = pow(10.0, Double(places))
        
        return (self * divisor).rounded() / divisor
    }
}
