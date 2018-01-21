//
//  SpecOnQueueViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 11/01/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "GlobalQueueInitialAndQueueSpec.h"


// The "global logging queue" refers to [DDLog loggingQueue].
// It is the queue that all log statements go through.
//
// The logging queue sets a flag via dispatch_queue_set_specific using this key.
// We can check for this key via dispatch_get_specific() to see if we're on the "global logging queue".


/*!
 这代表这是一个指向自己的指针并且又一个静态地址，这个一般用来简单的创建一个特殊的可以用来被当作keying的值，类似objc_getAssociatedObject可以用到

 这个值会一直呆在内存中一个固定的位置，例如  0x12345 ，这句话的意思就是在 0x12345这个内存地址中写入 0x12345这个值，这样的话就没有别的可变数据可以占据这个地址，这样的话这个值就可以保证独特性
 */
static void *const GlobalLoggingQueueIdentityKey = (void *)&GlobalLoggingQueueIdentityKey;

@interface GlobalQueueInitialAndQueueSpec (){
    @public
    dispatch_queue_t _loggerQueue;

}
@property (nonatomic, readonly) dispatch_queue_t loggerQueue;


@end

@implementation GlobalQueueInitialAndQueueSpec

static dispatch_queue_t _loggingQueue;

/**
 *
 *  initial 只会运行一次，而且是第一次被import 的时候，这样就能很有效的保证这个类只会别运行一次，并且，这个方法是线程安全的
 *
 **/
+ (void)initialize {
    static dispatch_once_t DDLogOnceToken;
    
    dispatch_once(&DDLogOnceToken, ^{
        
        _loggingQueue = dispatch_queue_create("cocoa.lumberjack", NULL);
        
        void *nonNullValue = GlobalLoggingQueueIdentityKey; // Whatever, just not null
        dispatch_queue_set_specific(_loggingQueue, GlobalLoggingQueueIdentityKey, nonNullValue, NULL);
        
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

// 这方法是给一些二级queue使用的
- (BOOL)isOnGlobalLoggingQueue {
    return (dispatch_get_specific(GlobalLoggingQueueIdentityKey) != NULL);
}

// 这方法是给一些二级queue使用的
- (BOOL)isOnInternalLoggerQueue {
    void *key = (__bridge void *)self;
    
    return (dispatch_get_specific(key) != NULL);
}


// 判断是不是在当前线程上
/*！
 NSAssert(dispatch_get_specific(GlobalLoggingQueueIdentityKey),
 @"This method should only be run on the logging thread/queue");
 */

// 因为设置是每个logger的事物，在串行队列上永远有顺序，但是不一定要在大的logqueue上排序，但是读取不能等待每个loggerqueue去相应，必须在大的loggerqueue中获得
// 使用各种设置的时候，都使用async
//- (void)removeAllLoggers {
//    dispatch_async(_loggingQueue, ^{ @autoreleasepool {
//        [self lt_removeAllLoggers];
//    } });
//}

/* 这里所有的删除都在自己的子线程上
 - (void)lt_removeAllLoggers {
    NSAssert(dispatch_get_specific(GlobalLoggingQueueIdentityKey),
    @"This method should only be run on the logging thread/queue");
 
    // Notify all loggers
    for (DDLoggerNode *loggerNode in self._loggers) {
    if ([loggerNode->_logger respondsToSelector:@selector(willRemoveLogger)]) {
        dispatch_async(loggerNode->_loggerQueue, ^{ @autoreleasepool {
            [loggerNode->_logger willRemoveLogger];
            } });
        }
    }
 
 // Remove all loggers from array
 
 [self._loggers removeAllObjects];
 }
 */

// 使用读取的时候 ， 都在sync，使用了sync ，默认就会在主线程上了
//- (NSArray<id<DDLogger>> *)allLoggers {
//    __block NSArray *theLoggers;
//
//    dispatch_sync(_loggingQueue, ^{ @autoreleasepool {
//        theLoggers = [self lt_allLoggers];
//    } });
//
//    return theLoggers;
//}

// 在主线程上的时候就不需要再check线程了
//- (NSArray *)lt_allLoggers {
//    NSAssert(dispatch_get_specific(GlobalLoggingQueueIdentityKey),
//             @"This method should only be run on the logging thread/queue");
//
//    NSMutableArray *theLoggers = [NSMutableArray new];
//
//    for (DDLoggerNode *loggerNode in self._loggers) {
//        [theLoggers addObject:loggerNode->_logger];
//    }
//
//    return [theLoggers copy];
//}

// 一般的销毁操作都是在主线程上的
//- (void)flushLog {
//    dispatch_sync(_loggingQueue, ^{ @autoreleasepool {
//        [self lt_flush];
//    } });
//}

// 销毁操作本身可以在紫的线程使用async
//- (void)lt_flush {
//    // All log statements issued before the flush method was invoked have now been executed.
//    //
//    // Now we need to propogate the flush request to any loggers that implement the flush method.
//    // This is designed for loggers that buffer IO.
//
//    NSAssert(dispatch_get_specific(GlobalLoggingQueueIdentityKey),
//             @"This method should only be run on the logging thread/queue");
//
//    for (DDLoggerNode *loggerNode in self._loggers) {
//        if ([loggerNode->_logger respondsToSelector:@selector(flush)]) {
//            dispatch_group_async(_loggingGroup, loggerNode->_loggerQueue, ^{ @autoreleasepool {
//                [loggerNode->_logger flush];
//            } });
//        }
//    }
//
//    dispatch_group_wait(_loggingGroup, DISPATCH_TIME_FOREVER);
//}


// 这里可以使用同步也可以使用异步，这是这个可以控制数量
//- (void)queueLogMessage:(DDLogMessage *)logMessage asynchronously:(BOOL)asyncFlag {
//
//    dispatch_semaphore_wait(_queueSemaphore, DISPATCH_TIME_FOREVER);
//
//
//    dispatch_block_t logBlock = ^{
//        @autoreleasepool {
//            [self lt_log:logMessage];
//        }
//    };
//
//    if (asyncFlag) {
//        dispatch_async(_loggingQueue, logBlock);
//    } else {
//        dispatch_sync(_loggingQueue, logBlock);
//    }
//}


// 这个方法有一个亮点 ，就是它不用刻意切换队列，只要判断就行了
//- (void)setSaveThreshold:(NSUInteger)threshold {
//    dispatch_block_t block = ^{
//        @autoreleasepool {
//            // 这里有个细节
//            // 先更改save的数值，在使用保存函数
//            if (_saveThreshold != threshold) {
//                _saveThreshold = threshold;
//
//                // Since the saveThreshold has changed,
//                // we check to see if the current unsavedCount has surpassed the new threshold.
//                //
//                // If it has, we immediately save the log.
//
//                if ((_unsavedCount >= _saveThreshold) && (_saveThreshold > 0)) {
//                    [self performSaveAndSuspendSaveTimer];
//                }
//            }
//        }
//    };
//
//    // The design of the setter logic below is taken from the DDAbstractLogger implementation.
//    // For documentation please refer to the DDAbstractLogger implementation.
//
//    if ([self isOnInternalLoggerQueue]) {
//        block();
//    } else {
//        // 漂亮，强制使用 queue 检查
//        dispatch_queue_t globalLoggingQueue = [DDLog loggingQueue];
//        NSAssert(![self isOnGlobalLoggingQueue], @"Core architecture requirement failure");
//        // 这里所有的操作都在大的loggerqueue中，而且，小的async， 大的也是async
//        dispatch_async(globalLoggingQueue, ^{
//            dispatch_async(self.loggerQueue, block);
//        });
//    }
//}

- (void)dealloc {
#if !OS_OBJECT_USE_OBJC
    
    if (_loggerQueue) {
        dispatch_release(_loggerQueue);
    }
    
#endif
}


@end
