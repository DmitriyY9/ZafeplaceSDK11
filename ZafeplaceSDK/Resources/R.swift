//
//  R.swift
//  ZafeplaceSDK
//
//  Created by Dmitriy Zhyzhko on 04.05.2018.
//  Copyright © 2018 Z4. All rights reserved.
//

import Foundation

final class R {
    
    struct string {
        static let unlockDeviceWithFaceId = Bundle.main.localizedString(forKey: "unlock_faceID", value: nil, table: nil)
        static let unlockDeviceWithTouchId = Bundle.main.localizedString(forKey: "unlock_touchID", value: nil, table: nil)
        static let unlockDevice = Bundle.main.localizedString(forKey: "unlock_device", value: nil, table: nil)
        static let noBiometricSensorHasBeenDetected = Bundle.main.localizedString(forKey: "noBiometricSensorHasBeenDetected", value: nil, table: nil)
        static let error = Bundle.main.localizedString(forKey: "error", value: nil, table: nil)
        static let ok = Bundle.main.localizedString(forKey: "ok", value: nil, table: nil)
        static let noAppIdOrAppSecret = Bundle.main.localizedString(forKey: "not_specified_appId_and_secret", value: nil, table: nil)
    }
}
