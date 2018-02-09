//
//  ApplicationWillTerminateNotificationViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 11/01/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "ApplicationWillTerminateNotificationViewController.h"


@interface ApplicationWillTerminateNotificationViewController ()

@end


@implementation ApplicationWillTerminateNotificationViewController

- (instancetype)init {
    if (self = [super init]) {
#if TARGET_OS_IOS
        NSString *notificationName = @"UIApplicationWillTerminateNotification";
#else
        NSString *notificationName = nil;

// On Command Line Tool apps AppKit may not be avaliable
#ifdef NSAppKitVersionNumber10_0

        if (NSApp) {
            notificationName = @"NSApplicationWillTerminateNotification";
        }

#endif

        if (!notificationName) {
            // If there is no NSApp -> we are running Command Line Tool app.
            // In this case terminate notification wouldn't be fired, so we use workaround.
            atexit_b(^{
                [self applicationWillTerminate:nil];
            });
        }

#endif /* if TARGET_OS_IOS */

        if (notificationName) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationWillTerminate:)
                                                         name:notificationName
                                                       object:nil];
        }
    }
    return self;
}

- (void)applicationWillTerminate:(NSNotification *__attribute__((unused)))notification {
    // ....
}

@end
