//
//  ApiCore.swift
//
//  Created by Dmitry Smirnov on 22.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Foundation

// MARK: - MURemoteDataManagerDelegate

public protocol MURemoteDataManagerDelegate: class {
    
    func remoteDataManagerDidFailure(error: Error)
    func remoteDataManagerDidTryAgainWithSuccess(result: Any)
}

// MARK: - MUTransferError

public enum MUTransferError: Error {
    
    case parsingError
    case unknownError
}

// MARK: - MUDataTransferManager

open class MUDataTransferManager: NSObject {
    
    // MARK: - Public properties
    
    open weak var delegate: MURemoteDataManagerDelegate?
    
    open  var networkManager: MUNetworkManager?
    
    open var token: String?
    
    // MARK: - Private properties
    
    private var failureRequests: [MUNetworkRequest] = []
    
    // MARK: - Public
    
    open func getObjects<T: MUCodable>(
        
        from url            : String,
        method              : MUNetworkHttpMethod? = nil,
        to                  : T.Type,
        headers             : [String: String]? = nil,
        params              : [String: Any]? = nil,
        body                : Any? = nil,
        encoding            : MUNetworkEncoding = .url,
        beforeParsing       : ((Any) -> Any)? = nil,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil,
        success             : (([T]) -> Void)? = nil,
        failure             : ((Error?) -> Void)? = nil
        
    ) {
        
        request(url: url, method: method, headers: headers, parameters: params, body: body, encoding: encoding, success: { result in
            
            var result: Any = result
            
            if let beforeParsing = beforeParsing {
                
                result = beforeParsing(result)
            }
            
            var items: [T]? = nil
            
            DispatchQueue.global().async { [weak self] in
                
                let data = self?.prepareData(
                    data                 : result,
                    to                   : T.self,
                    dateDecodingStrategy : dateDecodingStrategy
                )
                
                DispatchQueue.main.async {
                    
                    if let dataError = data as? Error {
                        
                        self?.returnError(with: dataError, failure: failure)
                        
                        return
                    }
                    
                    if let item = data as? T {
                        
                        items = [item]
                    }
                        
                    else if let data = data as? [T] {
                        
                        items = data
                    }
                    
                    let objects = items ?? []
                    
                    success?(objects)
                }
            }
            
        }, failure: failure)
    }
    
    open func getObject<T: MUCodable>(
        
        from url            : String,
        method              : MUNetworkHttpMethod? = nil,
        to                  : T.Type,
        headers             : [String: String]? = nil,
        params              : [String: Any]? = nil,
        body                : Any? = nil,
        encoding            : MUNetworkEncoding = .url,
        beforeParsing       : ((Any) -> Any)? = nil,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil,
        success             : ((T) -> Void)? = nil,
        failure             : ((Error?) -> Void)? = nil

    ) {
        
        getObjects(
            
            from                 : url,
            method               : method,
            to                   : T.self,
            headers              : headers,
            params               : params,
            body                 : body,
            encoding             : encoding,
            beforeParsing        : beforeParsing,
            dateDecodingStrategy : dateDecodingStrategy,

            success : { objects in
            
                guard let object = objects.first else { return }
                
                success?(object)                
            },
            
            failure : failure
        )
    }
    
    open func getValue(
        
        from url : String,
        method   : MUNetworkHttpMethod? = nil,
        headers  : [String: String]? = nil,
        params   : [String: Any]? = nil,
        body     : Any? = nil,
        success  : ((String) -> Void)? = nil,
        failure  : ((Error?) -> Void)? = nil
        
    ) {
        
        request(url: url, method: method, headers: headers, parameters: params, body: body, success: { [weak self] (data) in
            
            guard let valueString = data as? String else {
                
                self?.returnError(with: MUTransferError.parsingError, failure: failure)
                
                return
            }
            
            success?(valueString)
            
        }, failure: failure)
    }
    
    open func request(
        
        url        : String,
        method     : MUNetworkHttpMethod? = nil,
        headers    : [String: String]? = nil,
        parameters : [String: Any]? = nil,
        body       : Any? = nil,
        encoding   : MUNetworkEncoding = .url,
        success    : ((Any) -> Void)? = nil,
        failure    : ((Error?) -> Void)? = nil
        
    ) {
        
        let defaultMethod: MUNetworkHttpMethod = parameters == nil ? .get : .post
        
        let request = MUNetworkRequest(
            
            url      : url,
            method   : method ?? defaultMethod,
            headers  : headers,
            params   : parameters,
            body     : body,
            encoding : encoding,
            success  : success,
            failure  : failure
        )
        
        let recipient = MUErrorManager.recipient
        
        networkManager?.request(
            
            url        : url,
            method     : method ?? defaultMethod,
            parameters : parameters,
            body       : body,
            encoding   : encoding,
            headers    : headers ?? getHeaders(),
            
            success    : { [weak self] (result) in
                
                self?.removeSameFailureRequest(with: request)
                
                self?.handlerResponse(result: result, request: request, success: success, failure: failure)
            },
            
            failure: { [weak self] (error,result) in
                
                switch error {
                case .connectionError?, .serverError? : self?.addFailureRequest(with: request)
                default                               : break
                }
                
                self?.handleFailure(result: result, error: error, request: request, recipient: recipient, completion: failure)
            }
        )
    }
    
    open func getHeaders() -> [String: String] {
        
        var headers: [String: String] = [:]
        
        if let token = token {
            
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return headers
    }
    
    open func tryAgainFailureRequests() {
        
        guard failureRequests.count > 0 else {
            
            delegate?.remoteDataManagerDidFailure(error: MUTransferError.unknownError)
            
            return
        }
        
        let requests = failureRequests
        
        failureRequests.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) { [weak self] in
            
            for failRequest in requests {
                
                self?.request(
                    
                    url        : failRequest.url,
                    method     : failRequest.method,
                    headers    : failRequest.headers,
                    parameters : failRequest.params,
                    body       : failRequest.body,
                    encoding   : failRequest.encoding,
                    
                    success    : { [weak self] (result) in
                        
                        failRequest.success?(result)
                        
                        self?.delegate?.remoteDataManagerDidTryAgainWithSuccess(result: failRequest)
                    },
                    
                    failure    : failRequest.failure
                )
            }
        }
    }
    
    @available(*, deprecated, message: "Use handlerResponse method with request parameter")
    open func handlerResponse(
        
        result    : Any,
        recipient : NSObject? = nil,
        success   : ((Any) -> Void)?     = nil,
        failure   : ((Error?) -> Void)?  = nil
        
    ) {

    }
    
    open func handlerResponse(
        
        result    : Any,
        request   : MUNetworkRequest?,
        recipient : NSObject? = nil,
        success   : ((Any) -> Void)?     = nil,
        failure   : ((Error?) -> Void)?  = nil
    ) {
        
    }
    
    open func handleFailure(result: Any?, error: MUNetworkError?, request: MUNetworkRequest?, recipient: NSObject?, completion : ((Error?) -> Void)? = nil) {
        
        returnError(with: error, recipient: recipient, failure: completion)
    }
    
    open func prepareData<Object: MUCodable>(
        data                 : Any,
        to                   : Object.Type,
        dateDecodingStrategy : JSONDecoder.DateDecodingStrategy?
    ) -> Any? {
        
        if let item = data as? [String: Any] {

            guard let object = MUSerializationManager.decode(
                item                 : item,
                to                   : Object.self,
                dateDecodingStrategy : dateDecodingStrategy
            ) else {
                
                return MUTransferError.parsingError
            }

            return object
        }

        if let items = data as? [[String: Any]] {

            var resultArray: [Any] = []

            for item in items {

                guard let object = MUSerializationManager.decode(item: item, to: Object.self) else {
                    
                    return MUTransferError.parsingError
                }

                resultArray.append(object)
            }

            return resultArray
        }

        if let items = data as? [String: [String: Any]] {

            var resultArray: [Any] = []

            for (_, item) in items {

                guard let object = MUSerializationManager.decode(item: item, to: Object.self) else {
                    
                    return MUTransferError.parsingError
                }

                resultArray.append(object)
            }

            return resultArray
        }

        return nil
    }
    
    open func cancelAllRequests() {
        
        networkManager?.cancelAllRequests()
    }
    
    open func cancelDataTask(with url: String) {
        
        networkManager?.cancelDataTask(with: url)
    }
    
    open func returnError(with error: Error?, recipient: NSObject? = nil, failure: ((Error?) -> Void)? = nil) {
        
        if let failure = failure {
            
            return failure(error)
        }
        
        MUErrorManager.post(with: error ?? MUTransferError.unknownError, for: recipient)
    }
    
    open func addFailureRequest(with request: MUNetworkRequest) {
        
        failureRequests.append(request)
    }
    
    open func removeSameFailureRequest(with request: MUNetworkRequest) {
        
        if let index = failureRequests.firstIndex(where: { $0.method == request.method } )  {
            
            failureRequests.remove(at: index)
        }
    }
}
