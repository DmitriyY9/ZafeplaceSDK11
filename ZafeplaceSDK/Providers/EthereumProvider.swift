//
//  EthereumProvider.swift
//  ZafeplaceSDK
//
//  Created by Dmitriy Zhyzhko on 09.05.2018.
//  Copyright © 2018 Z4. All rights reserved.
//

import Foundation
import web3swift
import BigInt

final class EthereumProvider: BaseProvider {
    
    func getAddressInstance() -> Address? {
        let fileDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let keystoreManager = getKeystoreManager(dir: fileDir)
        
        if (keystoreManager?.addresses.count == 0) { return nil }
        else {
            let ethereumKeystore = keystoreManager?.walletForAddress((keystoreManager?.addresses[0])!) as? EthereumKeystoreV3
            return ethereumKeystore?.addresses.first
        }
    }
    
    override func signTx(rawTx: NativeCoinRawTx) -> Data? {
        var hash: Data? = nil
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        if let rawTx = rawTx.result?.rawTx {
            if let gasPrice = rawTx.gasPrice, let gasLimit = rawTx.gasLimit,
                let value = rawTx.value, let nonce = rawTx.nonce, let to = rawTx.to,
                let walletAddress = EthereumProvider().getAddressInstance(), let keystore = EthereumProvider().getKeystoreManager(dir: dir) {
                
                let toWalletAdress = Address.init(to)
                let bigIntGasPrice = BigUInt.init(gasPrice)!
                let bigIntGasLimit = BigUInt.init(gasLimit)
                let bigIntValue = BigUInt.init(value)
                let data = rawTx.data
                var transaction = EthereumTransaction(nonce: BigUInt(nonce),
                                                      gasPrice: bigIntGasPrice,
                                                      gasLimit: bigIntGasLimit,
                                                      to: toWalletAdress,
                                                      value: bigIntValue,
                                                      data: Data.fromHex(data ?? "") ?? Data(),
                                                      v: BigUInt(0),
                                                      r: BigUInt(0),
                                                      s: BigUInt(0))
                
                do {
                    //86e8f463036b2e506c663d968e41a16b07b041ae5436cee227e5b57c8af04fbd
                    try Web3Signer.signTX(transaction: &transaction, keystore: keystore, account: walletAddress, password: BaseProvider.walletPassword)
                    hash = transaction.encode()
                }
                catch {
                    print("Transaction signTx error = \(error)")
                }
            }
        }
        return hash
    }
    
    override func getAddress() -> String? {
        //print("👍 ", String(describing: type(of: self)),":", #function, "\(String(describing: getAddressInstance()?.address))")
       return getAddressInstance()?.address
    }
    
    override func isWalletExist() -> Bool {
        //print("👍 ", String(describing: type(of: self)),":", #function)
        return getPrivateKey() != nil
    }
    
    override func getPublicKey() -> Data? {
        guard let privateKey = getPrivateKey() else { return nil }
        return try! Web3.Utils.privateToPublic(privateKey, compressed: false)
    }
    
    override func getPrivateKey() -> Data? {
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let ks = getKeystoreManager(dir: dir)
        if let address = ks?.addresses.first {
            return try! ks?.UNSAFE_getPrivateKeyData(password: BaseProvider.walletPassword, account: address)
        }
        return nil
    }
    
    override func generateWallet() -> Zafeplace.State {
        
        

        let fileDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let keystoreManager = getKeystoreManager(dir: fileDir)
        
        var ethereumKeystore: EthereumKeystoreV3?
        
        if (keystoreManager?.addresses.count == 0) {
            ethereumKeystore = try! EthereumKeystoreV3(password: BaseProvider.walletPassword)
            
            let keydata = try! JSONEncoder().encode(ethereumKeystore!.keystoreParams)
            FileManager.default.createFile(atPath: fileDir + fielDirectoryName + fileName, contents: keydata, attributes: nil)
        } else {
            ethereumKeystore = keystoreManager?.walletForAddress((keystoreManager?.addresses[0])!) as? EthereumKeystoreV3
        }
        
        guard let sender = ethereumKeystore?.addresses.first else { return .WALLET_NOT_CREATED }
        
        //print("Address = \(sender)")
        //print("Private key hex = \(String(describing: getPrivateKey()?.hexEncodedString()))")
        
        return .WALLET_CREATED
    }
    
     func getKeystoreManager(dir: String) -> KeystoreManager? {
        return KeystoreManager.managerForPath(dir + fielDirectoryName)
    }
}

