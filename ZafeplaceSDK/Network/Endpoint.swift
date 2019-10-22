//
//  Endpoint.swift
//  Vibe
//
//  Created by Z4
//  Copyright © 2018 Dmitriy Zhyzhko. All rights reserved.
//

import UIKit

enum Endpoint {
    case getAccessToken(appId: String, appSecret: String)
    case getBalance(network: String, address: String)
    case getTokenBalance(network: String, address: String)
    case nativeCoinRawTx(network: String, sender: String, recipient: String, amount: Double, gasLimit: Int, gasPrice: Int)
    case sendTx(network: String, hash: String)
    case tokenTransferRawTx(network: String, sender: String, recipient: String, amount: Double, gasLimit: Int, gasPrice: Int)
    case getContractAbi(network: String)
    case executeSmartContract(network: String, contract: SmartContractBody)
    case changeTrust(network: String, recipient: String, amount: Double)
    
    static var urlComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "35.233.100.41"
        components.port = 3000
        return components
    }
    
    fileprivate enum Method: String {
        case post = "POST"
        case get = "GET"
        case put = "PUT"
    }
}

extension Endpoint {
    
    var request: URLRequest {
        var components = Endpoint.urlComponents
        let method: Method
        let path: String
        var params: [String: Any] = [:]
        var queryItems: [URLQueryItem]?
        
        switch self {
            
            case .getAccessToken(let appId, let appSecret):
                queryItems = [
                    URLQueryItem(name: "appId", value: appId),
                    URLQueryItem(name: "appSecret", value: appSecret)
                ]

                path = "api/v1/sdk/session/login"
                method = .get
            
            case .getBalance(let network, let address):
                
                queryItems = [URLQueryItem(name: "address", value: address)]

                path = String(format:"api/v1/sdk/%@/account/balance", network)
                method = .get
            
            case .getTokenBalance(let network, let address):

                queryItems = [URLQueryItem(name: "address", value: address)]
            
                path = String(format:"api/v1/sdk/%@/account/token-balance", network)
                method = .get
            
            case .nativeCoinRawTx(let network, let sender, let recipient, let amount, let gasLimit, let gasPrice):
                queryItems = [
                    URLQueryItem(name: "sender", value: sender),
                    URLQueryItem(name: "recipient", value: recipient),
                    URLQueryItem(name: "amount", value: String(amount)),
                    URLQueryItem(name: "gasLimit", value: String(gasLimit)),
                    URLQueryItem(name: "gasPrice", value: String(gasPrice)),
                ]
            
                path = String(format:"api/v1/sdk/%@/account/native-coin-raw-transaction", network)
                method = .get
            
        case .sendTx(let network, let hash):
                path = String(format:"api/v1/sdk/%@/account/send-transaction", network)
                method = .post
                params = ["signTx" : hash]
                //queryItems = [URLQueryItem(name: "signTx", value: hash)]
                         //URLQueryItem(name: "recipient", value: recipient)
            
            
            case .tokenTransferRawTx(let network, let sender, let recipient, let amount, let gasLimit, let gasPrice):
                queryItems = [
                    URLQueryItem(name: "sender", value: sender),
                    URLQueryItem(name: "recipient", value: recipient),
                    URLQueryItem(name: "amount", value: String(amount)),
                    URLQueryItem(name: "gasLimit", value: String(gasLimit)),
                    URLQueryItem(name: "gasPrice", value: String(gasPrice)),
                ]
            
                path = String(format:"api/v1/sdk/%@/account/token-raw-transaction", network)
                method = .get
            
            case .getContractAbi(let network):
                path = String(format:"api/v1/sdk/%@/contract/abi", network)
                method = .get
            
            case .executeSmartContract(let network, let contract):
                path = String(format:"api/v1/sdk/%@/contract/execute-method", network)
                method = .post
            
                params = ["sender" : contract.sender,
                          "methodName" : contract.methodName,
                          "methodParams" : contract.methodParams]
            
            case .changeTrust(let network, let recipient, let amount):
                path = String(format:"api/v1/sdk/%@/account/change-trust", network)
                method = .get
                
                queryItems = [
                    URLQueryItem(name: "network", value: network),
                    URLQueryItem(name: "recipient", value: recipient),
                    URLQueryItem(name: "limit", value: "\(amount)")
                ]
        }
        
        components.path = "/\(path)"
        components.queryItems = queryItems

        var request: URLRequest = .init(url: components.url!)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.token {
            request.setValue("\(token)", forHTTPHeaderField: "Authorization")
        }

        switch method {
        case .post:
            request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: [])
            request.httpMethod = "POST"
        case .put:
            if params.count > 0  {
                request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: [])
            }
            request.httpMethod = "PUT"

        case .get:
       
            break
        }

        print("👍 ", String(describing: type(of: self)),":", #function)
        print(request)
        print(request.allHTTPHeaderFields!)

        
        if request.httpMethod != Method.get.rawValue {
            print("👍 ", String(describing: type(of: self)),":", #function, " ", params as NSDictionary)
        }


        return request
    }
}
