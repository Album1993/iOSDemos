//
//  ProcessNumberViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 11/01/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "ProcessNumberViewController.h"


@interface ProcessNumberViewController ()

@end


@implementation ProcessNumberViewController

static NSUInteger _numProcessors;

+ (void)initialize {
    static dispatch_once_t DDLogOnceToken;

    dispatch_once(&DDLogOnceToken, ^{
        //获取一共有多少核
        _numProcessors = MAX([NSProcessInfo processInfo].processorCount, (NSUInteger)1);
    });
}

// 如果只有一核的时候就只sync了
// 如果是多核的时候就可以将
//- (void)lt_log:(DDLogMessage *)logMessage {
//    // Execute the given log message on each of our loggers.
//
//    NSAssert(dispatch_get_specific(GlobalLoggingQueueIdentityKey),
//             @"This method should only be run on the logging thread/queue");
//
//    if (_numProcessors > 1) {
// 并行执行logger，并且每个logger 都在它自己的线程中
// 所有的block都在同一个group 中
// 并且每一个block都在自己的queue中
// The waiting ensures that a slow logger doesn't end up with a large queue of pending log messages.
// This would defeat the purpose of the efforts we made earlier to restrict the max queue size.
// 因为这是两个维度的，每个message 可以给多个logger，所以使用group 可以有效防止一些比较慢的logger执行完成
//
//        for (DDLoggerNode *loggerNode in self._loggers) {
//            // skip the loggers that shouldn't write this message based on the log level
//
//            if (!(logMessage->_flag & loggerNode->_level)) {
//                continue;
//            }
//
//            dispatch_group_async(_loggingGroup, loggerNode->_loggerQueue, ^{ @autoreleasepool {
//                [loggerNode->_logger logMessage:logMessage];
//            } });
//        }
//
//        dispatch_group_wait(_loggingGroup, DISPATCH_TIME_FOREVER);
//    } else {
//        // Execute each logger serialy, each within its own queue.
//
//        for (DDLoggerNode *loggerNode in self._loggers) {
//            // skip the loggers that shouldn't write this message based on the log level
//
//            if (!(logMessage->_flag & loggerNode->_level)) {
//                continue;
//            }
//
//            dispatch_sync(loggerNode->_loggerQueue, ^{ @autoreleasepool {
//                [loggerNode->_logger logMessage:logMessage];
//            } });
//        }
//    }
//
//    dispatch_semaphore_signal(_queueSemaphore);
//}

@end
