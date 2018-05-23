//
// Created by 张一鸣 on 2018/5/23.
// Copyright (c) 2018 张一鸣. All rights reserved.
//

import Foundation
import UIKit

extension Notification.Name {
    public static let CountdownDidUpdate = Notification.Name(rawValue: "CountdownDidUpate")
}

//@UIApplicationMain
class Mock_AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    private var store: SchedulingServiceStore!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        store = SchedulingServiceStore()
        store.service.delegate = self

        if store.service.scheduledRequests.isEmpty == true {
            scheduleRequests(service: store.service)
        }

        store.service.resume()
        print("\(store.service)")

        return true
    }

    private func scheduleRequests(service: SchedulingService) {
        /**
         Closure based example
         */
        let request = service.schedule(date: Date().addingTimeInterval(5))
        service.cancel(request: request)

        /**
         Notification based example
         */
        service.schedule(date: Date().addingTimeInterval(20), notification: .CountdownDidUpdate)
    }

}

extension Mock_AppDelegate: SchedulingServiceDelegate {

    func schedulingServiceDidChange(_ service: SchedulingService) {
        print("Changed: \(service)")
    }

    func schedulingService(_ service: SchedulingService, didAdd request: SchedulingRequest) {
        print("Added: \(request)")
    }

    func schedulingService(_ service: SchedulingService, didComplete request: SchedulingRequest) {
        print("Completed: \(request)")
    }

    func schedulingService(_ service: SchedulingService, didCancel request: SchedulingRequest) {
        print("Cancelled: \(request)")
    }

}