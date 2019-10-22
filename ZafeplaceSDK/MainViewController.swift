//
//  MainViewController.swift
//  ZafeplaceSDK
//
//  Created by Dmitriy Zhyzhko on 25.06.2018.
//  Copyright © 2018 Z4. All rights reserved.
//

import Foundation
import UIKit
import LocalAuthentication
import stellarsdk

class MainViewController: UIViewController {
    
    @IBOutlet weak var transNumber: UITextField!
    @IBOutlet weak var tokenTrans: UITextField!
    @IBOutlet weak var wrapView: UIView!
    @IBOutlet weak var limitTextField: UITextField!
    
    let sdk = Zafeplace.default
    let stellarSDK = StellarSDK()
    
    var isPinCodeStyle = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        Zafeplace.generateAccessToken(appId: "291377603636896", appSecret: "698940504ca9c2353f2494299926694f")
    }
    
    @IBAction func logOut(_ sender: Any) {
        UserDefaults.standard.set(0, forKey: "pin")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController")
        self.present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func generateWallet(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Alert", message: "Choose currency", preferredStyle: UIAlertControllerStyle.alert)
        let execution = { [weak self] (_ walletType: NetworkProvider.WalletType) -> Void in
            guard let `self` = self else { return }
            if self.sdk.isWalletCreated(type: walletType) {
                let alert = UIAlertController(title: "Alert", message: "Wallet already created!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.wrapView.isHidden = false
                self.sdk.generateWallet(walletType: walletType) { (address) in
                    print("NEW CLOSURE ___________ \(address)")
                }
                self.wrapView.isHidden = true
//                self.sdk.generateWallet(walletType) { (state) in
//                    self.wrapView.isHidden = true
//                    print("STATE = \(state)")
//                    let alert = UIAlertController(title: "Alert", message: "Wallet was successfully created!", preferredStyle: UIAlertControllerStyle.alert)
//                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
//                }
            }
        }
        alertController.addAction(UIAlertAction(title: "Ethereum", style: .default) { _ in execution(.Ethereum) })
        alertController.addAction(UIAlertAction(title: "Stellar", style: .default) { _ in execution(.Stellar) })
        self.present(alertController, animated: true, completion: nil)
//        if isPinCodeStyle {
//           pin()
//        } else {
//           touch()
//        }
    }
    
    @IBAction func getBalance(_ sender: Any) {
        let alertController = UIAlertController(title: "Alert", message: "Choose currency", preferredStyle: UIAlertControllerStyle.alert)
        let execution = { [weak self] (_ walletType: NetworkProvider.WalletType) -> Void in
            guard let `self` = self else { return }
            if !self.sdk.isWalletCreated(type: walletType) {
                let alert = UIAlertController(title: "Wallet", message: "Please generate a wallet at first", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.wrapView.isHidden = false
            self.sdk.getWalletBalance(network: walletType) { (result) in
                self.wrapView.isHidden = true
                let alert = UIAlertController(title: "Wallet", message: "Balance = \(result.value!)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        alertController.addAction(UIAlertAction(title: "Ethereum", style: .default) { _ in execution(.Ethereum) })
        alertController.addAction(UIAlertAction(title: "Stellar", style: .default) { _ in execution(.Stellar) })
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func getTokenBalance(_ sender: Any) {
        let alertController = UIAlertController(title: "Alert", message: "Choose currency", preferredStyle: UIAlertControllerStyle.alert)
        let execution = { [weak self] (_ walletType: NetworkProvider.WalletType) -> Void in
            guard let `self` = self else { return }
            if !self.sdk.isWalletCreated(type: walletType) {
                let alert = UIAlertController(title: "Wallet", message: "Please generate a wallet at first", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.wrapView.isHidden = false
            self.sdk.getTokenBalance(network: walletType) { (result) in
                self.wrapView.isHidden = true
                switch result {
                case .success(_):
                    let alert = UIAlertController(title: "Wallet", message: "\(result.value!)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                case .failure(_):
                    let alert = UIAlertController(title: "Wallet", message: "\(result.error!)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        alertController.addAction(UIAlertAction(title: "Ethereum", style: .default) { _ in execution(.Ethereum) })
        alertController.addAction(UIAlertAction(title: "Stellar", style: .default) { _ in execution(.Stellar) })
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func createTran(_ sender: Any) {
        let alertController = UIAlertController(title: "Alert", message: "Choose currency", preferredStyle: UIAlertControllerStyle.alert)
        let execution = { [weak self] (_ walletType: NetworkProvider.WalletType) -> Void in
            guard let `self` = self else { return }
            if (self.transNumber.text?.isEmpty)! {
                let alert = UIAlertController(title: "Wallet", message: "Input nubmer", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
                
            } else if !self.sdk.isWalletCreated(type: walletType) {
                let alert = UIAlertController(title: "Wallet", message: "Please generate a wallet at first", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            if walletType == .Ethereum {
                if let sender = self.sdk.wallet(type: walletType).getAddress() {
                    if let transNumber = self.transNumber.text {
                        if let transInt = Double(transNumber) {
                            self.sdk.createTransaction(network: walletType, sender: sender, recipient: "0x41B964C9E439d5d5e06c30BA24DC3F9A53844C9A", amount: transInt) { (result) in
                                self.wrapView.isHidden = true
                                if result.isSuccess {
                                    let alert = UIAlertController(title: "Wallet", message: "\(String(describing: result.value))", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                } else {
                                    let alert = UIAlertController(title: "Wallet", message: "The operation couldn’t be completed. Returned error: insufficient funds for gas * price + value", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            } else {
                if let sender = self.sdk.wallet(type: walletType).getAddress() {
                    if let transNumber = self.transNumber.text {
                        if let transInt = Double(transNumber) {
                            self.sdk.createTransaction(network: walletType, sender: sender, recipient: "GB2I7LFQ5HODVFT65XZAFRWBWX3XBBN6JYTJS3I6XPFJKD2VQKV56JFI", amount: transInt) { (result) in
                                self.wrapView.isHidden = true
                                if result.isSuccess {
                                    let alert = UIAlertController(title: "Wallet", message: "\(String(describing: result.value))", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                } else {
                                    let alert = UIAlertController(title: "Wallet", message: "The operation couldn’t be completed. Returned error: insufficient funds for gas * price + value", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
        }
        alertController.addAction(UIAlertAction(title: "Ethereum", style: .default) { _ in execution(.Ethereum) })
        alertController.addAction(UIAlertAction(title: "Stellar", style: .default) { _ in execution(.Stellar) })
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func getTokenTrans(_ sender: Any) {
        let alertController = UIAlertController(title: "Alert", message: "Choose currency", preferredStyle: UIAlertControllerStyle.alert)
        let execution = { [weak self] (_ walletType: NetworkProvider.WalletType) -> Void in
            guard let `self` = self else { return }
            if (self.tokenTrans.text?.isEmpty)! {
                let alert = UIAlertController(title: "Wallet", message: "Input nubmer", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
                
            } else if !self.sdk.isWalletCreated(type: walletType) {
                let alert = UIAlertController(title: "Wallet", message: "Please generate a wallet at first", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.wrapView.isHidden = false
            if walletType == .Ethereum {
                if let sender = self.sdk.wallet(type: walletType).getAddress() {
                    if let transNumber = self.tokenTrans.text {
                        if let transInt = Double(transNumber) {
                            self.sdk.createTransactionToken(network: walletType, sender: sender, recipient: "0x41B964C9E439d5d5e06c30BA24DC3F9A53844C9A", amount: transInt) { (result) in
                                self.wrapView.isHidden = true
                                if result.isSuccess {
                                    let alert = UIAlertController(title: "Wallet", message: "\(String(describing: result.value))", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                } else {
                                    let alert = UIAlertController(title: "Wallet", message: "The operation couldn’t be completed. Returned error: insufficient funds for gas * price + value", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            } else {
                if let sender = self.sdk.wallet(type: walletType).getAddress() {
                    if let transNumber = self.tokenTrans.text {
                        if let transInt = Double(transNumber) {
                            self.sdk.createTransactionToken(network: walletType, sender: sender, recipient: "GD44FXG36FHJKWK2P56UBMF7QCMUIKGRSGGC7MEJAPWYKECIHN3VJU3R", amount: transInt) { (result) in
                                self.wrapView.isHidden = true
                                if result.isSuccess {
                                    let alert = UIAlertController(title: "Wallet", message: "\(String(describing: result.value))", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                } else {
                                    let alert = UIAlertController(title: "Wallet", message: "The operation couldn’t be completed. Returned error: insufficient funds for gas * price + value", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }

        }
        alertController.addAction(UIAlertAction(title: "Ethereum", style: .default) { _ in execution(.Ethereum) })
        alertController.addAction(UIAlertAction(title: "Stellar", style: .default) { _ in execution(.Stellar) })
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func getList(_ sender: Any) {
       if !sdk.isWalletCreated(type: .Ethereum) {
            let alert = UIAlertController(title: "Wallet", message: "Please generate a wallet at first", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        wrapView.isHidden = false
        sdk.getSmartContractTransactionRaw(network: .Ethereum) { (result) in
            if let value = result.value {
                let list = value!.map { $0.name }
                let res = list.filter { $0 != nil }
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ListOfAdressesViewController") as! ListOfAdressesViewController
                vc.array = res
                self.wrapView.isHidden = true
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func testButtonGenStellar(_ sender: UIButton) {
        if let limit = limitTextField.text {
            if let limitInt = Double(limit) {
                sdk.changeTrust(amount: limitInt) { (result) in
                    print("CHANGE_TRUST: Result = \(result)")
                }
        }
    }
}
    
    @IBAction func executeMethod(_ sender: Any) {
        if !sdk.isWalletCreated(type: .Ethereum) {
            let alert = UIAlertController(title: "Wallet", message: "Please generate a wallet at first", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if let sender = sdk.wallet(type: .Ethereum).getAddress() {
            wrapView.isHidden = false
            let params = "[{\"name\":\"tokenOwner\",\"value\":\"0xb7A66BEf08DA07a78c8a8284B873f976967D4052\"}]"
            let body = SmartContractBody(sender: sender, methodName: "balanceOf", methodParams: params)
            sdk.executeSmartContractMethod(network: .Ethereum, contract: body) { (result) in
                self.wrapView.isHidden = true
                var val = ExecuteMethodModel()
                if let newVal = result.value {
                    val = newVal
                }
                let alert = UIAlertController(title: "Wallet", message: "Result token balance = \(val)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func pin() {
        let alert = UIAlertController(title: "Wallet", message: "Enter pin code", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let pin = String(UserDefaults.standard.integer(forKey: "pin"))
            let textPin = alert?.textFields![0].text // Force unwrapping because we know it exists.
            
            if pin == textPin {
                self.createWall()
            } else {
                let alert = UIAlertController(title: "Wallet", message: "Wrong pincode!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func touch() {
        var error: NSError? // Create error reference
        let authContext = LAContext() // Create a authentication context
        
        // Check device biometryType
        var localizedReason = R.string.unlockDevice
        if #available(iOS 11.0, *) {
            switch authContext.biometryType {
            case .faceID: localizedReason = R.string.unlockDeviceWithFaceId
            case .none: fallthrough
            case .touchID: localizedReason = R.string.unlockDeviceWithTouchId
            }
        }
        
        // Check if the device has a fingerprint sensor
        // If not, show the user an alert view and bail out!
        guard authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return
        }
        
        // Check the fingerprint
        authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReason, reply: {
            (success, error) -> Void in
            
            if error != nil {
               // result(success, .TOUCH_ID_RETRY_EXCEEDED)
                return
            }
            
            //UserDefaults.save(key: .AUTHORIZATION, value: true)
            //result(success, .SUCCESS)
            DispatchQueue.main.async {
                self.createWall()
            }
        })
    }
    
    func createWall() {
        let alertController = UIAlertController(title: "Alert", message: "Choose currency", preferredStyle: UIAlertControllerStyle.alert)
        let execution = { [weak self] (_ walletType: NetworkProvider.WalletType) -> Void in
            guard let `self` = self else { return }
            if self.sdk.isWalletCreated(type: walletType) {
                let alert = UIAlertController(title: "Alert", message: "Wallet already created!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.wrapView.isHidden = false
                self.sdk.createNewWallet(type: walletType) { (state) in
                    self.wrapView.isHidden = true
                    print("STATE = \(state)")
                    let alert = UIAlertController(title: "Alert", message: "Wallet was successfully created!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        alertController.addAction(UIAlertAction(title: "Ethereum", style: .default) { _ in execution(.Ethereum) })
        alertController.addAction(UIAlertAction(title: "Stellar", style: .default) { _ in execution(.Stellar) })
        self.present(alertController, animated: true, completion: nil)
    }
    
    func checkIfAuth() {

    }
}

extension MainViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
