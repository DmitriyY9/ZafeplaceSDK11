//
//  TokenBalance.swift
//  ZafeplaceSDK
//
//  Created by Dmitriy Zhyzhko on 18.06.2018.
//  Copyright © 2018 Z4. All rights reserved.
//

import Foundation

struct TokenBalanceResponse: Codable {
    var network: String?
    var result: [TokenBalance]
    var constant = false
}

 struct TokenBalance: Codable, CustomStringConvertible {
    var balance: String?
    var asset_type: String?
    
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        balance = try values.decode(String.self, forKey: .balance)
//        assetType = try values.decode(String.self, forKey: .asset_type)
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case balance
//        case asset_type = "asset_type"
//    }
    
    var description: String {
        return "Balance: \(balance!), AssetType: \(asset_type!)"
    }
}
