//
//  RACMulticastViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 14/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "RACMulticastViewController.h"
#import <ReactiveObjc/ReactiveObjC.h>


@interface RACMulticastViewController ()

@end


@implementation RACMulticastViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    RACSignal *signal = [RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
        [subscriber sendNext:@1];
        return nil;
    }];

    // 每次订阅都发送一次
    [signal subscribeNext:^(id _Nullable x) {
        NSLog(@"订阅者1%@", x);
    }];

    [signal subscribeNext:^(id _Nullable x) {
        NSLog(@"订阅者2%@", x);
    }];

    // 只发送一次数据，但是每次订阅都能拿到数据

    // 不管订阅多少次信号，只发送一次信号
    // 创建信号
    // 必须要有信号， 把信号转换成连接类
    // 订阅连接类的信号
    // 连接

    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
        NSLog(@"1");
        [subscriber sendNext:@"1"];
        return nil;
    }];

    RACMulticastConnection *connection = [signal2 publish];

    [connection.signal subscribeNext:^(id _Nullable x){

    }];

    [connection.signal subscribeNext:^(id _Nullable x){

    }];


    [connection connect];
}


@end
