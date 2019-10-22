//
//  Extensions.swift
//  ZafeplaceSDK
//
//  Created by Dmitriy Zhyzhko on 04.05.2018.
//  Copyright © 2018 Z4. All rights reserved.
//

import Foundation
import CryptoSwift

// MARK: - UserDefaults
extension UserDefaults {
    
    
    enum Key: String {
        case AUTHORIZATION = "ZafeplaceAuthrorization"
        case PIN = "ZafeplacePin"
        case USER = "ZafeplaceUser"
        case HASH = "ZafeplaceHash"
    }
    
    var token: String? {
        get { return value(forKey: #function) as? String }
        set { set(newValue, forKey: #function) }
    }
    
    static func save(key: Key, value: Any) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    static func saveEncrypt(key: Key, value: String) {
        if let encryped = CryptoUtils.encrypt(text: value) {
            save(key: .PIN, value: encryped)
        }
    }
    
    static func retrievePinDecrypt(key: Key) -> String? {
        if let encrypted = retreiveDecrypt(key: .PIN) {
            return CryptoUtils.decrypt(encryped: encrypted)
        }
        return nil
    }
    
    static func retreiveDecrypt(key: Key) -> [UInt8]? {
        return UserDefaults.standard.array(forKey: key.rawValue) as? [UInt8]
    }
    
    static func retrieveUser(key: Key) -> User? {
        guard let decoded  = UserDefaults.standard.object(forKey: key.rawValue) as? Data else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(with: decoded) as? User
    }
    
    static func retrieveHash(key: Key) -> String? {
        return UserDefaults.standard.string(forKey: key.rawValue)
    }
    
    static func retrieveAuth(key: Key) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }
}

extension Data {
    
    /// Create hexadecimal string representation of `Data` object.
    ///
    /// - returns: `String` representation of this `Data` object.
    func hexadecimal() -> String {
        return map { String(format: "%02x", $0) }
            .joined(separator: "")
    }
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
