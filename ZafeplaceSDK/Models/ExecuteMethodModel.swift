//
//  ExecuteMethodModel.swift
//  ZafeplaceSDK
//
//  Created by Максим Власенко on 3/28/19.
//  Copyright © 2019 Z4. All rights reserved.
//

import Foundation

struct ExecuteMethodModel: Codable {
    var network: String?
    var result: Result?
    
    struct Result: Codable {
        var sender: String?
        var const: Bool?
        var rawTx: RawTx?
        var popup: String?
    }
    
    struct RawTx: Codable {
        
        var from: String?
        var to: String?
        var gasPrice: String?
        var gasLimit: Int?
        var nonce: Int?
        var value: Int?
        var chainId: Int?
        var data: String?
        
        private enum CodingKeys: String, CodingKey {
            case from = "from",
            to = "to",
            gasPrice = "gasPrice",
            gasLimit = "gasLimit",
            nonce = "nonce",
            value = "value",
            chainId = "chainId",
            data = "data"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            from = try? container.decode(String.self, forKey: .from)
            to = try? container.decode(String.self, forKey: .to)
            gasLimit = try? container.decode(Int.self, forKey: .gasLimit)
            nonce = try? container.decode(Int.self, forKey: .nonce)
            value = try? container.decode(Int.self, forKey: .value)
            data = try? container.decode(String.self, forKey: .data)
            if let value = try? container.decode(Int.self, forKey: .gasPrice) {
                gasPrice = String(value)
            } else {
                gasPrice = try? container.decode(String.self, forKey: .gasPrice)
            }
        }
    }
}







/*
 {
 "network": "ethereum",
 "result": {
 "constant": false,
 "rawTx": {
 "from": "0x41B964C9E439d5d5e06c30BA24DC3F9A53844C9A",
 "nonce": 111,
 "gasPrice": 1000000000,
 "gasLimit": 3000000,
 "to": "0xD0d8D1045413A31b164Ac965FcA42f4BE1AE5360",
 "data": "0xa9059cbb000000000000000000000000b7a66bef08da07a78c8a8284b873f976967d40520000000000000000000000000000000000000000000000000000000000007530",
 "value": 0,
 "chainId": 3
 },
 "sender": "0x41B964C9E439d5d5e06c30BA24DC3F9A53844C9A",
 "popup": "- Information about transaction:\n - ethereum\n - Token information : \n  - Which account the apps to sign the transaction : 0x41B964C9E439d5d5e06c30BA24DC3F9A53844C9A\n  - Which Smart Contract : 0xD0d8D1045413A31b164Ac965FcA42f4BE1AE5360\n  - The function name : transfer\n  - All inputs : [{\"name\":\"to\",\"value\":\"0xb7A66BEf08DA07a78c8a8284B873f976967D4052\"},{\"name\":\"tokens\",\"value\":30000}]\n  - Transaction Fee : 3000000000000000"
 }
 }
 */
