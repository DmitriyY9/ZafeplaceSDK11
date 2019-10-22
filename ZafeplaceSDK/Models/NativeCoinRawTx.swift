//
//  NativeCoinRawTx.swift
//  ZafeplaceSDK
//
//  Created by Dmitriy Zhyzhko on 18.06.2018.
//  Copyright © 2018 Z4. All rights reserved.
//

import Foundation
import BigInt

struct NativeCoinRawTx: Codable {
    var network: String?
    var constant = false
    var result: Result?
    
    
    struct Result: Codable {
        var sender: String?
        var recipient: String?
        var rawTx: RawTx?
        var popup: String?
        var xdr: String?
    }

    struct RawTx: Codable {
            var from: String?
            var to: String?
            var gasPrice: String?
            var gasLimit: Int?
            var nonce: Int?
            var value: Int?
            var rawTx: String?
            var chainId: Int?
            var data: String?
            
            private enum CodingKeys: String, CodingKey {
                case from = "from",
                to = "to",
                gasPrice = "gasPrice",
                gasLimit = "gasLimit",
                nonce = "nonce",
                value = "value",
                rawTx = "rawTx",
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
                rawTx = try? container.decode(String.self, forKey: .rawTx)
                data = try? container.decode(String.self, forKey: .data)
                if let value = try? container.decode(Int.self, forKey: .gasPrice) {
                    gasPrice = String(value)
                } else {
                    gasPrice = try? container.decode(String.self, forKey: .gasPrice)
                }
            }
    }
}
