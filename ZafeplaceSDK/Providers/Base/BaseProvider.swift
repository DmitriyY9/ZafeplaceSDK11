//
//  BaseProvider.swift
//  ZafeplaceSDK
//
//  Created by Dmitriy Zhyzhko on 09.05.2018.
//  Copyright © 2018 Z4. All rights reserved.
//

import Foundation

/// Protocol for each type of the wallet provider
protocol BaseProviderProtocol {
    func generateWallet() -> Zafeplace.State
    func signTx(rawTx: NativeCoinRawTx) -> Data?
    func getPrivateKey() -> Data?
    func getPublicKey() -> Data?
    func getAddress() -> String?
    func isWalletExist() -> Bool
}

class BaseProvider: BaseProviderProtocol {

    static let walletPassword = "ZAFEPLACESDKPASSWORD"
    let fileName = "/key.json"
    let fielDirectoryName = "/keystore"
    
    func generateWallet() -> Zafeplace.State { return .WALLET_NOT_CREATED }
    func getAddress() -> String? { return nil }
    func getPrivateKey() -> Data? { return nil }
    func getPublicKey() -> Data? { return nil }
    func isWalletExist() -> Bool { return false }
    func signTx(rawTx: NativeCoinRawTx) -> Data? { return nil }
}
