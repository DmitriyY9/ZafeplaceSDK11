//
//  Zafeplace.swift
//  ZafeplaceSDK
//
//  Created by Dmitriy Zhyzhko on 03.05.2018.
//  Copyright © 2018 Z4. All rights reserved.
//

import Foundation
import LocalAuthentication
import UIKit
import stellarsdk

final class Zafeplace {
    static let `default` = Zafeplace()
    
    lazy var networkManager = NetworkManager()
    
    private var appId: String?
    private var appSecret: String?
    
    func setup(appId: String, appSecret: String) {
        self.appId = appId
        self.appSecret = appSecret
    }
    
    private func tokenExist() -> Bool {
        return UserDefaults.standard.token != nil
    }
    
    var authState: State = .NOT_AUTHORIZED
    let defaults = UserDefaults.standard
    enum State {
        case AUTHORIZED
        case NOT_AUTHORIZED
        case WALLET_CREATED
        case WALLET_NOT_CREATED
    }
    
    private init() {
        authState = !UserDefaults.retrieveAuth(key: .AUTHORIZATION) ? .NOT_AUTHORIZED : .AUTHORIZED
    }
    
    /// Set appId and appSecret
    ///
    /// - Parameters:
    ///   - appId: bundle id
    ///   - appSecret: unique app key
     static func generateAccessToken(appId: String, appSecret: String) {
        Zafeplace.default.setup(appId: appId, appSecret: appSecret)
    }
    
    /// Create new wallet method
    ///
    /// - Parameter result: generate wallet and return the state
    func createNewWallet(type: NetworkProvider.WalletType, result: (_ state: State) -> ()) {
        if authState == .NOT_AUTHORIZED { result(.NOT_AUTHORIZED) }
        else if !isWalletCreated(type: type) { result(NetworkProvider.generateWallet(type: type)) }
        else { result(.WALLET_CREATED) }
    }
    
    /// User authorization
    ///
    /// - Returns: return Authenticator instance
    func user() -> Authenticator {
        return Authenticator()
    }
    
    /// For requests
    ///
    /// - Returns: request manager instance
//    func operation() -> RequestManager {
//        return RequestManager.instance
//    }
    
    /// Check user auth state
    ///
    /// - Returns: return true/false
    func isAuthorized() -> Bool {
        return authState == .AUTHORIZED
    }
    
    /// Get wallet
    ///
    /// - Parameter type: wallet type
    func wallet(type: NetworkProvider.WalletType) -> BaseProvider {
        return NetworkProvider.getNetwork(by: type)
    }
    
    /// Check if a specific wallet was created
    ///
    /// - Parameter type: wallet type
    /// - Returns: return true/false
    func isWalletCreated(type: NetworkProvider.WalletType) -> Bool {
        return NetworkProvider.getNetwork(by: type).isWalletExist()
    }
    
    /// List of networks and addresses associated with each network
    ///
    /// - Returns: array of the tuples with networks and addresses
    func listOfAddresses() -> [(type: NetworkProvider.WalletType, address: String?)] {
        var list: [(type: NetworkProvider.WalletType, address: String?)] = []
        for type in NetworkProvider.WalletType.allTypes {
            let network = NetworkProvider.getNetwork(by: type)
            if network.isWalletExist() {
                list.append((type: type, address: network.getAddress()))
            }
        }
        return list
    }
    
    func setPinHash(_ pinCode: String) -> Bool {        
        var result = false
        if pinCode.isEmpty {
            result = false
            showAlertPinHash("Pin", message: "error")
        } else {
            let ecryptPinCode = CryptoUtils.encrypt(text: pinCode)
            defaults.set(ecryptPinCode, forKey: "\(pinCode)")
            result = true
            showAlertPinHash("Pin", message: "success")
        }
        return result
    }
    
    func generateWallet(walletType: NetworkProvider.WalletType, completionHandler: @escaping ((String) -> Void)) {
        showAlertEnterPin(title: "", message: "") { [weak self] result in
            guard let `self` = self else { return }
            if result == true {
                if self.isWalletCreated(type: walletType) {
                } else {
                    self.createNewWallet(type: walletType, result: { (state) in
                        print("\(state)")
                        let address = NetworkProvider.getWalletAddress(type: walletType)
                        completionHandler(address ?? "wallet does not exist")
                    })
                }
            } else {
                print("wrong pin")
            }
        }
    }
}

extension Zafeplace {
    private func showAlertPinHash(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        var vc = UIApplication.shared.keyWindow?.rootViewController
        while vc?.presentedViewController != nil {
            vc = vc?.presentedViewController
        }
        vc?.present(alert, animated: true)
    }
    
    private func showAlertEnterPin(title: String, message: String, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Enter Pin Code"
        })
        alertController.addAction(UIAlertAction(title: "Enter Pin", style: .default, handler: { [weak self] alert -> Void in
            guard let `self` = self else { return }
            guard let textField = alertController.textFields?[0] else { return }
            guard let pin = textField.text else { return }
            if self.pinCodeLogin(pin) == true {
                if let pinHash = CryptoUtils.encrypt(text: pin) {
                    let currentPinHash = self.defaults.array(forKey: "\(pin)") as! [UInt8]
                    if pinHash == currentPinHash {
                        completionHandler(true)
                        print("PIN MUTCHED")
                    } else {
                        completionHandler(false)
                        print("PIN ERROR")
                    }
                }
            } else {
                completionHandler(false)
                print("PIN NO CREATE")
            }
        }))
        alertController.addAction(UIAlertAction(title: "FaceID/TuchID", style: .default, handler: { (alert) -> Void in
            print("hello there!.. You have clicked the touch ID")
            let myContext = LAContext()
            let myLocalizedReasonString = "Biometric Authntication testing !! "
            
            var authError: NSError?
            if #available(iOS 8.0, macOS 10.12.1, *) {
                if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                    myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
                        DispatchQueue.main.async {
                            if success {
                                // User authenticated successfully, take appropriate action
                                completionHandler(true)
                                print("Awesome!!... User authenticated successfully")
                            } else {
                                // User did not authenticate successfully, look at error and take appropriate action
                                completionHandler(false)
                                print("Sorry!!... User did not authenticate successfully")
                            }
                        }
                    }
                } else {
                    // Could not evaluate policy; look at authError and present an appropriate message to user
                    completionHandler(false)
                    print("Sorry!!.. Could not evaluate policy.")
                }
            } else {
                // Fallback on earlier versions
                completionHandler(false)
                print("Ooops!!.. This feature is not supported.")
            }
        }))
        var vc = UIApplication.shared.keyWindow?.rootViewController
        while vc?.presentedViewController != nil {
            vc = vc?.presentedViewController
        }
        vc?.present(alertController, animated: true)
    }
    
     func pinCodeLogin(_ pin: String) -> Bool {
        var result = false
        if let pinHash = CryptoUtils.encrypt(text: pin) {
            let currentPinHash = self.defaults.array(forKey: "\(pin)") as? [UInt8]
            if pinHash == currentPinHash {
                result = true
            } else {
                result = false
            }
        }
        return result
    }
    
    //MARK:- Networking    
    private func getAccessToken(response: @escaping (_ descr: Result<String>) -> ()) {
        if tokenExist() {
            response(.failure(NSError(domain: R.string.ok, code: 0, userInfo: nil)))
            return
        }
        
        guard let appId = appId, let appSecret = appSecret else {
            response(.failure(NSError(domain: R.string.noAppIdOrAppSecret, code: 0, userInfo: nil)))
            return
        }
        
        let endpoint = Endpoint.getAccessToken(appId: appId, appSecret: appSecret)
        networkManager.execute(endpoint.request) { (result, code) in
            if let value  = result.value {
                let token = value["accessToken"] as! String
                UserDefaults.standard.token = token
                response(.success(R.string.ok))
            } else {
                response(.failure(NSError(domain: R.string.noAppIdOrAppSecret, code: 0, userInfo: nil)))
            }
        }
    }
    
    func getWalletBalance(network: NetworkProvider.WalletType, response: @escaping (_ balance: Result<Float>) -> ()) {
        getAccessToken { (result) in
            let net = NetworkProvider.getNetwork(by: network)
            if let address = net.getAddress() {
                let networkName = "\(network)".lowercased()
                let endpoint = Endpoint.getBalance(network: networkName, address: address)
                self.networkManager.execute(endpoint.request) { (result, code) in
                    var balance: Float = 0
                    if result.isSuccess, let value = result.value, let floatBalance = value["result"] as? NSString {
                        balance = floatBalance.floatValue
                        response(.success(balance))
                    } else { response(.success(balance)) }
                }
            }
        }
    }
    
    func getTokenBalance(network: NetworkProvider.WalletType, response: @escaping (_ tokenBalance: Result<[TokenBalance]>) -> ()) {
        getAccessToken { (result) in
            let net =  NetworkProvider.getNetwork(by: network)
            if let address = net.getAddress() {
                let networkName = "\(network)".lowercased()
                let endpoint = Endpoint.getTokenBalance(network: networkName, address: address)
                self.networkManager.execute(endpoint.request) { (result, code) in
                    let encoder = JSONDecoder()
                    if result.isSuccess, let value = result.value,
                        let jsonData = try? JSONSerialization.data(withJSONObject: value, options: []),
                        let balanceArray = try? encoder.decode(TokenBalanceResponse.self, from: jsonData) {
                        response(.success(balanceArray.result))
                    } else { response(.failure(result.error!)) }
                }
            }
        }
    }
    
    private func getNativeCoinRawTx(network: NetworkProvider.WalletType, sender: String, recipient: String,
                                    amount: Double, gasLimit: Int, gasPrice: Int,
                                    response: @escaping (_ tokenBalance: Result<NativeCoinRawTx>) -> ()) {
        
        getAccessToken { (result) in
            let networkName = "\(network)".lowercased()
            let endpoint = Endpoint.nativeCoinRawTx(network: networkName, sender: sender, recipient: recipient,
                                                    amount: amount, gasLimit: gasLimit, gasPrice: gasPrice)
            
            self.networkManager.execute(endpoint.request) { (result, code) in
                print("result = \(String(describing: result.value))")
                let encoder = JSONDecoder()
                
                if let value = result.value, let jsonData = try? JSONSerialization.data(withJSONObject: value, options: []),
                    let rawTx = try? encoder.decode(NativeCoinRawTx.self, from: jsonData) {
                    response(.success(rawTx))
                    
                } else {
                    response(.failure(NSError(domain: "Parse error", code: 102, userInfo: nil)))
                }
            }
        }
    }
    
    private func getTokenTransferRawTx(network: NetworkProvider.WalletType, sender: String, recipient: String,
                                       amount: Double, gasLimit: Int, gasPrice: Int,
                                       response: @escaping (_ tokenBalance: Result<NativeCoinRawTx>) -> ()) {
        getAccessToken { (result) in
            let networkName = "\(network)".lowercased()
            let endpoint = Endpoint.tokenTransferRawTx(network: networkName, sender: sender, recipient: recipient,
                                                       amount: amount, gasLimit: gasLimit, gasPrice: gasPrice)
            
            self.networkManager.execute(endpoint.request) { (result, code) in
                print("result = \(String(describing: result.value))")
                
                let encoder = JSONDecoder()
                if let value = result.value, let jsonData = try? JSONSerialization.data(withJSONObject: value, options: []),
                    let rawTx = try? encoder.decode(NativeCoinRawTx.self, from: jsonData) {
                    response(.success(rawTx))
                    
                } else {
                    response(.failure(NSError(domain: "Parse error", code: 102, userInfo: nil)))
                }
            }
        }
    }
    
    func createTransaction(network: NetworkProvider.WalletType, sender: String, recipient: String, amount: Double, response: @escaping (_ response: Result<String>) -> ()) {
                self.getNativeCoinRawTx(network: network, sender: sender, recipient: recipient, amount: amount,
                                   gasLimit: 0, gasPrice: 0, response: { [weak self] (data) in
                                    guard let `self` = self else { return }
                                    guard let popUp = data.value?.result?.popup else { return }
                                    self.showAlertEnterPin(title: "", message: popUp, completionHandler: { (state) in
                                        if state {
                                            switch network {
                                            case .Ethereum:
                                                if let rawTx = data.value {
                                                    let net = NetworkProvider.getNetwork(by: network)
                                                    if let hash = net.signTx(rawTx: rawTx)?.hexEncodedString() {
                                                        let networkName = "\(network)".lowercased()
                                                        let endpoint = Endpoint.sendTx(network: networkName, hash: "0x\(hash)")
                                                        self.networkManager.execute(endpoint.request, completion: { (result, code) in
                                                            if result.isSuccess {
                                                                response(.success("Success"))
                                                            } else {
                                                                let error = result.error?.localizedDescription == nil ? "Error" : (result.error?.localizedDescription)!
                                                                response(.failure(NSError(domain: error, code: 102, userInfo: nil)))
                                                            }
                                                        })
                                                    }
                                                }
                                            case .Stellar:
                                                if let xdr = data.value {
                                                    let net = NetworkProvider.getNetwork(by: network)
                                                     let hash = String(decoding: net.signTx(rawTx: xdr) ?? Data(), as: UTF8.self)
                                                        let networkName = "\(network)".lowercased()
                                                        let endpoint = Endpoint.sendTx(network: networkName, hash: "\(hash)")
                                                        self.networkManager.execute(endpoint.request, completion: { (result, code) in
                                                            if result.isSuccess {
                                                                response(.success("Success"))
                                                            } else {
                                                                let error = result.error?.localizedDescription == nil ? "Error" : (result.error?.localizedDescription)!
                                                                response(.failure(NSError(domain: error, code: 102, userInfo: nil)))
                                                            }
                                                        })
                                                    
                                                }
                                            }
                                        } else {
                                            print("ERROR___ \(#function)")
                                        }
                                    })
                })
    }
    
    func createTransactionToken(network: NetworkProvider.WalletType, sender: String, recipient: String, amount: Double, response: @escaping (_ response: Result<String>) -> ()) {
                self.getTokenTransferRawTx(network: network, sender: sender, recipient: recipient, amount: amount,
                                      gasLimit: 0, gasPrice: 0, response: { [weak self] (data) in
                                        guard let `self` = self else { return }
                                        guard let popUp = data.value?.result?.popup else { return }
                                        self.showAlertEnterPin(title: "", message: popUp, completionHandler: { (state) in
                                            if state {
                                                switch network {
                                                case .Ethereum:
                                                    if let rawTx = data.value {
                                                        let net = NetworkProvider.getNetwork(by: network)
                                                        if let hash = net.signTx(rawTx: rawTx)?.hexEncodedString() {
                                                            let networkName = "\(network)".lowercased()
                                                            let endpoint = Endpoint.sendTx(network: networkName, hash: "0x\(hash)")
                                                            self.networkManager.execute(endpoint.request, completion: { (result, code) in
                                                                if result.isSuccess {
                                                                    response(.success("Success"))
                                                                } else {
                                                                    let error = result.error?.localizedDescription == nil ? "Error" : (result.error?.localizedDescription)!
                                                                    response(.failure(NSError(domain: error, code: 102, userInfo: nil)))
                                                                }
                                                            })
                                                        }
                                                    }
                                                case .Stellar:
                                                    if let rawTx = data.value {
                                                        let net = NetworkProvider.getNetwork(by: network)
                                                        guard let hashX = net.signTx(rawTx: rawTx) else { return }
                                                        let stringHash = String(decoding: hashX, as: UTF8.self)
                                                        //let hash = String(decoding: net.signTx(rawTx: rawTx) ?? Data(), as: UTF8.self)
                                                        let networkName = "\(network)".lowercased()
                                                        let endpoint = Endpoint.sendTx(network: networkName, hash: stringHash)
                                                        self.networkManager.execute(endpoint.request, completion: { (result, code) in
                                                            if result.isSuccess {
                                                                response(.success("Success"))
                                                            } else {
                                                                let error = result.error?.localizedDescription == nil ? "Error" : (result.error?.localizedDescription)!
                                                                response(.failure(NSError(domain: error, code: 102, userInfo: nil)))
                                                            }
                                                        })
                                                        
                                                    }
                                                }
                                            } else {
                                                print("ERROR___ \(#function)")
                                            }
                                        })
                })
    }
    
    func getSmartContractTransactionRaw(network: NetworkProvider.WalletType, response: @escaping (_ abi: Result<[Abi]?>) -> ()) {
        getAccessToken { (result) in
            let networkName = "\(network)".lowercased()
            let endpoint = Endpoint.getContractAbi(network: networkName)
            self.networkManager.execute(endpoint.request, completion: { (result, code) in
                let encoder = JSONDecoder()
                if let value = result.value, let jsonData = try? JSONSerialization.data(withJSONObject: value, options: []),
                    let smartContranct = try? encoder.decode(SmartContractTransactionRow.self, from: jsonData) {
                    response(.success(smartContranct.result?.abi))
                    
                } else {
                    response(.failure(NSError(domain: "Parse error", code: 102, userInfo: nil)))
                }
            })
        }
    }
    
    func executeSmartContractMethod(network: NetworkProvider.WalletType, contract: SmartContractBody, response: @escaping (_ abi: Result<ExecuteMethodModel>) -> ()) {
        getAccessToken { (result) in
            self.showAlertEnterPin(title: ".", message: "executeSmartContract", completionHandler: { (state) in
                if state {
                    let networkName = "\(network)".lowercased()
                    let endpoint = Endpoint.executeSmartContract(network: networkName, contract: contract)
                    self.networkManager.execute(endpoint.request, completion: { (result, code) in
                        print("result = \(result)")
                        let encoder = JSONDecoder()
                        if let value = result.value, let jsonData = try? JSONSerialization.data(withJSONObject: value, options: []),
                            let executeMethod = try? encoder.decode(ExecuteMethodModel.self, from: jsonData) {
                            response(.success(executeMethod))
                        } else {
                            response(.failure(NSError(domain: "Parse error", code: 102, userInfo: nil)))
                        }
                    })
                } else {
                    print("ERROR___ \(#function)")
                }
            })
        }
    }
    
    private func changeTrustMethod(amount: Double, response: @escaping (_ response: Result<NativeCoinRawTx>) -> ()) {
        getAccessToken { (result) in
            let net =  NetworkProvider.getNetwork(by: .Stellar)
            if let address = net.getAddress() {
                let networkName = "\(NetworkProvider.WalletType.Stellar)".lowercased()
                let endpoint = Endpoint.changeTrust(network: networkName, recipient: address, amount: amount)
                self.networkManager.execute(endpoint.request) { (result, code) in
                    print("result = \(String(describing: result.value))")
                    let encoder = JSONDecoder()
                    if let value = result.value, let jsonData = try? JSONSerialization.data(withJSONObject: value, options: []),
                        let rawTx = try? encoder.decode(NativeCoinRawTx.self, from: jsonData) {
                        response(.success(rawTx))
                    } else {
                        response(.failure(NSError(domain: "Parse error", code: 102, userInfo: nil)))
                    }
                }
            }
        }
    }
    
    func changeTrust(amount: Double, response: @escaping (_ response: Result<Any>) -> ()) {
        changeTrustMethod(amount: amount) { [weak self] (data) in
            guard let `self` = self else { return }
            if let xdr = data.value {
                self.showAlertEnterPin(title: "", message: "", completionHandler: { (state) in
                    if state {
                        let net = NetworkProvider.getNetwork(by: .Stellar)
                        let hash = String(decoding: net.signTx(rawTx: xdr) ?? Data(), as: UTF8.self)
                        let networkName = "stellar"
                        let endpoint = Endpoint.sendTx(network: networkName, hash: "\(hash)")
                        self.networkManager.execute(endpoint.request, completion: { (result, code) in
                            if result.isSuccess {
                                response(.success(result))
                            } else {
                                let error = result.error?.localizedDescription == nil ? "Error" : (result.error?.localizedDescription)!
                                response(.failure(NSError(domain: error, code: 102, userInfo: nil)))
                            }
                        })
                    } else {
                        print("error pin")
                    }
                })
            }
        }
    }
}
