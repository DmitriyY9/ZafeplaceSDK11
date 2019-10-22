//
//  RequestManager.swift
//  ZafeplaceSDK
//
//  Created by Dmitriy Zhyzhko on 18.06.2018.
//  Copyright © 2018 Z4. All rights reserved.
//

import Foundation
//import BigInt

final class RequestManager {
    static let instance = RequestManager()
    lazy var networkManager = NetworkManager.init()
    
    private var appId: String?
    private var appSecret: String?
    
    func setup(appId: String, appSecret: String) {
        self.appId = appId
        self.appSecret = appSecret
    }
    
    private func tokenExist() -> Bool {
        return UserDefaults.standard.token != nil
    }
    
    private func getAccessToken(response: @escaping (_ descr: Result<String>) -> ()) {
        if tokenExist() {
            response(.failure(NSError.init(domain: R.string.ok, code: 0, userInfo: nil)))
            return
        }
        guard let appId = appId, let appSecret = appSecret else {
            response(.failure(NSError.init(domain: R.string.noAppIdOrAppSecret, code: 0, userInfo: nil)))
            return
        }
        
        let endpoint = Endpoint.getAccessToken(appId: appId, appSecret: appSecret)
        networkManager.execute(endpoint.request) { (result, code) in
            if let value  = result.value {
                let token = value["accessToken"] as! String
                UserDefaults.standard.token = token
                print("token = \(token)")
                response(.success(R.string.ok))
            } else {
                response(.failure(NSError.init(domain: R.string.noAppIdOrAppSecret, code: 0, userInfo: nil)))
            }
        }
    }
    
    func getBalance(network: NetworkProvider.WalletType, response: @escaping (_ balance: Result<Float>) -> ()) {
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
    
    func  getTokenBalance(network: NetworkProvider.WalletType, response: @escaping (_ tokenBalance: Result<[TokenBalance]>) -> ()) {
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
                            amount: Int, gasLimit: Int, gasPrice: Int,
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
                    response(.failure(NSError.init(domain: "Parse error", code: 102, userInfo: nil)))
                    
                }
            }
        }
    }
    
    private func getTokenTransferRawTx(network: NetworkProvider.WalletType, sender: String, recipient: String,
                                    amount: Int, gasLimit: Int, gasPrice: Int,
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
                    response(.failure(NSError.init(domain: "Parse error", code: 102, userInfo: nil)))
                }
            }
        }
    }
    
    func createTransaction(network: NetworkProvider.WalletType, sender: String, recipient: String, amount: Int, response: @escaping (_ response: Result<String>) -> ()) {
        getNativeCoinRawTx(network: network, sender: sender, recipient: recipient, amount: amount,
                           gasLimit: 0, gasPrice: 0, response: { (data) in
                            
                            switch network {
                            case .Ethereum:
                                if let rawTx = data.value?.result?.rawTx {
                                    let net = NetworkProvider.getNetwork(by: network)
                                    if let hash = net.signTx(rawTx: rawTx)?.hexEncodedString() {
                                        let networkName = "\(network)".lowercased()
                                        let endpoint = Endpoint.sendTx(network: networkName, hash: "0x\(hash)")
                                        self.networkManager.execute(endpoint.request, completion: { (result, code) in
                                            if result.isSuccess {
                                                response(.success("Success"))
                                            } else {
                                                let error = result.error?.localizedDescription == nil ? "Error" : (result.error?.localizedDescription)!
                                                response(.failure(NSError.init(domain: error, code: 102, userInfo: nil)))
                                            }
                                        })
                                    }
                                }
                            case .Stellar:
                                if let rawTx = data.value?.result?.rawTx {
                                    let net = NetworkProvider.getNetwork(by: network)
                                    let hash = String(decoding: net.signTx(rawTx: rawTx) ?? Data(), as: UTF8.self)
                                    let networkName = "\(network)".lowercased()
                                    let endpoint = Endpoint.sendTx(network: networkName, hash: "\(hash)")
                                    self.networkManager.execute(endpoint.request, completion: { (result, code) in
                                        if result.isSuccess {
                                            response(.success("Success"))
                                        } else {
                                            let error = result.error?.localizedDescription == nil ? "Error" : (result.error?.localizedDescription)!
                                            response(.failure(NSError.init(domain: error, code: 102, userInfo: nil)))
                                        }
                                    })
                                    
                                }
                            }
        })
    }
    
    func createTokenTransaction(network: NetworkProvider.WalletType, sender: String, recipient: String, amount: Int, response: @escaping (_ response: Result<String>) -> ()) {
        getTokenTransferRawTx(network: network, sender: sender, recipient: recipient, amount: amount,
                              gasLimit: 0, gasPrice: 0, response: { (data) in
                                
                                switch network {
                                case .Ethereum:
                                    if let rawTx = data.value?.result?.rawTx {
                                        let net = NetworkProvider.getNetwork(by: network)
                                        if let hash = net.signTx(rawTx: rawTx)?.hexEncodedString() {
                                            let networkName = "\(network)".lowercased()
                                            let endpoint = Endpoint.sendTx(network: networkName, hash: "0x\(hash)")
                                            self.networkManager.execute(endpoint.request, completion: { (result, code) in
                                                if result.isSuccess {
                                                    response(.success("Success"))
                                                } else {
                                                    let error = result.error?.localizedDescription == nil ? "Error" : (result.error?.localizedDescription)!
                                                    response(.failure(NSError.init(domain: error, code: 102, userInfo: nil)))
                                                }
                                            })
                                        }
                                    }
                                case .Stellar:
                                    if let rawTx = data.value?.result?.rawTx {
                                        let net = NetworkProvider.getNetwork(by: network)
                                        let hash = String(decoding: net.signTx(rawTx: rawTx) ?? Data(), as: UTF8.self)
                                        let networkName = "\(network)".lowercased()
                                        let endpoint = Endpoint.sendTx(network: networkName, hash: "\(hash)")
                                        self.networkManager.execute(endpoint.request, completion: { (result, code) in
                                            if result.isSuccess {
                                                response(.success("Success"))
                                            } else {
                                                let error = result.error?.localizedDescription == nil ? "Error" : (result.error?.localizedDescription)!
                                                response(.failure(NSError.init(domain: error, code: 102, userInfo: nil)))
                                            }
                                        })
                                        
                                    }
                                }
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
                    response(.failure(NSError.init(domain: "Parse error", code: 102, userInfo: nil)))
                }
            })
        }
    }
    
//    func executeSmartContract(network: NetworkProvider.WalletType, contract: SmartContractBody, response: @escaping (_ abi: Result<ExecuteMethodModel>) -> ()) {
//        getAccessToken { (result) in
//            let networkName = "\(network)".lowercased()
//            let endpoint = Endpoint.executeSmartContract(network: networkName, contract: contract)
//            self.networkManager.execute(endpoint.request, completion: { (result, code) in
//                print("result = \(result)")
//                if let value = result.value {
//                    let balance = "\(String(describing: value["result"]!))"
//                    response(.success(balance))
//                    
//                } else {
//                    response(.failure(NSError.init(domain: "Parse error", code: 102, userInfo: nil)))
//                }
//            })
//        }
//    }
    
    func changeTrust(amount: Int, response: @escaping (_ response: Result<NativeCoinRawTx>) -> ()) {
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
                        response(.failure(NSError.init(domain: "Parse error", code: 102, userInfo: nil)))
                        
                    }
                }
            }
        }
    }
    
    func changeTrustFunc(amount: Int, response: @escaping (_ response: Result<String>) -> ()) {
        changeTrust(amount: amount) { (data) in
            if let rawTx = data.value?.result?.rawTx {
                let net = NetworkProvider.getNetwork(by: .Stellar)
                let hash = String(decoding: net.signTx(rawTx: rawTx) ?? Data(), as: UTF8.self)
                let networkName = "stellar".lowercased()
                let endpoint = Endpoint.sendTx(network: networkName, hash: "\(hash)")
                self.networkManager.execute(endpoint.request, completion: { (result, code) in
                    if result.isSuccess {
                        response(.success("Success"))
                    } else {
                        let error = result.error?.localizedDescription == nil ? "Error" : (result.error?.localizedDescription)!
                        response(.failure(NSError.init(domain: error, code: 102, userInfo: nil)))
                    }
                })
                
            }
        }
    }
}
