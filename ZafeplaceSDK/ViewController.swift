//
//  ViewController.swift]
//  ZafeplaceSDK
//
//  Created by Dmitriy Zhyzhko on 03.05.2018.
//  Copyright © 2018 Z4. All rights reserved.
//

import UIKit
import web3swift
import BigInt

class ViewController: UIViewController {
    @IBOutlet weak var pinHashTextField: UITextField!
    let zafeplace = Zafeplace.default
    override func viewDidLoad() {
        super.viewDidLoad()
        Zafeplace.generateAccessToken(appId: "291377603636896", appSecret: "698940504ca9c2353f2494299926694f")
    }
    @IBAction func generateWallet(_ sender: UIButton) {
    }
    
    @IBAction func transforToHash(_ sender: UIButton) {
        
        if let pinHash = pinHashTextField.text {
            let x = Zafeplace.default.setPinHash(pinHash)
            print("\(x)")
        }
    }
    
    @IBAction func fingerprintPressed(_ sender: Any) {
        Zafeplace.default.user().authenticate(type: .TOUCH) { (state, type) in
            print("type = \(type)")
            if type == .SUCCESS {
                DispatchQueue.main.async {
                    UserDefaults.standard.set("00000", forKey: "pin")
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                    vc.isPinCodeStyle = false
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func pinCodePressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PincodeViewController")
        self.present(vc!, animated: true, completion: nil)
    }
}
