//
//  EnMUCodable.swift

//
//  Created by Dmitry Smirnov on 22.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Foundation

public extension MUCodable {
    
    var dictionary: [String: Any]? {
        
        let encoder = JSONEncoder()
        
        encoder.dateEncodingStrategy = .custom({ (date,encoder) in
            
            let dateString = Formatter.iso8601.string(from: date)
                
            var container = encoder.singleValueContainer()
            
            try? container.encode(dateString)
        })
        
        guard let data = try? encoder.encode(self) else { return nil }
        
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
