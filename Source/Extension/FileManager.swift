//
//  FileManager.swift

//
//  Created by Dmitry Smirnov on 22.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Foundation

public extension FileManager {
    
    class var documentDirectory: String { return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] }
    
    class func getPath(to file: String) -> String {
        
        return getPath(to: file, from: documentDirectory)
    }
    
    class func getPath(to file: String, from path: String) -> String {
        
        return (path as NSString).appendingPathComponent(file)
    }
    
    class func getPathFromBundle(to file: String) -> String {
        
        var components    = file.components(separatedBy : ".")
        let fileExtension = components.popLast()
        
        let path = Bundle.main.path(forResource: components.joined(separator: "."), ofType: fileExtension)
        
        return (path != nil) ? path! : ""
    }
}
