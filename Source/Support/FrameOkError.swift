//
//  FrameOkError.swift
//  FrameOk
//
//  Created by Dmitry Smirnov on 02.11.2020.
//

import Foundation

enum FrameOkError: Error {

    case unknownError
}

// MARK: - MUErrorManager

extension FrameOkError {

    // MARK: - Public properties

    static var recipient: NSObject? { didSet { MUErrorManager.recipient = recipient } }

    // MARK: - Public methods

    static func post(with error: FrameOkError, for recipient: NSObject? = nil) {

        MUErrorManager.post(with: error, for: recipient)
    }

    func post(for recipient: NSObject? = nil) {

        MUErrorManager.post(with: self, for: recipient)
    }
}
