//
//  StellarModel.swift
//  ZafeplaceSDK
//
//  Created by Максим Власенко on 11/8/18.
//  Copyright © 2018 Z4. All rights reserved.
//

import Foundation
import stellarsdk

struct StellarModel: Codable {
    let accountID: String
    let secretSeed: String
    let accUInt: [UInt8]
    let secrUInt: [UInt8]
}
