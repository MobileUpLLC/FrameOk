//
//  LogManager.swift
//
//  Created by Dmitry Smirnov on 1/02/2019.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Foundation
import XCGLogger

public enum MULogLevel: String {
    
    case details  = "[ℹ️]"
    case event    = "[💬]"
    case error    = "[⚠️]"
    case critical = "[🔥]"
    
    public static var allValues: [MULogLevel] { return [.details, .event, .error, .critical] }
}

// MARK: - MULogManager

open class MULogManager: NSObject {
    
    // MARK: - Public properties

    public static var isEnabled: Bool = false
    
    private(set) public static var logOnRelease: Bool = false
    
    private(set) public static var writeToFile: Bool = false
    
    private(set) public static var shouldAppend: Bool = false
    
    public static let filePath: String = FileManager.getPath(to: "Logs")
    
    public static var isLogingEnabled: Bool { return MULogManager.isEnabled }
    
    public static var isAlreadySetup: Bool = false
    
    // MARK: - Private properties
    
    private static let consoleLogDestinationKey: String = "MULogManager.console"
    
    private static let fileLogDestinationKey: String = "MULogManager.file"
    
    fileprivate static let lineStartKey: String = "ǁ"
    
    fileprivate static let logger: XCGLogger = XCGLogger(identifier: "MULogManager", includeDefaultDestinations: false)
    
    fileprivate static var collectedLogs: String = ""
    
    fileprivate static var levelsDescriptions = [
        
        XCGLogger.Level.verbose : MULogLevel.details.rawValue,
        XCGLogger.Level.info    : MULogLevel.event.rawValue,
        XCGLogger.Level.error   : MULogLevel.error.rawValue,
        XCGLogger.Level.severe  : MULogLevel.critical.rawValue,
    ]
    
    // MARK: - Public methods
    
    public class func setup(logOnRelease: Bool = false, writeToFile: Bool = false, shouldAppend: Bool = false) {
        
        logger.remove(destinationWithIdentifier: consoleLogDestinationKey)
        
        logger.remove(destinationWithIdentifier: fileLogDestinationKey)
        
        self.logOnRelease = logOnRelease
        self.writeToFile  = writeToFile
        self.shouldAppend = shouldAppend
        
        addWritingToConsole()
        
        if writeToFile {
            
            addWritingToFile(shouldAppend: shouldAppend)
        }
        
        isAlreadySetup = true
        
        logger.logAppDetails()
    }
    
    public class func clear() {
        
        collectedLogs = ""
    }
    
    public class func collectedLogs(_ types: [MULogLevel] = MULogLevel.allValues) -> String {
        
        return filteredLogs(collectedLogs, levels: types)
    }
    
    public class func lastLogs(_ types: [MULogLevel] = MULogLevel.allValues, number: Int = 1) -> [String] {
        
        return splitLogs(with: collectedLogs, levels: types).suffix(number)
    }
    
    public class func fileLogs(_ types: [MULogLevel] = MULogLevel.allValues) -> String? {
        
        guard writeToFile else { return nil }

        if let rawLogs = try? String(contentsOf: URL(fileURLWithPath: filePath), encoding: .utf8) {
        
            return filteredLogs(rawLogs, levels: types)
        } else {
            return nil
        }
    }
    
    // MARK: - Private methods
    
    private class func addWritingToConsole() {
        
        let console: BaseQueuedDestination = FormattedConsoleDestination(identifier: consoleLogDestinationKey)
       
        console.outputLevel       = .verbose
        console.showLogIdentifier = false
        console.showFunctionName  = true
        console.showThreadName    = false
        console.showLevel         = true
        console.showFileName      = true
        console.showLineNumber    = true
        console.showDate          = true
        console.levelDescriptions = levelsDescriptions
        
        logger.add(destination: console)
    }
    
    private class func addWritingToFile(shouldAppend: Bool) {
        
        let file = FormattedFileDestination(
            
            writeToFile  : MULogManager.filePath,
            identifier   : fileLogDestinationKey,
            shouldAppend : shouldAppend
        )
        
        file.outputLevel       = .verbose
        file.showLogIdentifier = false
        file.showFunctionName  = true
        file.showThreadName    = true
        file.showLevel         = true
        file.showFileName      = true
        file.showLineNumber    = true
        file.showDate          = true
        file.logQueue          = XCGLogger.logQueue
        file.levelDescriptions = levelsDescriptions
        
        logger.add(destination: file)
    }
    
    private class func splitLogs(with rawLogs: String, levels: [MULogLevel]) -> [String] {
        
        let levelTags: [String] = levels.map { $0.rawValue }
        
        return rawLogs.components(separatedBy:lineStartKey).filter{levelTags.contains(where: $0.contains)}
    }
    
    private class func filteredLogs(_ rawLogs: String, levels: [MULogLevel]) -> String {
        
        return splitLogs(with: rawLogs, levels: levels).joined(separator: "")
    }
    
    fileprivate class func log(
        
        _ level  : MULogLevel,
        message  : String,
        function : StaticString = #function,
        file     : StaticString = #file,
        line     : Int          = #line
    ) {
        
        if isAlreadySetup == false { setup() }
        
        if collectedLogs.count + message.count >= NSIntegerMax {
            
            collectedLogs = (collectedLogs as NSString).substring(from: NSIntegerMax/2)
        }
        
        if MULogManager.isLogingEnabled {
            
            switch level {
                
            case .details  : logger.verbose(message, functionName: function, fileName: file, lineNumber: line)
            case .event    : logger.info(message, functionName: function, fileName: file, lineNumber: line)
            case .error    : logger.error(message, functionName: function, fileName: file, lineNumber: line)
            case .critical : logger.severe(message, functionName: function, fileName: file, lineNumber: line)
            }
        }
    }
}

// MARK: - Log

final class Log: NSObject {
    
    // MARK: - Public methods
    
    @available(*, deprecated, message: "Please use details/event/error/critical instead") public class func show(
        
        _ message  : String,
        function : StaticString = #function,
        file     : StaticString = #file,
        line     : Int          = #line
    ) {
        
        details(message, function: function, file: file, line: line)
    }
    
    /// Used to log all the detailed information like an API JSON response or file path, etc.
    public class func details(
        
        _ message  : String,
          function : StaticString = #function,
          file     : StaticString = #file,
          line     : Int          = #line
    ) {
        
       MULogManager.log(.details, message: message, function: function, file: file, line: line)
    }
    
    /// Used to log all the significant events like a gesture recognition or user authorization success or any other.
    public class func event(
        
        _ message  : String,
          function : StaticString = #function,
          file     : StaticString = #file,
          line     : Int          = #line
    ) {
        
        MULogManager.log(.event, message: message, function: function, file: file, line: line)
    }

    /// Used to log any non-critical error, like a wrong user password or http request timeout.
    public class func error(
        
        _ message  : String,
          function : StaticString = #function,
          file     : StaticString = #file,
          line     : Int          = #line
    ) {
        
        MULogManager.log(.error, message: message, function: function, file: file, line: line)
    }
    
    /// Used to log any critical error, which occuring requires special attention.
    public class func critical(
        
        _ message  : String,
          function : StaticString = #function,
          file     : StaticString = #file,
          line     : Int          = #line
    ) {
        
        MULogManager.log(.critical, message: message, function: function, file: file, line: line)
    }
}

// MARK: - FormattedFileDestination

class FormattedFileDestination: FileDestination {
    
    override func process(logDetails: LogDetails) {
        
        formattedProcess(logDetails)
    }
}

// MARK: - FormattedConsoleDestination

class FormattedConsoleDestination: BaseQueuedDestination {
    
    // MARK: - Public properties
    
    //Setter is ignored, NSLog adds the date, so we always want showDate to be false in this subclass
    override var showDate: Bool {
        
        get { return isNSLog == false }
        set { }
    }
    
    // MARK: - Private properties
    
    fileprivate var isNSLog: Bool {
        
        #if DEBUG
        
        return false
        
        #else
        
        return MULogManager.logOnRelease == true
        
        #endif
    }
    
    // MARK: - Override methods
    
    override func write(message: String) {
    
        MULogManager.collectedLogs = message + "\n" + MULogManager.collectedLogs
        
        let cleanMessage = message.replace(pattern: MULogManager.lineStartKey) 
        
        if isNSLog == true {
            
            NSLog("%@", cleanMessage)
        } else {
            print(cleanMessage)
        }
    }
    
    override func process(logDetails: LogDetails) {
        
        formattedProcess(logDetails)
    }
}

extension BaseQueuedDestination {
    
    // MARK: - Private methods
    
    fileprivate func formattedProcess(_ logDetails: LogDetails) {
        
        guard let owner = owner else { return }
        
        var extendedDetails: String = "\n\(MULogManager.lineStartKey)"
        
        if showDate {
            
            extendedDetails += "\((owner.dateFormatter != nil) ? owner.dateFormatter!.string(from: logDetails.date) : logDetails.date.description)\n"
        }
        
        if showLogIdentifier {
            
            extendedDetails += "[\(owner.identifier)] "
        }
        
        if showFunctionName {
            
            extendedDetails += "\(logDetails.functionName) "
        }
        
        if showFileName {
            
            extendedDetails += "[\((logDetails.fileName as NSString).lastPathComponent)\((showLineNumber ? ":" + String(logDetails.lineNumber) : ""))] "
            
        } else if showLineNumber {
            
            extendedDetails += "[\(logDetails.lineNumber)] "
            
        }
        
        if showThreadName {
        
            extendedDetails += "[\(threadName())] "
        }
        
        var level = ""
        
        if showLevel {
            
            level = "\(levelDescriptions[logDetails.level] ?? owner.levelDescriptions[logDetails.level] ?? logDetails.level.description) "
        }
        
        let formattedMessage = "\(extendedDetails)\n\(level)\(logDetails.message)"
        
        output(logDetails: logDetails, message: formattedMessage)
    }
    
    private func threadName() -> String {
        
        guard Thread.isMainThread == false else { return "main" }
        
        if let threadName = Thread.current.name, !threadName.isEmpty {
            
            return threadName
            
        } else if let queueName = DispatchQueue.currentQueueLabel, !queueName.isEmpty {
            
            return queueName
            
        } else {
            
            return String(format: "%p", Thread.current)
            
        }
    }
}
