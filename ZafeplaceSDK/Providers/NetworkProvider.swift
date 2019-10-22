//
//  WalletProvider.swift
//  ZafeplaceSDK
//
//  Created by Dmitriy Zhyzhko on 09.05.2018.
//  Copyright © 2018 Z4. All rights reserved.
//

import Foundation

final class NetworkProvider {
    
    enum WalletType: Int {
        case Ethereum
        case Stellar
        
        static var allTypes: [WalletType] {
            var i = 0
            return Array(AnyIterator {
                let newEnum = WalletType(rawValue: i)
                i += 1
                return newEnum
            })
        }
    }
    
    static func generateWallet(type: WalletType) -> Zafeplace.State {
        switch type {
            case .Ethereum:
                return EthereumProvider().generateWallet()
            case .Stellar:
                return StellarProvider().generateWallet()
        }
    }
    
    static func getWalletAddress(type: WalletType) -> String? {
        switch type {
        case .Ethereum:
            return EthereumProvider().getAddress()
        case .Stellar:
            return StellarProvider().getAddress()
        }
    }
    
    /// Get network instance by type
    ///
    /// - Parameter type: wallet type
    /// - Returns: return instance
    static func getNetwork(by type: NetworkProvider.WalletType) -> BaseProvider {
        switch type {
        case .Ethereum:
            return EthereumProvider()
        case .Stellar:
            return StellarProvider()
        }
    }
}
