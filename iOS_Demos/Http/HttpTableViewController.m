//
//  HttpTableViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 16/01/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "HttpTableViewController.h"

@interface HttpTableViewController ()

@end

@implementation HttpTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dictionary = @{
                        @"单向/双向认证": @"HttpsAuthenticationViewController",
                        @"ytknetworkhttps": @"YtknetworkHttpsSetting"
                        };

}

@end
