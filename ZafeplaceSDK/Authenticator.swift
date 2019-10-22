//
//  Authenticator .swift
//  ZafeplaceSDK
//
//  Created by Dmitriy Zhyzhko on 04.05.2018.
//  Copyright © 2018 Z4. All rights reserved.
//

import Foundation
import LocalAuthentication
import UIKit

final class Authenticator {
    
    private let maxPinCodeNumber = 4
    
    enum ResultType: Int {
        case TOUCH_ID_IS_MISSING = -7
        case TOUCH_ID_RETRY_EXCEEDED = -1
        case INCORRECT_PIN_CODE = -4
        case WRONG_PIN_CODE_NUMBER_COUNT = -5
        case SUCCESS = 1
        case ALREADY_AUTHORIZED = -10
    }
    
    enum AuthType {
        case PIN(String)
        case TOUCH
        case FACEID
    }
    
    enum RegisterType {
        case REGISTER
        case UPDATE
    }
    
    enum RegisterState {
        case NOT_AUTHORIZED
        case ALREADY_REGISTERED
        case REGISTERED
        case UPDATED
    }
    
    /// Registration
    ///
    /// - Parameters:
    ///   - user: information about the user
    func register(user: User, type: RegisterType, result: @escaping (_ type: RegisterState) -> ()) {
        if type == .REGISTER && UserDefaults.retrieveUser(key: .USER) != nil {
            result(.ALREADY_REGISTERED)
            return
        }
        
        if let prevUserData = UserDefaults.retrieveUser(key: .USER) {
            UserDefaults.save(key: .HASH, value: prevUserData.hash())
        }
        UserDefaults.save(key: .USER, value: NSKeyedArchiver.archivedData(withRootObject: user))
        result(type == .REGISTER ? .REGISTERED : .UPDATED)
    }
    
    /// Request user data
    func requestUserData( result: @escaping (_ type: RegisterState) -> ()) -> User? {
        let user = UserDefaults.retrieveUser(key: .USER)
        let hash = UserDefaults.retrieveHash(key: .HASH)
        //print("Hash = \(hash), User hash = \(user?.hash())")
        if hash != nil && user?.hash() != hash {
            result(.NOT_AUTHORIZED)
            return nil
        }
        return user
    }
    
    /// Authentication
    ///
    /// - Parameters:
    ///   - type: touch id or pin code
    ///   - result: return result of the authentication
    func authenticate(type: AuthType, result: @escaping (_ state: Bool, _ type: ResultType) -> ()) {
//        guard EthereumProvider().getPrivateKey() == nil else {
//            result(false, .ALREADY_AUTHORIZED)
//            return
//        }
        
        switch type {
            case .FACEID: touchId(result: result) //added if condition for biometryType
            case .TOUCH: touchId(result: result)
            case .PIN(let code): pin(code: code, result: result)
        }
    }
    
    fileprivate func pin(code: String, result: @escaping (_ state: Bool, _ type: ResultType) -> ()) {
        if code.count < maxPinCodeNumber { result(false, .WRONG_PIN_CODE_NUMBER_COUNT) }
        else {
            if UserDefaults.retrieveAuth(key: .AUTHORIZATION) {
                let pin = UserDefaults.retrievePinDecrypt(key: .PIN)
                let isEquals = pin == code
                result(isEquals, isEquals ? .SUCCESS : .INCORRECT_PIN_CODE)
                
            } else {
                Zafeplace.default.authState = .AUTHORIZED
                UserDefaults.save(key: .AUTHORIZATION, value: true)
                UserDefaults.saveEncrypt(key: .PIN, value: code)
                result(true, .SUCCESS)
            }
        }
    }
    
    fileprivate func touchId(result: @escaping (_ state: Bool, _ type: ResultType) -> ()) {
        var error: NSError? // Create error reference
        let authContext = LAContext() // Create a authentication context
        
        // Check device biometryType
        var localizedReason = R.string.unlockDevice
        if #available(iOS 11.0, *) {
            switch authContext.biometryType {
                case .faceID: localizedReason = R.string.unlockDeviceWithFaceId
                case .none: fallthrough
                case .touchID: localizedReason = R.string.unlockDeviceWithTouchId
            }
        }
        
        // Check if the device has a fingerprint sensor
        // If not, show the user an alert view and bail out!
        guard authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            print("error = \(error)")
            result(false, .TOUCH_ID_IS_MISSING)
            return
        }
        
        // Check the fingerprint
        authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReason, reply: {
            (success, error) -> Void in
            
            if error != nil {
                result(success, .TOUCH_ID_RETRY_EXCEEDED)
                return
            }
            
            Zafeplace.default.authState = .AUTHORIZED
            UserDefaults.save(key: .AUTHORIZATION, value: true)
            result(success, .SUCCESS)
        })
    }
}
