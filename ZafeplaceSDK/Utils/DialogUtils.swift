//
//  DialogUtils.swift
//  ZafeplaceSDK
//
//  Created by Dmitriy Zhyzhko on 04.05.2018.
//  Copyright © 2018 Z4. All rights reserved.
//

import Foundation
import UIKit

final class DialogUtils {
    
    static func showAlertNoBiometricSensorHasBeenDetected(to vc: UIViewController) {
        showAlertWithTitle(title: R.string.error, message: R.string.noBiometricSensorHasBeenDetected, to: vc)
    }
    
    fileprivate static func showAlertWithTitle(title: String, message: String, to vc: UIViewController) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: R.string.ok, style: .default, handler: nil))
        
        DispatchQueue.main.async() { () -> Void in
            vc.present(alertVC, animated: true, completion: nil)
        }
    }
}
