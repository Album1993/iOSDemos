//
//  RunLoopViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 06/03/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "RunLoopViewController.h"


@interface RunLoopViewController ()

@end


@implementation RunLoopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self defaultRunloop];
}

- (void)defaultRunloop {
    NSLog(@"----%@", [NSRunLoop currentRunLoop]);
}

static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
}

- (void)threadMain {
    NSRunLoop *runloop                = [NSRunLoop currentRunLoop];
    CFRunLoopObserverContext context  = {0, (__bridge void *)(self), NULL, NULL, NULL};
    CFRunLoopObserverRef     observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &runLoopObserverCallBack, &context);

    if (observer) {
        CFRunLoopRef cfloop = [runloop getCFRunLoop];
        CFRunLoopAddObserver(cfloop, observer, kCFRunLoopDefaultMode);
    }
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(dofireTimer:) userInfo:nil repeats:YES];
    NSInteger loopcount = 10;

    do {
        [runloop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        loopcount--;
    } while (loopcount);
}

- (void)dofireTimer:(NSTimer *)timer {
}

- (void)skeletonThreadMain {
    // set up an autorelease pool here if not using garbage collection
    BOOL done = NO;

    // add your sources or timers to the run loop and do any other setup


    do {
        // start the run loop but return after each source is handled
        SInt32 result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, YES);

        // if a source expliticly stopped the run loop . or if there are no
        // sources or timers . go ahead and exit

        if ((result == kCFRunLoopRunStopped) || (result == kCFRunLoopRunFinished)) {
            done = YES;
        }

        // check for any other exit coditions here and set the
        // done varible as needed
    } while (!done);

    // clean up code here . Be sure to release any allocated autorelease pools
}


@end
