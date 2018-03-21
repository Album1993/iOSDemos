//
//  AppDelegate.swift
//  vue
//
//  Created by 张一鸣 on 20/03/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//


//核心设计
//基于经典的 Redux 模型，ReSwift 也奉行以下设计：
//
//The Store：以单一数据结构管理整个 app 的状态，状态只能通过 dispatching Actions 来进行修改。一旦 store 中的状态改变了，它就会通知给所有的 observers 。
//
//Actions：通过陈述的形式来描述一次状态变更，它不包含任何代码，存储在 store，被转发给 reducers。reducers 会接收这些 actions 然后进行相应的状态逻辑变更。
//
//Reducers：基于当前的 action 和 app 状态，通过纯函数来返回一个新的 app 状态。
//
//combineReducers
//笔者发现在当前的 ReSwift 版本中，并没有提供 Redux 中相应的 combineReducers 实现。猜想这个其实跟 Swift 与 JavaScript 之间的差异导致，与后者这门动态语言不通，前者存在静态的类型。但这个问题可以通过其它办法来解决。

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

