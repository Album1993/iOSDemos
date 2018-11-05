//
//  MultiDelegate.swift
//  iOS_Demos
//
//  Created by 张一鸣 on 2018/10/22.
//  Copyright © 2018 张一鸣. All rights reserved.
//

import UIKit


protocol MasterOrderDelegate: class {
    func toEat(_ food: String)
}

class masterOrderDelegateManager : MasterOrderDelegate {
    
//    1. NSHashTable中的元素可以通过Hashable协议来判断是否相等.
//    2. NSHashTable中的元素如果是弱引用,对象销毁后会被移除,可以避免循环引用.
    private let multiDelegate: NSHashTable<AnyObject> = NSHashTable.weakObjects()
    
    init(_ delegates: [MasterOrderDelegate]) {
        delegates.forEach(multiDelegate.add)
    }
    
    // 协议中的方法,可以有多个
    func toEat(_ food: String) {
        invoke { $0.toEat(food) }
    }
    
    // 添加遵守协议的类
    func add(_ delegate: MasterOrderDelegate) {
        multiDelegate.add(delegate)
    }
    
    // 删除指定遵守协议的类
    func remove(_ delegateToRemove: MasterOrderDelegate) {
        invoke {
            if $0 === delegateToRemove as AnyObject {
                multiDelegate.remove($0)
            }
        }
    }
    
    // 删除所有遵守协议的类
    func removeAll() {
        multiDelegate.removeAllObjects()
    }
    
    // 遍历所有遵守协议的类
    private func invoke(_ invocation: (MasterOrderDelegate) -> Void) {
        for delegate in multiDelegate.allObjects.reversed() {
            invocation(delegate as! MasterOrderDelegate)
        }
    }
}
class Master {
    weak var delegate: MasterOrderDelegate?
    func orderToEat() {
        delegate?.toEat("meat")
    }
}

class Dog {}
extension Dog: MasterOrderDelegate {
    func toEat(_ food: String) {
        print("\(type(of: self)) is eating \(food)")
    }
}

class Cat {}
extension Cat: MasterOrderDelegate {
    func toEat(_ food: String) {
        print("\(type(of: self)) is eating \(food)")
    }
}

let cat = Cat()
let dog = Dog()
let cat1 = Cat()

let master = Master()
// master的delegate是弱引用,所以不能直接赋值
let delegate = masterOrderDelegateManager([cat, dog])
// 添加遵守该协议的类
delegate.add(cat1)
// 删除遵守该协议的类
delegate.remove(dog)

master.delegate = delegate
master.orderToEat()


class MultiDelegate: NSObject {

}
