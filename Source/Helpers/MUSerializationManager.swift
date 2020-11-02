//
//  MUSerializationManager.swift
//
//  Created by Dmitry Smirnov on 1/02/2019.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Foundation

// MARK: - MUSerializationManager

open class MUSerializationManager {
    
    // MARK: - Public methods
    
    public class func encode(object: MUCodable) -> Any? {
        
        object.updateBeforeEncode()
        
        guard let dictionary = object.dictionary else {
            
            return nil
        }
        
        return dictionary
    }
    
    public class func decode<Object: MUCodable>(
        item                 : [String: Any],
        to objectType        : Object.Type,
        dateDecodingStrategy : JSONDecoder.DateDecodingStrategy?  = nil
    ) -> Object? {
        
        var item = item
        
        Object.updateBeforeParsing(rawData: &item)
        
        guard let objectData = getData(from: item) else {
            
            return nil
        }
        
        do {
            
            let decoder = JSONDecoder()

            if let strategy = dateDecodingStrategy {

                decoder.dateDecodingStrategy = strategy

            } else {

                decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in

                    let container  = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)

                    let date = Formatter.iso8601.date(from: dateString)

                    return date ?? Formatter.zeroDate
                })
            }
            
            let object = try decoder.decode(objectType, from: objectData)
            
            object.updateAfterDecode()
            
            return object
            
        } catch let error {
            
            Log.error("error: \(error) \n \(item)")
        }
        
        return nil
    }
    
    public class func copy<Object: MUCodable>(object: MUCodable, to objectType: Object.Type) -> Object? {
        
        guard let copy = encode(object: object) as? [String : Any] else {
            
            return nil
        }
        
        return decode(item: copy, to: Object.self)
    }
    
    // MARK: - Private methods
    
    private class func getData(from dictionary: [String: Any]) -> Data? {
        
        do {
            
            return try JSONSerialization.data(withJSONObject: dictionary)
            
        } catch let error {
            
            Log.error("error: \(error)")
        }
        
        return nil
    }
}
// MARK: -  JSONValue

public enum JSONValue: Codable {
    
    case string(String)
    
    case int(Int)
    
    case double(Double)
    
    case bool(Bool)
    
    case object([String: JSONValue])
    
    case array([JSONValue])
    
    // MARK: - Public methods
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        
        self = try ((try? container.decode(String.self)).map(JSONValue.string))
            .or((try? container.decode(Int.self)).map(JSONValue.int))
            .or((try? container.decode(Double.self)).map(JSONValue.double))
            .or((try? container.decode(Bool.self)).map(JSONValue.bool))
            .or((try? container.decode([String: JSONValue].self)).map(JSONValue.object))
            .or((try? container.decode([JSONValue].self)).map(JSONValue.array))
            .resolve(with: DecodingError.typeMismatch(JSONValue.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "")))
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let string) : try container.encode(string)
        case .int(let int)       : try container.encode(int)
        case .double(let double) : try container.encode(double)
        case .bool(let bool)     : try container.encode(bool)
        case .object(let object) : try container.encode(object)
        case .array(let array)   : try container.encode(array)
        }
    }
}

// MARK: - Optional

public extension Optional {
    
    func or(_ other: Optional) -> Optional {
        
        switch self {
        case .none: return other
        case .some: return self
        }
    }
    
    func resolve(with error: @autoclosure () -> Error) throws -> Wrapped {
        
        switch self {
            
        case .none: throw error()
        case .some(let wrapped): return wrapped
        }
    }
}
