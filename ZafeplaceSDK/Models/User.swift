//
//  User.swift
//  ZafeplaceSDK
//
//  Created by Dmitriy Zhyzhko on 10.05.2018.
//  Copyright © 2018 Z4. All rights reserved.
//

import Foundation
import UIKit

class User: NSObject, NSCoding {
    
    private var firstName: [UInt8]?
    private var secondName: [UInt8]?
    private var email: [UInt8]?
    private var additionalData: [UInt8]?
    private var validationTime: [UInt8]?
    private var network: [UInt8]?
    private var deviceKey: [UInt8]?
    
    override init() {
        super.init()
        setValidationTime(time: NSDate().timeIntervalSince1970 * 1000)
        setDeviceKey(key: UIDevice.current.identifierForVendor!.uuidString)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.firstName, forKey: "firstName")
        aCoder.encode(self.secondName, forKey: "secondName")
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.additionalData, forKey: "additionalData")
        aCoder.encode(self.validationTime, forKey: "validationTime")
        aCoder.encode(self.network, forKey: "network")
        aCoder.encode(self.deviceKey, forKey: "deviceKey")
    }
    
    required  init?(coder aDecoder: NSCoder) {
        self.firstName = aDecoder.decodeObject(forKey: "firstName") as? [UInt8]
        self.secondName = aDecoder.decodeObject(forKey: "secondName") as? [UInt8]
        self.email = aDecoder.decodeObject(forKey: "email") as? [UInt8]
        self.additionalData = aDecoder.decodeObject(forKey: "additionalData") as? [UInt8]
        self.validationTime = aDecoder.decodeObject(forKey: "validationTime") as? [UInt8]
        self.network = aDecoder.decodeObject(forKey: "network") as? [UInt8]
        self.deviceKey = aDecoder.decodeObject(forKey: "deviceKey") as? [UInt8]
    }
    
    //MAKR: Setters
    
    func setDeviceKey(key: String) {
        self.deviceKey = CryptoUtils.encrypt(text: key)
    }
    
    func setNetwork(type: NetworkProvider.WalletType) {
        let network = String(describing: type)
        self.network = CryptoUtils.encrypt(text: network)
    }
    
    func setValidationTime(time: Double) {
        let valStr = String(describing: time)
        self.validationTime = CryptoUtils.encrypt(text: valStr)
    }
    
    func setFirstName(firstName: String) {
        self.firstName = CryptoUtils.encrypt(text: firstName)
    }
    
    func setSecondName(secondName: String) {
        self.secondName = CryptoUtils.encrypt(text: secondName)
    }
    
    func setEmail(email: String) {
        self.email = CryptoUtils.encrypt(text: email)
    }
    
    func setAdditionalData(additionalData: String) {
        self.additionalData = CryptoUtils.encrypt(text: additionalData)
    }
    
    //MAKR: Getters
    
    func getDeviceKey() -> String? {
        return CryptoUtils.decrypt(encryped: deviceKey!)
    }
    
    func getNetwork() -> String? {
        return CryptoUtils.decrypt(encryped: network!)
    }
    
    func getValidationTime() -> String? {
        return CryptoUtils.decrypt(encryped: validationTime!)
    }
    
    func getFirstName() -> String? {
        return CryptoUtils.decrypt(encryped: firstName!)
    }
    
    func getSecondName() -> String? {
        return CryptoUtils.decrypt(encryped: secondName!)
    }
    
    func getEmail() -> String? {
        return CryptoUtils.decrypt(encryped: email!)
    }
    
    func getAdditionalData() -> String? {
        return CryptoUtils.decrypt(encryped: additionalData!)
    }
    
    func hash() -> String {
        return String(describing: getFirstName()!.hashValue)
            + String(describing: getSecondName()!.hashValue)
            + String(describing: getEmail()!.hashValue)
            + String(describing: getAdditionalData()!.hashValue)
    }
}
