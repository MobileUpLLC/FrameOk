//
//  Formatter.swift

//
//  Created by Dmitry Smirnov on 24.05.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Foundation

public extension Formatter {
    
    static let zeroDate: Date = Formatter.iso8601.date(from: "1970-01-01T00:00:00+0000")!
    
    static let iso8601: DateFormatter = {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        return dateFormatter
    }()
}
