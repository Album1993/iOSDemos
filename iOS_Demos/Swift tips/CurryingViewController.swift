//
//  CurryingViewController.swift
//  iOS_Demos
//
//  Created by 张一鸣 on 24/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

import UIKit


@objc(CurryingViewController) // 这个不加上的话没有办法从NSClassFromString 获取类
class CurryingViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let b = addto(num: 1)
    
    
        let addTwo = addToCurrying(_adder: 2)
        
        let result = addTwo(4)
        
        print(result)
        
        
        let greaterThan10 = greaterThan(10)
        print(greaterThan10(11))
        print(greaterThan10(9))

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let control = Control.init()
        
        control.setTarget(target: self, action: { (tar) -> () -> () in
            return {
                print(tar)
            }
        }, controlEvent: ControlEvent.TouchUpInside)
        control.performActionForControlEvent(controlEvent: ControlEvent.TouchUpInside)
    }
    
    //这个函数所表达的内容非常有限，如果我们之后还需要一个将输入数字加 2，或者加 3 的函数，可能不得不类似地去定义返回为 num + 2 或者 num + 3 的版本。”
    func addto(num: Int) -> Int {
        return num + 1
    }
    
    func addToCurrying(_adder: Int) -> (Int) -> Int {
        return {
            num in
            return num + _adder
        }
    }
    
    func greaterThan(_ compare:Int) -> (Int) -> Bool {
        return {$0 > compare}
    }

}

// 使用实例
protocol TargetAction {
    func performAction()
}

struct TargetActionWrapper<T: AnyObject> : TargetAction {
    weak var target: T?
    let action:(T) -> () -> ()
    
    func performAction() -> () {
        if let t = target {
            action(t)()
        }
    }
}

enum ControlEvent {
    case TouchUpInside
    case ValueChanged
}


class Control {
    var actions = [ControlEvent: TargetAction]()
    
    func setTarget<T: AnyObject>(target: T,
                                 action:@escaping(T) -> () -> (),
                                 controlEvent:ControlEvent) {
        actions[controlEvent] = TargetActionWrapper(target:target, action: action)
    }
    
    func removeTargetForControlEvent(controlEvent:ControlEvent) {
        actions[controlEvent] = nil
    }
    
    func performActionForControlEvent(controlEvent: ControlEvent) {
        actions[controlEvent]?.performAction()
    }
    
}
























