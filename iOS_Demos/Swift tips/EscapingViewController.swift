//
//  EscapingViewController.swift
//  iOS_Demos
//
//  Created by 张一鸣 on 26/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

import UIKit

@objc(EscapingViewController)
class EscapingViewController: UIViewController {
    
    func ja(_ args: CVarArg...)  {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.method1()

    }

// 这种的闭包必须是同步的，如果是异步的就必须使用@escaping
    func doWork(block:()->()) {
        
        block()
    }
    
    func doWorkAsync(block: @escaping ()->()) {
        DispatchQueue.main.async {
            block()
        }
    }
    
    
    
    var foo = "foo"
    
    func method1() {
        
        // 同步执行的时候就打印foo
        doWork {
            print(foo)
        }
        foo = "bar"
    }
    
    func method2() {
        
        // 这样的话会直接输出 bar
        // 这个闭包会被异步执行
        doWorkAsync {
            print(self.foo)
        }
        foo = "bar"
    }
    
    func method3() {
        doWorkAsync {
            [weak self] in
            print(self?.foo ?? "nil")
        }
        foo = "bar"
    }
    
}


