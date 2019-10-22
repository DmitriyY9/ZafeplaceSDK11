//
//  CryptoUtils.swift
//  ZafeplaceSDK
//
//  Created by Dmitriy Zhyzhko on 04.05.2018.
//  Copyright © 2018 Z4. All rights reserved.
//

import Foundation
import CryptoSwift

final class CryptoUtils {
    
    //16 chars only
    private static let password = "zafeplacepasswor"
    private static let vendor = "zafeplacevendorr"
    
    static func encrypt(text: String) -> [UInt8]? {
        do {
            let aes = try AES(key: password, iv: vendor)
            let encrypted = try aes.encrypt(Array(text.utf8))
            
            return encrypted
        } catch { print("Error = \(error) ") }
    
        return nil
    }
    
    static func decrypt(encryped: [UInt8]) -> String? {
        do {
            let aes = try AES(key: password, iv: vendor)
            let dec = try aes.decrypt(Array(encryped))
            
            return String(data: Data(dec), encoding: .utf8) ?? ""
        } catch { print("Error: \(error)") }
        
        return nil
    }
}
