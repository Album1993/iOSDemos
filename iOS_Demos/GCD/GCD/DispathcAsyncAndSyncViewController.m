//
//  DispathcAsyncAndSyncViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 17/01/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "DispathcAsyncAndSyncViewController.h"


@interface DispathcAsyncAndSyncViewController ()

@end


@implementation DispathcAsyncAndSyncViewController

static dispatch_queue_t _loggingQueue;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //    [self dispatchAsyncSerial];
    //    [self dispatchSyncSerial];
    //    [self dispatchAsyncConcurrent];
    //    [self dispatchSyncConcurrent];
    [self outerSerialAsync];
}

- (void)dispatchAsyncSerial {
    NSLog(@"-----------dispatch serial -------- async ---------");
    dispatch_queue_t queue = dispatch_queue_create("cocoa.lumberjack2", NULL);
    for (int i = 0; i < 5; i++) {
        dispatch_async(queue, ^{
            NSLog(@"threadS_A %@", [NSThread currentThread]);
        });
    }
    NSLog(@"-----------end  ------------------------------------");
    NSLog(@"\n\n\n");
}

- (void)dispatchSyncSerial {
    NSLog(@"-----------dispatch serial -------- sync ---------");
    dispatch_queue_t queue = dispatch_queue_create("cocoa.lumberjack2", NULL);
    for (int i = 0; i < 5; i++) {
        dispatch_sync(queue, ^{
            NSLog(@"threadS_S %@", [NSThread currentThread]);
        });
    }
    NSLog(@"-----------end  ------------------------------------");
    NSLog(@"\n\n\n");
}

- (void)dispatchAsyncConcurrent {
    NSLog(@"-----------dispatch Concurrent -------- async ---------");
    dispatch_queue_t queue = dispatch_queue_create("cocoa.lumberjack2", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < 5; i++) {
        dispatch_async(queue, ^{
            NSLog(@"threadC_A %@", [NSThread currentThread]);
        });
    }
    NSLog(@"-----------end  ------------------------------------");
    NSLog(@"\n\n\n");
}


- (void)dispatchSyncConcurrent {
    NSLog(@"-----------dispatch Concurrent -------- async ---------");
    dispatch_queue_t queue = dispatch_queue_create("cocoa.lumberjack2", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < 5; i++) {
        dispatch_sync(queue, ^{
            NSLog(@"threadC_S %@", [NSThread currentThread]);
        });
    }
    NSLog(@"-----------end  ------------------------------------");
    NSLog(@"\n\n\n");
}

- (void)outerSerialSync {
    dispatch_queue_t queue = dispatch_queue_create("cocoa.lumberjack2", NULL);
    dispatch_sync(queue, ^{
        [self dispatchAsyncSerial];
        [self dispatchSyncSerial];
        [self dispatchAsyncConcurrent];
        [self dispatchSyncConcurrent];
    });
}

- (void)outerSerialAsync {
    dispatch_queue_t queue = dispatch_queue_create("cocoa.lumberjack2", NULL);
    dispatch_async(queue, ^{
        [self dispatchAsyncSerial];
        [self dispatchSyncSerial];
        [self dispatchAsyncConcurrent];
        [self dispatchSyncConcurrent];
    });
}


- (void)outerConcorrectSync {
    dispatch_queue_t queue = dispatch_queue_create("cocoa.lumberjack2", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(queue, ^{
        [self dispatchAsyncSerial];
        [self dispatchSyncSerial];
        [self dispatchAsyncConcurrent];
        [self dispatchSyncConcurrent];
    });
}


- (void)outerConcorrectAsync {
    dispatch_queue_t queue = dispatch_queue_create("cocoa.lumberjack2", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [self dispatchAsyncSerial];
        [self dispatchSyncSerial];
        [self dispatchAsyncConcurrent];
        [self dispatchSyncConcurrent];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
