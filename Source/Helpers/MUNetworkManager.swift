//
//  MUNetworkManager.swift
//
//  Created by Dmitry Smirnov on 1/02/2019.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireNetworkActivityIndicator
import AlamofireNetworkActivityLogger

// MARK: - MUNetworkError

public enum MUNetworkError: Error {
    
    case connectionError
    case serverError
    case unknownError
    case parsingError
    case httpError(Int)
}

// MARK: - MUNetworkConfiguration

private struct MUNetworkConfiguration {
    
    static let timeoutForRequestInSecods: TimeInterval = 15
    
    static let timeoutForResourceInSecods: TimeInterval = 300
}

// MARK: - MUNetworkManager

open class MUNetworkManager: NSObject {
    
    open var serverUrl: String?
    
    // MARK: - Private properties
    
    private let sessionManager: Alamofire.SessionManager!
    
    private let reachabilityManager = Alamofire.NetworkReachabilityManager()!
    
    private var numberOfRequests = 0
    
    // MARK: - Override methods
    
    public init(serverTrustPolicies: [String: MUServerTrustPolicy]? = nil) {

        let configuration = URLSessionConfiguration.default
        
        configuration.timeoutIntervalForRequest = MUNetworkConfiguration.timeoutForRequestInSecods
        
        configuration.timeoutIntervalForResource = MUNetworkConfiguration.timeoutForResourceInSecods

        var policyManager: ServerTrustPolicyManager? = nil

        if let policies = serverTrustPolicies {

            let convertedPolicies = policies.mapValues { MUNetworkManager.convertServerTrustPolicy($0) }

            policyManager = ServerTrustPolicyManager(policies: convertedPolicies)
        }

        sessionManager = Alamofire.SessionManager(
            configuration            : configuration,
            serverTrustPolicyManager : policyManager
        )
        
        NetworkActivityIndicatorManager.shared.isEnabled = true

        NetworkActivityLogger.shared.level = .debug

        NetworkActivityLogger.shared.startLogging()

        super.init()
    }
    
    public convenience init(serverUrl: String, serverTrustPolicies: [String: MUServerTrustPolicy]? = nil) {
        
        self.init(serverTrustPolicies: serverTrustPolicies)
        
        self.serverUrl = serverUrl
    }
    
    // MARK: - Public methods
    
    open func request (
        
        url        : String,
        method     : MUNetworkHttpMethod,
        parameters : [String: Any]? = nil,
        body       : Any? = nil,
        encoding   : MUNetworkEncoding = .url,
        headers    : [String: String] = [:],
        queue      : DispatchQueue?  = nil,
        success    : @escaping (Any) -> Void,
        failure    : @escaping (MUNetworkError?,Any?) -> Void
        )
        
    {
        
        let requestId = getRequestId()
        
        guard returnErrorIfDeveloperModeIsOn(failure: failure) == false else { return }
        
        guard let serverUrl = serverUrl else {
            
            failure(MUNetworkError.serverError, nil)
            
            return Log.error("error: server url is nil")
        }
        
        let requestUrl = serverUrl + url
        
        guard let method: HTTPMethod = HTTPMethod.init(rawValue: method.rawValue) else { return }
        
        sessionManager
            
            .request(
                
                requestUrl,
                method     : method,
                parameters : parameters,
                encoding   : convertEncoding(with: encoding, body: body),
                headers    : headers
            )
            
            .responseJSON(queue: queue) { [weak self] (responseObject) -> Void in
                
                self?.simulateBadConnectionIfNeeded {
                
                    self?.responseHandler(
                        
                        requestUrl     : requestUrl,
                        requestId      : requestId,
                        responseObject : responseObject,
                        success        : success,
                        failure        : failure
                    )
                }
        }
    }
    
    open func cancelAllRequests() {
        
        sessionManager.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach      { $0.cancel() }
            downloadData.forEach    { $0.cancel() }
        }
    }
    
    open func cancelDataTask(with url: String) {
        
        guard let serverUrl = serverUrl else {
            
            return Log.error("error: server url is nil")
        }
        
        let requestUrl = serverUrl + url
        
        getDataTask(with: requestUrl) { $0?.cancel() }
    }
    
    // MARK: - Private methods
    
    private func getDataTask(with url: String, completion: @escaping (URLSessionDataTask?) -> ()) {
        
        sessionManager.session.getTasksWithCompletionHandler { sessionDataTasks, _, _ in
            
            let dataTask = sessionDataTasks.first {
                
                guard let taskUrl = $0.originalRequest?.url, let host = taskUrl.host else { return false }
                
                return url.contains(host + taskUrl.path)
            }
            
            completion(dataTask)
        }
    }
    
    private func responseHandler(
        
        requestUrl     : String,
        requestId      : Int,
        responseObject : DataResponse<Any>,
        success        : @escaping (Any) -> Void,
        failure        : @escaping (MUNetworkError?,Any?) -> Void
    ) {
        
        logResponse(with: responseObject, requestId: requestId)
        
        if responseObject.response?.statusCode == nil, let error = responseObject.result.error as NSError? {
            
            switch error.code {
            case -999         : failure(MUNetworkError.unknownError, nil)
            case -1009, -1005 : failure(MUNetworkError.connectionError, nil)
            default           : failure(MUNetworkError.serverError, nil)
            }
            
            Log.error("\n[\(requestId)] Handle error:\n\(responseObject.result.error! as NSError)\n")
            
            return
        }
        
        guard let statusCode = responseObject.response?.statusCode else {
            
            return failure(MUNetworkError.unknownError, nil)
        }
        
        switch statusCode {
            
        case 200, 201, 202, 203, 204 : success(responseObject.result.value ?? [])
        case -1009, -1004, -1001     : failure(MUNetworkError.connectionError, nil)
        case 500,501,502,503,504     : failure(MUNetworkError.serverError, responseObject.result.value)
        default                      : failure(MUNetworkError.httpError(statusCode), responseObject.result.value)
        }
    }
    
    private func returnErrorIfDeveloperModeIsOn(failure: (MUNetworkError?,Any?) -> Void) -> Bool {
        
        if MUDeveloperToolsManager.alwaysReturnConnectionError {
            
            failure(MUNetworkError.connectionError, nil)
            
            Log.error("error: connection error (Developer tool)")
            
            return true
        }
        
        if MUDeveloperToolsManager.alwaysReturnServerError {
            
            failure(MUNetworkError.serverError, nil)
            
            Log.error("error: server error (Developer tool)")
            
            return true
        }
        
        return false
    }
    
    private func simulateBadConnectionIfNeeded(completion: @escaping () -> Void) {
        
        guard MUDeveloperToolsManager.shouldSimulateBadConnection else { return completion() }
        
        let delay: TimeInterval = TimeInterval(Int.rand(min: 1, max: 15)) / 10
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            
            completion()
        }
    }
    
    // MARK: - Log methods
    
    private func logResponse(with responseObject: DataResponse<Any>, requestId: Int) {
        
        let body = responseObject.result.value as? NSDictionary ?? responseObject.result.value as? NSArray
        
        let logDictionary = [
            
            "Body" : body ?? responseObject.result.value ?? ""
        ]
        
        let statusCode = responseObject.response?.statusCode ?? -1
        
        DispatchQueue.global().async {
            
            Log.event("\n[\(requestId)] Response (code: \(statusCode)):\n\(logDictionary)\n".unescapingUnicodeCharacters)
        }
    }
    
    private func getRequestId() -> Int {
        
        numberOfRequests += 1
        
        return numberOfRequests
    }
    
    private func filterParams(with params: Any) -> [String: Any]? {
        
        return params as? [String: Any]
    }
    
    private func convertEncoding(with encoding: MUNetworkEncoding, body: Any? = nil) -> ParameterEncoding {
        
        var result: ParameterEncoding = encoding == .url ? URLEncoding.default : JSONEncoding.default
        
        if let body = body as? [Any] {
            
            result = JSONStringEncoding(with: body)
            
        } else if let body = body {
            
            result = JSONStringEncoding(with: body)
        }
        
        return result
    }

    private static func convertServerTrustPolicy(_ policy: MUServerTrustPolicy) -> ServerTrustPolicy {

        switch policy {

        case .performDefaultEvaluation(validateHost: let validateHost):
            return .performDefaultEvaluation(validateHost: validateHost)

        case .performRevokedEvaluation(validateHost: let validateHost, revocationFlags: let revocationFlags):
            return .performRevokedEvaluation(validateHost: validateHost, revocationFlags: revocationFlags)

        case .pinCertificates(certificates: let certificates, validateCertificateChain: let validateCertificateChain, validateHost: let validateHost):
            return .pinCertificates(certificates: certificates, validateCertificateChain: validateCertificateChain, validateHost: validateHost)

        case .pinPublicKeys(publicKeys: let publicKeys, validateCertificateChain: let validateCertificateChain, validateHost: let validateHost):
            return .pinPublicKeys(publicKeys: publicKeys, validateCertificateChain: validateCertificateChain, validateHost: validateHost)

        case .disableEvaluation:
            return .disableEvaluation

        case .customEvaluation(let evaluate):
            return .customEvaluation(evaluate)
        }
    }
}

// MARK: - MUNetworkManager

public extension MUNetworkManager {
    
    static let toArray = "_toArray"
}

// MARK: - MUNetworkRequest

public struct MUNetworkRequest {
    
    public var url      : String
    public var method   : MUNetworkHttpMethod
    public var headers  : [String : String]?   = nil
    public var params   : [String : Any]?      = nil
    public var body     : Any?                 = nil
    public var encoding : MUNetworkEncoding    = .url
    public var success  : ((Any) -> Void)?     = nil
    public var failure  : ((Error?) -> Void)?  = nil
}

// MARK: - MUNetworkManager

public extension MUNetworkManager {
    
    static var isConnected: Bool { return NetworkReachabilityManager()!.isReachable }
}

// MARK: - ApiCoreRequestEncoding

public enum MUNetworkHttpMethod: String {
    
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

// MARK: - MUNetworkEncoding

public enum MUNetworkEncoding {
    
    case url, json
}

// MARK: - ParameterEncoding

public struct JSONStringEncoding: ParameterEncoding {
    
    // MARK: - Private properties
    
    private let value: Any
    
    // MARK: - Public methods
    
    init(with value: Any) {
        
        self.value = value
    }
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        
        var urlRequest = try URLEncoding().encode(urlRequest, with: parameters)
        
        if let value = value as? String {
            
            urlRequest.httpBody = "\"\(value)\"".data(using: .utf8, allowLossyConversion: false)
            
        } else if let value = value as? Int {
            
            urlRequest.httpBody = "\"\(value)\"".data(using: .utf8, allowLossyConversion: false)
            
        } else {
            
            let data = try? JSONSerialization.data(withJSONObject: value, options: [])
            
            urlRequest.httpBody = data
        }
        
        if urlRequest.httpBody != nil {
            
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return urlRequest
    }
}

// MARK: MUServerTrustPolicy

public enum MUServerTrustPolicy {

    case performDefaultEvaluation(validateHost: Bool)
    case performRevokedEvaluation(validateHost: Bool, revocationFlags: CFOptionFlags)
    case pinCertificates(certificates: [SecCertificate], validateCertificateChain: Bool, validateHost: Bool)
    case pinPublicKeys(publicKeys: [SecKey], validateCertificateChain: Bool, validateHost: Bool)
    case disableEvaluation
    case customEvaluation((_ serverTrust: SecTrust, _ host: String) -> Bool)
}

// MARK: - String

extension String {
    
    var unescapingUnicodeCharacters: String {
        
        let string = self.replace(pattern: "\\\\U", with: "\\\\u")
        
        let mutableString = NSMutableString(string: string as NSString)
        
        CFStringTransform(mutableString, nil, "Any-Hex/Java" as NSString, true)
        
        return mutableString as String
    }
}

