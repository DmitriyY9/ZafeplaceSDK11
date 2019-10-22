//
//  PincodeViewController.swift
//  ZafeplaceSDK
//
//  Created by Dmitriy Zhyzhko on 25.06.2018.
//  Copyright © 2018 Z4. All rights reserved.
//

import Foundation
import UIKit

class PincodeViewController: UIViewController {
    @IBOutlet weak var pincodeTextField: UITextField!
    
    @IBAction func fingerPrintPressed(_ sender: Any) {
        guard let text = pincodeTextField.text,
        let pinFromText = Int(text) else { return }
        
        let pincode = UserDefaults.standard.integer(forKey: "pin")
        print("pin = \(pincode)")
        
        if pincode != 0 {
            if pincode == pinFromText {
                auth(pin: String(pincode))
            } else {
                let alert = UIAlertController(title: "Alert", message: "Wrong pincode!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            auth(pin: String(pinFromText))
        }
    }
    
    func auth(pin: String) {
        Zafeplace.default.user().authenticate(type: .PIN(pin)) { (state, type) in
            print("Auth state = \(type)")
            if type == .WRONG_PIN_CODE_NUMBER_COUNT {
                let alert = UIAlertController(title: "Alert", message: "Wrong pincode number, must be >= 4", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                UserDefaults.standard.set(pin, forKey: "pin")
                self.openMainVC()
            }
        }
    }
    
    func openMainVC() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        vc.isPinCodeStyle = true
        self.present(vc, animated: true, completion: nil)
    }
}
