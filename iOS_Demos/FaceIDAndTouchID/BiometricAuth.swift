//
//  BiometricAuth.swift
//  iOS_Demos
//
//  Created by 张一鸣 on 2018/5/23.
//  Copyright © 2018 张一鸣. All rights reserved.
//

import Foundation
import LocalAuthentication

public final class BiometricAuth {
    
    public var supportedBiometry: BiometrySupport {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            if #available(iOS 11.0, *) {
                switch context.biometryType {
                case .faceID:
                    return .available(.faceID)
                case .touchID:
                    return .available(.touchID)
                    // NOTE: LABiometryType.none was introduced in iOS 11.2
                    // which is why it can't be used here even though Xcode
                // errors with "non-exhaustive switch" if you don't use it 🤷🏼‍♀️
                default:
                    return .none
                }
            }
            
            return .available(.touchID)
        }
        
        // NOTE: despite what Apple Docs state, the biometryType
        // property *is* set even if canEvaluatePolicy fails
        // See: http://www.openradar.me/36064151
        if let error = error {
            let code = LAError(_nsError: error as NSError).code
            if #available(iOS 11.0, *) {
                switch (code, context.biometryType) {
                case (.biometryLockout, .faceID):
                    return .lockedOut(.faceID)
                case (.biometryLockout, .touchID):
                    return .lockedOut(.touchID)
                case (.biometryNotAvailable, .faceID), (.biometryNotEnrolled, .faceID):
                    return .notAvailable(.faceID)
                case (.biometryNotAvailable, .touchID), (.biometryNotEnrolled, .touchID):
                    return .notAvailable(.touchID)
                default:
                    return .none
                }
            } else {
                switch code {
                case .touchIDLockout:
                    return .lockedOut(.touchID)
                case .touchIDNotEnrolled, .touchIDNotAvailable:
                    return .notAvailable(.touchID)
                default:
                    return .none
                }
            }
        }
        
        return .none
    }
}
