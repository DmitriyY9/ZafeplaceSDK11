//
//  SmartContractBody.swift
//  ZafeplaceSDK
//
//  Created by Dmitriy Zhyzhko on 23.06.2018.
//  Copyright © 2018 Z4. All rights reserved.
//

import Foundation

struct SmartContractBody: Codable {
    var sender: String?
    var methodName: String?
    var methodParams: String?
}
