//
//  DispatchSemaphoreViewController.swift
//  iOS_Demos
//
//  Created by 张一鸣 on 09/03/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

import UIKit

@objc(DispatchSemaphoreViewController)
class DispatchSemaphoreViewController: UIViewController {
    let semaphore = DispatchSemaphore(value: 3)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let queue = DispatchQueue(label: "1");
        
        queue.async {
            self.semaphore.wait()
            
            sleep(8)
            print("++++++")

            self.semaphore.signal()
            
        }
        
        queue.async {
            self.semaphore.wait()
            
            sleep(8)
            print("++++++")
            
            self.semaphore.signal()
            
        }
        
        queue.async {
            self.semaphore.wait()
            
            sleep(8)
            print("++++++")
            
            self.semaphore.signal()
            
        }
        
        queue.async {
            self.semaphore.wait()
            
            sleep(8)
            print("++++++")
            
            self.semaphore.signal()
            
        }
        
        semaphore.wait()
        semaphore.wait()
        semaphore.wait()

        
        print("----------")
        
        
        
    }



}
