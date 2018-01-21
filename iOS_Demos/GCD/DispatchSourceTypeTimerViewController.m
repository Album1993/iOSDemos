//
//  DispatchSourceTypeTimerViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 11/01/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "DispatchSourceTypeTimerViewController.h"

@interface DispatchSourceTypeTimerViewController (){
@protected
    NSUInteger _saveThreshold;
    NSTimeInterval _saveInterval;
    NSTimeInterval _maxAge;
    NSTimeInterval _deleteInterval;
    BOOL _deleteOnEverySave;
    
    BOOL _saveTimerSuspended;
    NSUInteger _unsavedCount;
    dispatch_time_t _unsavedTime;
    // 时间控制的
    dispatch_source_t _saveTimer;
    dispatch_time_t _lastDeleteTime;
    dispatch_source_t _deleteTimer;
    
}

@end

@implementation DispatchSourceTypeTimerViewController


#pragma mark 初始化
//- (void)createSuspendedSaveTimer {
//
//    //  初始化sourcetimer
//    if ((_saveTimer == NULL) && (_saveInterval > 0.0)) {
//        _saveTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.loggerQueue);
//        // 漂亮， 什么都不用多写
//        dispatch_source_set_event_handler(_saveTimer, ^{ @autoreleasepool {
            // 这个方法里面就是执行暂停这个timer
//            [self performSaveAndSuspendSaveTimer];
//        } });
//        // 使用savetimer suspend 来 做标志位
//        _saveTimerSuspended = YES;
//    }
//}

#pragma mark 开始
// 这个是开始某项操作的最佳实践，这是两个timer的配合使用
//- (void)performSaveAndSuspendSaveTimer {
//    //保存了
//    if (_unsavedCount > 0) {
//        if (_deleteOnEverySave) {
//            [self db_saveAndDelete];
//        } else {
//            [self db_save];
//        }
//    }
//    // 将没保存设置为0
//    // 将没保存的数量设置为0
//    _unsavedCount = 0;
//    _unsavedTime = 0;
//
//
//    // 如果_有savetime这个线程，并且线程没有被挂起
//    // 就把这个线程挂起
//    if (_saveTimer && !_saveTimerSuspended) {
//        dispatch_suspend(_saveTimer);
//        _saveTimerSuspended = YES;
//    }
//}

#pragma mark
// 这是结束某项操作的最佳实践
// 删除数据
//- (void)performDelete {
//    if (_maxAge > 0.0) {
//        [self db_delete];
//
//        _lastDeleteTime = dispatch_time(DISPATCH_TIME_NOW, 0);
//    }
//}

#pragma mark 更新
// 更新timer 的正确方法
//- (void)updateAndResumeSaveTimer {
//    if ((_saveTimer != NULL) && (_saveInterval > 0.0) && (_unsavedTime > 0.0)) {
//
//        // 使用timeinterval 的正确方法
//        uint64_t interval = (uint64_t)(_saveInterval * (NSTimeInterval) NSEC_PER_SEC);
//        // 设置每一次的savetime 为从unsavedtime 开始每隔interval save 一次
//        dispatch_time_t startTime = dispatch_time(_unsavedTime, interval);
//
//        // 使用dispatch_source 开始了
//        dispatch_source_set_timer(_saveTimer, startTime, interval, 1ull * NSEC_PER_SEC);
//
//        // 开始save timer 这个source
//        if (_saveTimerSuspended) {
//            dispatch_resume(_saveTimer);
//            _saveTimerSuspended = NO;
//        }
//    }
//}

#pragma mark 销毁
// 用来销毁timer的最佳实践
//- (void)destroySaveTimer {
//    if (_saveTimer) {
//
//        // 用来cancel 线程
//        dispatch_source_cancel(_saveTimer);
//        // 将_save 重置
//        if (_saveTimerSuspended) {
//            // Must resume a timer before releasing it (or it will crash)
//            dispatch_resume(_saveTimer);
//            _saveTimerSuspended = NO;
//        }
//
//#if !OS_OBJECT_USE_OBJC
//        dispatch_release(_saveTimer);
//#endif
//        _saveTimer = NULL;
//    }
//}


#pragma mark 最大的玄机在这里
//- (void)logMessage:(DDLogMessage *)logMessage {
//    if ([self db_log:logMessage]) {
//        BOOL firstUnsavedEntry = (++_unsavedCount == 1);
//         // 这里少了一种情况
//         // 就是这里只有超过条数保存， 还有第一次记录时候启动计时器
//        if ((_unsavedCount >= _saveThreshold) && (_saveThreshold > 0)) {
//            [self performSaveAndSuspendSaveTimer];
//        } else if (firstUnsavedEntry) {
//            _unsavedTime = dispatch_time(DISPATCH_TIME_NOW, 0);
//            [self updateAndResumeSaveTimer];
//        }
//    }
//}

// 在dealloc 中注销就行，这样就不用各种注销了
- (void)dealloc {
//    [self destroySaveTimer];
//    [self destroyDeleteTimer];
}
@end



#pragma mark 完整代码

// #import "DDAbstractDatabaseLogger.h"
// #import <math.h>
//
//
// #if !__has_feature(objc_arc)
// #error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
// #endif
//
// @interface DDAbstractDatabaseLogger ()
//
// - (void)destroySaveTimer;
// - (void)destroyDeleteTimer;
//
// @end
//
// #pragma mark -
//
// @implementation DDAbstractDatabaseLogger
//
// - (instancetype)init {
// if ((self = [super init])) {
// _saveThreshold = 500;
// _saveInterval = 60;           // 60 seconds
// _maxAge = (60 * 60 * 24 * 7); //  7 days
// _deleteInterval = (60 * 5);   //  5 minutes
// }
//
// return self;
// }
// // 有意思
// - (void)dealloc {
// [self destroySaveTimer];
// [self destroyDeleteTimer];
// }
//
// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// #pragma mark Override Me
// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// - (BOOL)db_log:(DDLogMessage *)logMessage {
// // Override me and add your implementation.
// //
// // Return YES if an item was added to the buffer.
// // Return NO if the logMessage was ignored.
//
// return NO;
// }
//
// - (void)db_save {
// // Override me and add your implementation.
// }
//
// - (void)db_delete {
// // Override me and add your implementation.
// }
//
// - (void)db_saveAndDelete {
// // Override me and add your implementation.
// }
//
// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// #pragma mark Private API
// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// // 用来执行保存操作
// - (void)performSaveAndSuspendSaveTimer {
// //保存了
// if (_unsavedCount > 0) {
// if (_deleteOnEverySave) {
// [self db_saveAndDelete];
// } else {
// [self db_save];
// }
// }
// // 将没保存设置为0
// // 将没保存的数量设置为0
// _unsavedCount = 0;
// _unsavedTime = 0;
//
//
// // 如果_有savetime这个线程，并且线程没有被挂起
// // 就把这个线程挂起
// if (_saveTimer && !_saveTimerSuspended) {
// dispatch_suspend(_saveTimer);
// _saveTimerSuspended = YES;
// }
// }
//
// // 删除数据
// - (void)performDelete {
// if (_maxAge > 0.0) {
// [self db_delete];
//
// _lastDeleteTime = dispatch_time(DISPATCH_TIME_NOW, 0);
// }
// }
//
// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// #pragma mark Timers
// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// - (void)destroySaveTimer {
// if (_saveTimer) {
//
// // 用来cancel 线程
// dispatch_source_cancel(_saveTimer);
// // 将_save 重置
// if (_saveTimerSuspended) {
// // Must resume a timer before releasing it (or it will crash)
// dispatch_resume(_saveTimer);
// _saveTimerSuspended = NO;
// }
//
// #if !OS_OBJECT_USE_OBJC
// dispatch_release(_saveTimer);
// #endif
// _saveTimer = NULL;
// }
// }
//
// - (void)updateAndResumeSaveTimer {
// if ((_saveTimer != NULL) && (_saveInterval > 0.0) && (_unsavedTime > 0.0)) {
//
// uint64_t interval = (uint64_t)(_saveInterval * (NSTimeInterval) NSEC_PER_SEC);
// dispatch_time_t startTime = dispatch_time(_unsavedTime, interval);
//
// dispatch_source_set_timer(_saveTimer, startTime, interval, 1ull * NSEC_PER_SEC);
//
// if (_saveTimerSuspended) {
// dispatch_resume(_saveTimer);
// _saveTimerSuspended = NO;
// }
// }
// }
//
// - (void)createSuspendedSaveTimer {
//
// //  初始化sourcetimer
// if ((_saveTimer == NULL) && (_saveInterval > 0.0)) {
// _saveTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.loggerQueue);
// // 漂亮， 什么都不用多写
// dispatch_source_set_event_handler(_saveTimer, ^{ @autoreleasepool {
// [self performSaveAndSuspendSaveTimer];
// } });
// // 使用savetimer suspend 来 做标志位
// _saveTimerSuspended = YES;
// }
// }
//
// // 销毁dispatch time的
// - (void)destroyDeleteTimer {
// if (_deleteTimer) {
// dispatch_source_cancel(_deleteTimer);
// #if !OS_OBJECT_USE_OBJC
// dispatch_release(_deleteTimer);
// #endif
// _deleteTimer = NULL;
// }
// }
//
// - (void)updateDeleteTimer {
// if ((_deleteTimer != NULL) && (_deleteInterval > 0.0) && (_maxAge > 0.0)) {
// uint64_t interval = (uint64_t)(_deleteInterval * (NSTimeInterval) NSEC_PER_SEC);
// dispatch_time_t startTime;
// // 我去标准化流程 😂
// if (_lastDeleteTime > 0) {
// startTime = dispatch_time(_lastDeleteTime, interval);
// } else {
// startTime = dispatch_time(DISPATCH_TIME_NOW, interval);
// }
//
// dispatch_source_set_timer(_deleteTimer, startTime, z z z, 1ull * NSEC_PER_SEC);
// }
// }
//
// - (void)createAndStartDeleteTimer {
// if ((_deleteTimer == NULL) && (_deleteInterval > 0.0) && (_maxAge > 0.0)) {
// _deleteTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.loggerQueue);
//
// if (_deleteTimer != NULL) {
// dispatch_source_set_event_handler(_deleteTimer, ^{ @autoreleasepool {
// [self performDelete];
// } });
//
// [self updateDeleteTimer];
//
// if (_deleteTimer != NULL) {
// dispatch_resume(_deleteTimer);
// }
// }
// }
// }
//
// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// #pragma mark Configuration
// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// - (NSUInteger)saveThreshold {
// // The design of this method is taken from the DDAbstractLogger implementation.
// // For extensive documentation please refer to the DDAbstractLogger implementation.
//
// // Note: The internal implementation MUST access the colorsEnabled variable directly,
// // This method is designed explicitly for external access.
// //
// // Using "self." syntax to go through this method will cause immediate deadlock.
// // This is the intended result. Fix it by accessing the ivar directly.
// // Great strides have been take to ensure this is safe to do. Plus it's MUCH faster.
//
// NSAssert(![self isOnGlobalLoggingQueue], @"Core architecture requirement failure");
// NSAssert(![self isOnInternalLoggerQueue], @"MUST access ivar directly, NOT via self.* syntax.");
// // 来吧 耦合吧
// dispatch_queue_t globalLoggingQueue = [DDLog loggingQueue];
//
// __block NSUInteger result;
//
// // 设置都是async， sync是用来读取的，
// // 然后再使用当前的logger queue
// dispatch_sync(globalLoggingQueue, ^{
// dispatch_sync(self.loggerQueue, ^{
// result = _saveThreshold;
// });
// });
//
// return result;
// }
//
// - (void)setSaveThreshold:(NSUInteger)threshold {
// dispatch_block_t block = ^{
// @autoreleasepool {
// // 这里有个细节
// // 先更改save的数值，在使用保存函数
// if (_saveThreshold != threshold) {
// _saveThreshold = threshold;
//
// // Since the saveThreshold has changed,
// // we check to see if the current unsavedCount has surpassed the new threshold.
// //
// // If it has, we immediately save the log.
//
// if ((_unsavedCount >= _saveThreshold) && (_saveThreshold > 0)) {
// [self performSaveAndSuspendSaveTimer];
// }
// }
// }
// };
//
// // The design of the setter logic below is taken from the DDAbstractLogger implementation.
// // For documentation please refer to the DDAbstractLogger implementation.
//
// if ([self isOnInternalLoggerQueue]) {
// block();
// } else {
// // 漂亮，强制使用 queue 检查
// dispatch_queue_t globalLoggingQueue = [DDLog loggingQueue];
// NSAssert(![self isOnGlobalLoggingQueue], @"Core architecture requirement failure");
// // 这里所有的操作都在大的loggerqueue中，而且，小的async， 大的也是async
// dispatch_async(globalLoggingQueue, ^{
// dispatch_async(self.loggerQueue, block);
// });
// }
// }
//
// - (NSTimeInterval)saveInterval {
// // The design of this method is taken from the DDAbstractLogger implementation.
// // For extensive documentation please refer to the DDAbstractLogger implementation.
//
// // Note: The internal implementation MUST access the colorsEnabled variable directly,
// // This method is designed explicitly for external access.
// //
// // Using "self." syntax to go through this method will cause immediate deadlock.
// // This is the intended result. Fix it by accessing the ivar directly.
// // Great strides have been take to ensure this is safe to do. Plus it's MUCH faster.
//
// NSAssert(![self isOnGlobalLoggingQueue], @"Core architecture requirement failure");
// NSAssert(![self isOnInternalLoggerQueue], @"MUST access ivar directly, NOT via self.* syntax.");
//
// dispatch_queue_t globalLoggingQueue = [DDLog loggingQueue];
//
// __block NSTimeInterval result;
// // 只要是设置，就使用sync
// dispatch_sync(globalLoggingQueue, ^{
// dispatch_sync(self.loggerQueue, ^{
// result = _saveInterval;
// });
// });
//
// return result;
// }
//
// - (void)setSaveInterval:(NSTimeInterval)interval {
// dispatch_block_t block = ^{
// @autoreleasepool {
// // C99 recommended floating point comparison macro
// // Read: isLessThanOrGreaterThan(floatA, floatB)
// // 最佳实践
// if (/* saveInterval != interval */ isle99issgreater(_saveInterval, interval)) {
//     _saveInterval = interval;
//
//     // There are several cases we need to handle here.
//     //
//     // 1. If the saveInterval was previously enabled and it just got disabled,
//     //    then we need to stop the saveTimer. (And we might as well release it.)
//     //
//     // 2. If the saveInterval was previously disabled and it just got enabled,
//     //    then we need to setup the saveTimer. (Plus we might need to do an immediate save.)
//     //
//     // 3. If the saveInterval increased, then we need to reset the timer so that it fires at the later date.
//     //
//     // 4. If the saveInterval decreased, then we need to reset the timer so that it fires at an earlier date.
//     //    (Plus we might need to do an immediate save.)
//
//     if (_saveInterval > 0.0) {
//         if (_saveTimer == NULL) {
//             // Handles #2
//             //
//             // Since the saveTimer uses the unsavedTime to calculate it's first fireDate,
//             // if a save is needed the timer will fire immediately.
//
//             [self createSuspendedSaveTimer];
//             [self updateAndResumeSaveTimer];
//         } else {
//             // Handles #3
//             // Handles #4
//             //
//             // Since the saveTimer uses the unsavedTime to calculate it's first fireDate,
//             // if a save is needed the timer will fire immediately.
//
//             [self updateAndResumeSaveTimer];
//         }
//     } else if (_saveTimer) {
//         // Handles #1
//
//         [self destroySaveTimer];
//     }
// }
//}
//};
//
//// The design of the setter logic below is taken from the DDAbstractLogger implementation.
//// For documentation please refer to the DDAbstractLogger implementation.
//
//if ([self isOnInternalLoggerQueue]) {
//    block();
//} else {
//    dispatch_queue_t globalLoggingQueue = [DDLog loggingQueue];
//    NSAssert(![self isOnGlobalLoggingQueue], @"Core architecture requirement failure");
//
//    dispatch_async(globalLoggingQueue, ^{
//        dispatch_async(self.loggerQueue, block);
//    });
//}
//}
//
//- (NSTimeInterval)maxAge {
//    // The design of this method is taken from the DDAbstractLogger implementation.
//    // For extensive documentation please refer to the DDAbstractLogger implementation.
//
//    // Note: The internal implementation MUST access the colorsEnabled variable directly,
//    // This method is designed explicitly for external access.
//    //
//    // Using "self." syntax to go through this method will cause immediate deadlock.
//    // This is the intended result. Fix it by accessing the ivar directly.
//    // Great strides have been take to ensure this is safe to do. Plus it's MUCH faster.
//
//    NSAssert(![self isOnGlobalLoggingQueue], @"Core architecture requirement failure");
//    NSAssert(![self isOnInternalLoggerQueue], @"MUST access ivar directly, NOT via self.* syntax.");
//
//    dispatch_queue_t globalLoggingQueue = [DDLog loggingQueue];
//
//    __block NSTimeInterval result;
//
//    dispatch_sync(globalLoggingQueue, ^{
//        dispatch_sync(self.loggerQueue, ^{
//            result = _maxAge;
//        });
//    });
//
//    return result;
//}
//
//- (void)setMaxAge:(NSTimeInterval)interval {
//    dispatch_block_t block = ^{
//        @autoreleasepool {
//            // C99 recommended floating point comparison macro
//            // Read: isLessThanOrGreaterThan(floatA, floatB)
//
//            if (/* maxAge != interval */ islessgreater(_maxAge, interval)) {
//                NSTimeInterval oldMaxAge = _maxAge;
//                NSTimeInterval newMaxAge = interval;
//
//                _maxAge = interval;
//
//                // There are several cases we need to handle here.
//                //
//                // 1. If the maxAge was previously enabled and it just got disabled,
//                //    then we need to stop the deleteTimer. (And we might as well release it.)
//                //
//                // 2. If the maxAge was previously disabled and it just got enabled,
//                //    then we need to setup the deleteTimer. (Plus we might need to do an immediate delete.)
//                //
//                // 3. If the maxAge was increased,
//                //    then we don't need to do anything.
//                //
//                // 4. If the maxAge was decreased,
//                //    then we should do an immediate delete.
//
//                BOOL shouldDeleteNow = NO;
//
//                if (oldMaxAge > 0.0) {
//                    if (newMaxAge <= 0.0) {
//                        // Handles #1
//
//                        [self destroyDeleteTimer];
//                    } else if (oldMaxAge > newMaxAge) {
//                        // Handles #4
//                        shouldDeleteNow = YES;
//                    }
//                } else if (newMaxAge > 0.0) {
//                    // Handles #2
//                    shouldDeleteNow = YES;
//                }
//
//                if (shouldDeleteNow) {
//                    [self performDelete];
//
//                    if (_deleteTimer) {
//                        [self updateDeleteTimer];
//                    } else {
//                        [self createAndStartDeleteTimer];
//                    }
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
//        dispatch_queue_t globalLoggingQueue = [DDLog loggingQueue];
//        NSAssert(![self isOnGlobalLoggingQueue], @"Core architecture requirement failure");
//
//        dispatch_async(globalLoggingQueue, ^{
//            dispatch_async(self.loggerQueue, block);
//        });
//    }
//}
//
//- (NSTimeInterval)deleteInterval {
//    // The design of this method is taken from the DDAbstractLogger implementation.
//    // For extensive documentation please refer to the DDAbstractLogger implementation.
//
//    // Note: The internal implementation MUST access the colorsEnabled variable directly,
//    // This method is designed explicitly for external access.
//    //
//    // Using "self." syntax to go through this method will cause immediate deadlock.
//    // This is the intended result. Fix it by accessing the ivar directly.
//    // Great strides have been take to ensure this is safe to do. Plus it's MUCH faster.
//
//    NSAssert(![self isOnGlobalLoggingQueue], @"Core architecture requirement failure");
//    NSAssert(![self isOnInternalLoggerQueue], @"MUST access ivar directly, NOT via self.* syntax.");
//
//    dispatch_queue_t globalLoggingQueue = [DDLog loggingQueue];
//
//    __block NSTimeInterval result;
//
//    dispatch_sync(globalLoggingQueue, ^{
//        dispatch_sync(self.loggerQueue, ^{
//            result = _deleteInterval;
//        });
//    });
//
//    return result;
//}
//
//- (void)setDeleteInterval:(NSTimeInterval)interval {
//    dispatch_block_t block = ^{
//        @autoreleasepool {
//            // C99 recommended floating point comparison macro
//            // Read: isLessThanOrGreaterThan(floatA, floatB)
//
//            if (/* deleteInterval != interval */ islessgreater(_deleteInterval, interval)) {
//                _deleteInterval = interval;
//
//                // There are several cases we need to handle here.
//                //
//                // 1. If the deleteInterval was previously enabled and it just got disabled,
//                //    then we need to stop the deleteTimer. (And we might as well release it.)
//                //
//                // 2. If the deleteInterval was previously disabled and it just got enabled,
//                //    then we need to setup the deleteTimer. (Plus we might need to do an immediate delete.)
//                //
//                // 3. If the deleteInterval increased, then we need to reset the timer so that it fires at the later date.
//                //
//                // 4. If the deleteInterval decreased, then we need to reset the timer so that it fires at an earlier date.
//                //    (Plus we might need to do an immediate delete.)
//
//                if (_deleteInterval > 0.0) {
//                    if (_deleteTimer == NULL) {
//                        // Handles #2
//                        //
//                        // Since the deleteTimer uses the lastDeleteTime to calculate it's first fireDate,
//                        // if a delete is needed the timer will fire immediately.
//
//                        [self createAndStartDeleteTimer];
//                    } else {
//                        // Handles #3
//                        // Handles #4
//                        //
//                        // Since the deleteTimer uses the lastDeleteTime to calculate it's first fireDate,
//                        // if a save is needed the timer will fire immediately.
//
//                        [self updateDeleteTimer];
//                    }
//                } else if (_deleteTimer) {
//                    // Handles #1
//
//                    [self destroyDeleteTimer];
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
//        dispatch_queue_t globalLoggingQueue = [DDLog loggingQueue];
//        NSAssert(![self isOnGlobalLoggingQueue], @"Core architecture requirement failure");
//
//        dispatch_async(globalLoggingQueue, ^{
//            dispatch_async(self.loggerQueue, block);
//        });
//    }
//}
//
//- (BOOL)deleteOnEverySave {
//    // The design of this method is taken from the DDAbstractLogger implementation.
//    // For extensive documentation please refer to the DDAbstractLogger implementation.
//
//    // Note: The internal implementation MUST access the colorsEnabled variable directly,
//    // This method is designed explicitly for external access.
//    //
//    // Using "self." syntax to go through this method will cause immediate deadlock.
//    // This is the intended result. Fix it by accessing the ivar directly.
//    // Great strides have been take to ensure this is safe to do. Plus it's MUCH faster.
//
//    NSAssert(![self isOnGlobalLoggingQueue], @"Core architecture requirement failure");
//    NSAssert(![self isOnInternalLoggerQueue], @"MUST access ivar directly, NOT via self.* syntax.");
//
//    dispatch_queue_t globalLoggingQueue = [DDLog loggingQueue];
//
//    __block BOOL result;
//
//    dispatch_sync(globalLoggingQueue, ^{
//        dispatch_sync(self.loggerQueue, ^{
//            result = _deleteOnEverySave;
//        });
//    });
//
//    return result;
//}
//
//- (void)setDeleteOnEverySave:(BOOL)flag {
//    dispatch_block_t block = ^{
//        _deleteOnEverySave = flag;
//    };
//
//    // The design of the setter logic below is taken from the DDAbstractLogger implementation.
//    // For documentation please refer to the DDAbstractLogger implementation.
//
//    if ([self isOnInternalLoggerQueue]) {
//        block();
//    } else {
//        dispatch_queue_t globalLoggingQueue = [DDLog loggingQueue];
//        NSAssert(![self isOnGlobalLoggingQueue], @"Core architecture requirement failure");
//
//        dispatch_async(globalLoggingQueue, ^{
//            dispatch_async(self.loggerQueue, block);
//        });
//    }
//}
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//#pragma mark Public API
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//- (void)savePendingLogEntries {
//    dispatch_block_t block = ^{
//        @autoreleasepool {
//            [self performSaveAndSuspendSaveTimer];
//        }
//    };
//
//    if ([self isOnInternalLoggerQueue]) {
//        block();
//    } else {
//        dispatch_async(self.loggerQueue, block);
//    }
//}
//
//- (void)deleteOldLogEntries {
//    dispatch_block_t block = ^{
//        @autoreleasepool {
//            [self performDelete];
//        }
//    };
//
//    if ([self isOnInternalLoggerQueue]) {
//        block();
//    } else {
//        dispatch_async(self.loggerQueue, block);
//    }
//}
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//#pragma mark DDLogger
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//- (void)didAddLogger {
//    // If you override me be sure to invoke [super didAddLogger];
//
//    [self createSuspendedSaveTimer];
//
//    [self createAndStartDeleteTimer];
//}
//
//- (void)willRemoveLogger {
//    // If you override me be sure to invoke [super willRemoveLogger];
//
//    [self performSaveAndSuspendSaveTimer];
//
//    [self destroySaveTimer];
//    [self destroyDeleteTimer];
//}
//
//- (void)logMessage:(DDLogMessage *)logMessage {
//    if ([self db_log:logMessage]) {
//        BOOL firstUnsavedEntry = (++_unsavedCount == 1);
//
//        if ((_unsavedCount >= _saveThreshold) && (_saveThreshold > 0)) {
//            [self performSaveAndSuspendSaveTimer];
//        } else if (firstUnsavedEntry) {
//            _unsavedTime = dispatch_time(DISPATCH_TIME_NOW, 0);
//            [self updateAndResumeSaveTimer];
//        }
//    }
//}
//
//- (void)flush {
//    // This method is invoked by DDLog's flushLog method.
//    //
//    // It is called automatically when the application quits,
//    // or if the developer invokes DDLog's flushLog method prior to crashing or something.
//
//    [self performSaveAndSuspendSaveTimer];
//}
//
//@end

 



