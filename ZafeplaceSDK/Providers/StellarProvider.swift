//
//  StellarProvider.swift
//  ZafeplaceSDK
//
//  Created by Максим Власенко on 11/6/18.
//  Copyright © 2018 Z4. All rights reserved.
//

import Foundation
import stellarsdk

final class StellarProvider: BaseProvider {
    private let defaults = UserDefaults.standard
    private let sdk = Zafeplace.default

    private func getAddressInstance() -> StellarModel? {
        var model: StellarModel?
        if let savedStellar = defaults.object(forKey: "savedStellar") as? Data {
            let decoder = JSONDecoder()
            if let loadedStellat = try? decoder.decode(StellarModel.self, from: savedStellar) {
                //print("👍 ", String(describing: type(of: self)),":", #function, " ","\(loadedStellat)")
                model = loadedStellat
            }
        }
        return model
    }
    
    override func signTx(rawTx: NativeCoinRawTx) -> Data? {
        if let rawTx = rawTx.result?.xdr {
            let envelope = try! TransactionEnvelopeXDR(xdr: rawTx)
            let tx = envelope.tx
            let trnsactionHash = try! [UInt8](tx.hash(network: .testnet))
            let keyPair = try! KeyPair(publicKey: getAddressInstance()?.accUInt ?? [UInt8](), privateKey: getAddressInstance()?.secrUInt ?? [UInt8]())
            let userSignature = keyPair.signDecorated(trnsactionHash)
            envelope.signatures.append(userSignature)
            let xdrEncodedEnvelope = envelope.xdrEncoded
            
            return xdrEncodedEnvelope?.data(using: .utf8)
        }
        return nil
    }
    
    override func getAddress() -> String? {
        //print("👍 ", String(describing: type(of: self)),":", #function, "\(String(describing: getAddressInstance()?.accountID))")
        return getAddressInstance()?.accountID
    }
    
    override func isWalletExist() -> Bool {
        //print("👍 ", String(describing: type(of: self)),":", #function)
        return getPrivateKey() != nil
    }
    
    override func getPublicKey() -> Data? {
        if let savedStellarPK = defaults.object(forKey: "savedStellar") as? Data {
            let decoder = JSONDecoder()
            if let loadedStellar = try? decoder.decode(StellarModel.self, from: savedStellarPK) {
                //print("👍 ", String(describing: type(of: self)),":", #function, " ","\(loadedStellar.accountID)")
                return savedStellarPK
            }
        }
        return Data()
    }
    
    override func getPrivateKey() -> Data? {
        if let savedStellarPK = defaults.object(forKey: "savedStellar") as? Data {
            let decoder = JSONDecoder()
            if (try? decoder.decode(StellarModel.self, from: savedStellarPK)) != nil {
               //print("👍 ", String(describing: type(of: self)),":", #function, " ","\(loadedStellatPK.secretSeed)")
               return savedStellarPK
            }
        }
        return nil
    }
    
    @discardableResult
    override func generateWallet() -> Zafeplace.State {
        // create a completely new and unique pair of keys.
        let keyPair = try! KeyPair.generateRandomKeyPair()
        let stellat = StellarModel(accountID: keyPair.accountId, secretSeed: keyPair.secretSeed, accUInt: keyPair.publicKey.bytes, secrUInt: keyPair.privateKey?.bytes ?? [UInt8]())
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(stellat) {
            defaults.set(encoded, forKey: "savedStellar")
        }
        
        #if DEBUG
        //print("👍 ", String(describing: type(of: self)),":", #function, " ", "Account Id: " + keyPair.accountId)
        #endif
        //print("👍 ", String(describing: type(of: self)),":", #function, " ", "Secret Seed: " + keyPair.secretSeed)
        return .WALLET_CREATED
    }
}


