//
//  BiometrySupport.swift
//  iOS_Demos
//
//  Created by 张一鸣 on 2018/5/23.
//  Copyright © 2018 张一鸣. All rights reserved.
//

import Foundation

public enum BiometrySupport {
    public enum Biometry {
        case touchID
        case faceID
    }
    
    case available(Biometry)
    case lockedOut(Biometry)
    case notAvailable(Biometry)
    case none
    
    public var biometry: Biometry? {
        switch self {
        case .none, .lockedOut, .notAvailable:
            return nil
        case let .available(biometry):
            return biometry
        }
    }
}
