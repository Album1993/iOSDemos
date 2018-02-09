//
//  GCDTableViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 10/01/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "GCDTableViewController.h"
#import "NotifyRegisterDispatchViewController.h"


@interface GCDTableViewController ()

@end


@implementation GCDTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dictionary = @{
        @"NotifyRegisterDispatch" : @"NotifyRegisterDispatchViewController",
        @"GlobalQueueInitialAndQueueSpec" : @"GlobalQueueInitialAndQueueSpec",
        @"DispatchSourceTypeTimer" : @"DispatchSourceTypeTimerViewController",
        @"DispatchGroup" : @"DispatchGroupViewController",
        @"DispathcAsyncAndSync" : @"DispathcAsyncAndSyncViewController"
    };
}


@end
