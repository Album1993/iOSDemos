//
//  asynchronousTest.swift
//  iOS_DemosTests
//
//  Created by 张一鸣 on 27/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

import XCTest

class asynchronousTest: XCTestCase {
    

        
/**
     func testScalingProducesSameAmountOfImages() {

        // Create an expectation
        let expectation = self.expectation(description: "Scaling")
        
         funct {
            
            // Fullfil the expectation to let the test runner
            // know that it's OK to proceed
            expectation.fulfill()
        }
        
        // Wait for the expectation to be fullfilled, or time out
        // after 5 seconds. This is where the test runner will pause.
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertEqual(scaledImages?.count, originalImages.count)
    }

*/
    
/*
    func testPreviousClosureCancelled() {
        let debouncer = Debouncer(delay: 0.25)
        
        // Expectation for the closure we'e expecting to be cancelled
        let cancelExpectation = expectation(description: "Cancel")
        cancelExpectation.isInverted = true
        
        // Expectation for the closure we're expecting to be completed
        let completedExpectation = expectation(description: "Completed")
        
        debouncer.schedule {
            cancelExpectation.fulfill()
        }
        
        // When we schedule a new closure, the previous one should be cancelled
        debouncer.schedule {
            completedExpectation.fulfill()
        }
        
        // We add an extra 0.05 seconds to reduce the risk for flakiness
        waitForExpectations(timeout: 0.3, handler: nil)
    }
*/
    
    
/*
 But what we can do, is to enable a DispatchQueue to be injected from the outside - that way we can use the sync method to issue a synchronous closure on a specific queue right after our preloading has occurred, which will enable us to wait for the operation to finish, like this:
     
     通过sync这种方式则可以保证这个任务被阻塞了，直到上一个需要的任务被执行完成
     
     class FileLoaderTests: XCTestCase {
     func testPreloadingFiles() {
     let loader = FileLoader()
     let queue = DispatchQueue(label: "FileLoaderTests")
     
     loader.preloadFiles(named: ["One", "Two", "Three"], on: queue)
     
     // Issue an empty closure on the queue and wait for it to be executed
     queue.sync {}
     
     let preloadedFileNames = loader.preloadedFiles.map { $0.name }
     XCTAssertEqual(preloadedFileNames, ["One", "Two", "Three"])
     }
     }
 */
    
/*
    protocol UserNotificationCenter {
        func requestAuthorization(options: UNAuthorizationOptions,
                                  completionHandler: @escaping (Bool, Error?) -> Void)
    }
    
    // Since our protocol requirements exactly match UNUserNotificationCenter's API,
    // we can simply make it conform to it using an empty extension.
    extension UNUserNotificationCenter: UserNotificationCenter {}
    
    class UserNotificationCenterMock: UserNotificationCenter {
        // Properties that let us control the outcome of an authorization request.
        var grantAuthorization = false
        var error: Error?
        
        func requestAuthorization(options: UNAuthorizationOptions,
                                  completionHandler: @escaping (Bool, Error?) -> Void) {
            // We execute the completion handler right away, synchronously.
            // 因为这个是同步的（不是很明白）
            completionHandler(grantAuthorization, error)
        }
    }
     
     class PushNotificationManagerTests: XCTestCase {
        func testSuccessfulAuthorization() {
        let center = UserNotificationCenterMock()
        let manager = PushNotificationManager(notificationCenter: center)
     
        center.grantAuthorization = true
     
        var status: PushNotificationManager.Status?
        manager.enableNotifications { status = $0 }
     
        XCTAssertEqual(status, .enabled)
     }
     }
*/
}
