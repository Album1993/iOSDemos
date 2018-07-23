//
//  MacConsoleLog.swift
//  iOS_Demos
//
//  Created by 张一鸣 on 2018/7/12.
//  Copyright © 2018年 张一鸣. All rights reserved.
//

import Foundation
import os

private let subsystem = "tech.agostini.ATCompositePattern.Commander"


public class MacLog {
    
    public static func debugLog(message:StaticString,category:String, _ args: CVarArg...) {
        let customLog = OSLog(subsystem: subsystem, category: category)
        os_log(message, log: customLog, type: .debug,args)
    }
    
    
    public static func errorLog(message:StaticString,category:String, _ args: CVarArg...) {
        let customLog = OSLog(subsystem: subsystem, category: category)
        os_log(message, log: customLog, type: .error,args)
    }
}

