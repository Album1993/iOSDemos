//
//  BizarreQuestionViewController.swift
//  iOS_Demos
//
//  Created by 张一鸣 on 06/03/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

import UIKit

@objc(BizarreQuestionViewController)
class BizarreQuestionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        first()
        sec()
        third()
    }

    func first() {
        let key = DispatchSpecificKey<String>()
        
        DispatchQueue.main.setSpecific(key: key, value: "main")
        
        func log() {
            debugPrint("main thread: \(Thread.isMainThread)")
            let value = DispatchQueue.getSpecific(key: key)
            debugPrint("main queue: \(value != nil)")
        }
        
        // 这个很简单，只要是sync都在主线程当中
        DispatchQueue.global().sync(execute: log)
//        RunLoop.current.run()
        
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
        
//        这里用的这个 API dispatchMain() 如果改成 RunLoop.current.run()，结果就会像我们一般预期的那样是两个 true。
//        而且在 command line 环境下才能出这效果，如果建工程是 iOS app 的话因为有 runloop，所以结果也是两个 true 的。
        
        

        // 这个时候是一个false ，一个true
//        dispatchMain()
        
        // 这样就是两个true
//        RunLoop.current.run()

    }
    
    func third() {
        let observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.allActivities.rawValue, true, 0) { _, activity in
            if activity.contains(.entry) {
                debugPrint("entry")
            } else if activity.contains(.beforeTimers) {
                debugPrint("beforeTimers")
            } else if activity.contains(.beforeSources) {
                debugPrint("beforeSources")
            } else if activity.contains(.beforeWaiting) {
                debugPrint("beforeWaiting")
            } else if activity.contains(.afterWaiting) {
                debugPrint("afterWaiting")
            } else if activity.contains(.exit) {
                debugPrint("exit")
            }
        }
        
        CFRunLoopAddObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
        
        
        //这个例子可以看出有大量任务派发时用 OperationQueue 比 GCD 要略微不容易造成卡顿一些。
        
        // case 1
//        DispatchQueue.global().async {
//            (0...999).forEach { idx in
//                DispatchQueue.main.async {
//                    debugPrint(idx)
//                }
//            }
//        }
//
        // case 2
        DispatchQueue.global().async {
          let operations = (0...999).map { idx in BlockOperation { debugPrint(idx) } }
          OperationQueue.main.addOperations(operations, waitUntilFinished: false)
        }
        
        RunLoop.current.run()

    }
    
    func four()  {
        let queue1 = DispatchQueue(label: "queue1")
        let queue2 = DispatchQueue(label: "queue2")
        
        var list: [Int] = []
        
        queue1.async {
            while true {
                if list.count < 10 {
                    list.append(list.count)
                } else {
                    list.removeAll()
                }
            }
        }
        
        queue2.async {
            while true {
                // case 1
                list.forEach { debugPrint($0) }
                
                // case 2
                //    let value = list
                //    value.forEach { debugPrint($0) }
                
                // case 3
                //    var value = list
                //    value.append(100)
            }
        }
        
        RunLoop.current.run()
    
    }
    
    func five()  {
        class Object: NSObject {
            @objc
            func fun() {
                debugPrint("\(self) fun")
            }
        }
        
        var runloop: CFRunLoop!
        
        let sem = DispatchSemaphore(value: 0)
        
        let thread = Thread {
            RunLoop.current.add(NSMachPort(), forMode: .commonModes)
            
            runloop = CFRunLoopGetCurrent()
            
            sem.signal()
            
            CFRunLoopRun()
        }
        
        thread.start()
        
        sem.wait()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            CFRunLoopPerformBlock(runloop, CFRunLoopMode.commonModes.rawValue) {
                debugPrint("2")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                debugPrint("1")
                let object = Object()
                object.fun()
                //    CFRunLoopWakeUp(runloop)
            })
        }
        
        RunLoop.current.run()
        
//        如果把 object.fun() 改成 object.perform(#selector(Object.fun), on: thread, with: nil, waitUntilDone: false) 的话就能 print 出来 2 了，就是说 runloop 在 sleep 状态下，performSelector 是可以唤醒 runloop 的，而一次单纯的调用不行。
//        有一个细节就是，如果用CFRunLoopWakeUp(runloop)的话，输出顺序是1 fun 2 而用 performSelector 的话顺序是 1 2 fun。我的朋友骑神的解释：
//        perform调用时添加的timer任务会唤醒runloop去处理任务。但因为CFRunLoopPerformBlock的任务更早加入队列中，所以输出优先于fun
        
        
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
