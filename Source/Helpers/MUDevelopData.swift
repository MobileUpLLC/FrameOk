//
//  MUDevelopData.swift
//  FrameOk
//
//  Created by Dmitry Smirnov on 03.11.2020.
//

import UIKit

// MARK: - MUDevelopData

final class MUDevelopData {

    // MARK: - Public properties

    static var isEnabled: Bool = true

    static var defaultLogin: String = ""

    static var defaultPhone: String = ""

    static var defaultPassword: String = ""

    static var defaultPasswordHint: String { return isEnabled ? randomHint : "" }

    static var defaultSmsCode: String { return isEnabled ? verifySmsCode : "" }

    static var previousLogin: String? { return UserDefaults.previousLogin }

    static var previousPhone: String? { return UserDefaults.previousPhone }

    static var previousPassword: String? { return UserDefaults.previousPassword }

    static var defaultCardPan: String { return String.generateRandomCardPan() }

    // MARK: - Private properties

    private static var randomLogin: String { return String.generateRandomLogin() }

    private static var randomPhone: String { return String.generateRandomPhone() }

    private static var randomPassword: String { return String.generateRandomPassword() }

    private static var randomHint: String { return UUID().uuidString }

    private static var verifySmsCode: String { return "1234" }

    // MARK: - Public methods

    static func generateRandomData() {

        defaultLogin = isEnabled ? randomLogin : ""

        defaultPhone = isEnabled ? randomPhone : ""

        defaultPassword = isEnabled ? MUDevelopData.randomPassword : ""
    }

    static func saveData() {

        UserDefaults.previousLogin = defaultLogin

        UserDefaults.previousPhone = defaultPhone

        UserDefaults.previousPassword = defaultPassword
    }

    static func updatePreviousPassword(with password: String) {

        UserDefaults.previousPassword = password
    }
}

// MARK: - String

extension String {

    // MARK: - Public methods

    static func generateRandomPhone() -> String {

        var phone = "79"

        for _ in 1...9 {

            phone += Int.rand(min: 1, max: 9).description
        }

        return phone
    }

    static func generateRandomLogin() -> String {

        return randomString(length: 15)
    }

    static func generateRandomPassword() -> String {

        return randomString(length: 10)
    }

    static func randomString(length: Int) -> String {

        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

        return String((0..<length).map{ _ in letters.randomElement()! })
    }

    static func generateRandomCardPan() -> String {

        var number = "4111";

        for _ in 1...3 {

            number += " "

            for _ in 1...4 {

                number += Int.rand(min: 1, max: 9).description
            }
        }

        return number
    }
}

// MARK: - UserDefaults

extension UserDefaults {

    // MARK: - Private properties

    fileprivate static var previousLogin: String? {

        get { return UserDefaults.standard.string(forKey: previousLoginKey) }
        set { UserDefaults.standard.set(newValue, forKey: previousLoginKey) }
    }

    fileprivate static var previousPhone: String? {

        get { return UserDefaults.standard.string(forKey: previousPhoneKey) }
        set { UserDefaults.standard.set(newValue, forKey: previousPhoneKey) }
    }

    fileprivate static var previousPassword: String? {

        get { return UserDefaults.standard.string(forKey: previousPasswordKey) }
        set { UserDefaults.standard.set(newValue, forKey: previousPasswordKey) }
    }

    private static let previousLoginKey = "previousLoginKey"

    private static let previousPhoneKey = "previousPhoneKey"

    private static let previousPasswordKey = "previousPasswordKey"
}
