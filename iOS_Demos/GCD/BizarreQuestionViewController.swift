//
//  BizarreQuestionViewController.swift
//  iOS_Demos
//
//  Created by 张一鸣 on 06/03/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

import UIKit

class BizarreQuestionViewController: ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    
    }

    func first() {
        let key = DispatchSpecificKey<String>()
        
        DispatchQueue.main.setSpecific(key: key, value: "main")
        
        func log() {
            debugPrint("main thread: \(Thread.isMainThread)")
            let value = DispatchQueue.getSpecific(key: key)
            debugPrint("main queue: \(value != nil)")
        }
        
        DispatchQueue.global().sync(execute: log)
        RunLoop.current.run()
        

    }
    
    func sec() {
        let key = DispatchSpecificKey<String>()
        
        DispatchQueue.main.setSpecific(key: key, value: "main")
        
        func log() {
            debugPrint("main thread: \(Thread.isMainThread)")
            let value = DispatchQueue.getSpecific(key: key)
            debugPrint("main queue: \(value != nil)")
        }
        
        DispatchQueue.global().async {
            DispatchQueue.main.async(execute: log)
        }
        dispatchMain()

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
