//
//  MUWebLogsManager.swift
//  
//
//  Created by IF on 01/08/2019.
//  Copyright © 2019 MobileUp. All rights reserved.
//

import Foundation
import GCDWebServer

// MARK: - MUWebLogsManager

open class MUWebLogsManager: NSObject {
    
    // MARK: Public properties
    
    public static var url: String { return shared.server.serverURL?.absoluteString ?? "" }
    
    // MARK: - Private properties
    
    private static let shared: MUWebLogsManager = MUWebLogsManager()
    
    private var server: GCDWebServer = GCDWebServer()
    
    // MARK: - Public methods
    
    public static func setup() {
        
        if MUDeveloperToolsManager.shouldShowWebLogs {
            
            self.start()
        }
    }
    
    public static func start() {
        
        if shared.server.start(), let url = shared.server.serverURL {
            
            Log.details("Visit \(url.absoluteString) in your web browser.")
        } else {
            Log.error("Failed to start web logs server.")
        }
    }
    
    public static func stop() {
        
        shared.server.stop()
    }
    
    // MARK: - Overriden methods
    
    override init() {
        
        super.init()
        
        addRequestHandler()
    }
    
    // MARK: - Private methods
    
    private func addRequestHandler() {
        
        server.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self) { (request) -> GCDWebServerResponse? in
            
            let logs = MULogManager.collectedLogs().components(separatedBy: "\n").joined(separator: "<br/>")
            
            let font = "style=\"font-family: -apple-system, BlinkMacSystemFont, sans-serif;\""
            
            return GCDWebServerDataResponse(html:"<html><body><pre><p \(font)>\(logs)</p></pre></body></html>")
        }
    }
}
