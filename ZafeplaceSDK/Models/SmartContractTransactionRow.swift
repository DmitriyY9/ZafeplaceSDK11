//
//  SmartContractTransactionRow.swift
//  ZafeplaceSDK
//
//  Created by Dmitriy Zhyzhko on 23.06.2018.
//  Copyright © 2018 Z4. All rights reserved.
//

import Foundation


class SmartContractTransactionRow: Codable {
    var result: Result?
    
    class Result: Codable {
         var abi: [Abi]?
    }
}

public class Abi: Codable {
    var anonymous: Bool?
    var inputs: [Input]?
    var name: String?
    var type: String?
    var constant: Bool?
    var outputs: [Output]?
    var payable: Bool?
    var stateMutability: String?
    
    class Input: Codable {
        var indexed: Bool?
        var name: String?
        var type: String?
    }
    
    class Output: Codable {
        var name: String?
        var type: String?
    }
}

