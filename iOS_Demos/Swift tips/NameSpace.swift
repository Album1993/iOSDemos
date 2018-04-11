//
//  NameSpace.swift
//  iOS_Demos
//
//  Created by 张一鸣 on 11/04/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

import Foundation



// 定义泛型类
public final class SCBKit<Base> {
    public let base: Base
    
    public init(member: Base) {
        self.base = member
    }
}

// 定义泛型协议
public protocol SCBKitCompatible {
    associatedtype CompatibleType
    var scb: CompatibleType { get }
    static var scb: CompatibleType.Type {get}
}

// 协议的扩展
public extension SCBKitCompatible {
    public var scb: SCBKit<Self>{
        get { return SCBKit(member:self) }
    }
    
    public static var scb: SCBKit<Self>.Type {
        get { return  SCBKit<Self>.self}
    }
}

// 实现命名空间SCB
extension String: SCBKitCompatible {
    
}

// String命名空间scb中的函数
extension SCBKit where Base == String {
    // MARK: - Localized
    
    /// 国际化值
    public var localized: String {
        return NSLocalizedString(base, comment: "")
    }
    
}


// 使用
let string = "abcd".scb.localized


