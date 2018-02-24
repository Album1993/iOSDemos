//
//  RACCommandViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 15/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "RACCommandViewController.h"
#import <ReactiveObjc/ReactiveObjC.h>


@interface RACCommandViewController ()

@end


@implementation RACCommandViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // RACCommand 处理事件，可以把事件如何处理，事件中的数据如何传递，包装到这个类中，他可以很方便的监控事件的执行流程
    // 使用场景， 按钮点击， 网络请求
    // 不能返回一个空的信号，必须要有信号

    // 1: 创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *_Nonnull(id _Nullable input) {

        // input 就是执行命令传入的参数
        // block调用：执行命令的时候就会调用
        NSLog(@"%@", input);

        return [RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {

            [subscriber sendNext:@"2"];
            [subscriber sendCompleted];
            return nil;
        }];
    }];


    // 如何拿到执行命令中产生的数据
    // 订阅命令内部的信号
    // 1 方式一：
    RACSignal *signal = [command execute:@1];

    // 方式二：
    // executionSignals信号源，signal of signals：信号的信号：发送的数据就是信号
    // 必须要在执行命令前订阅
    [command.executionSignals subscribeNext:^(RACSignal *signal) {
        NSLog(@"%@", signal);
        [signal subscribeNext:^(id _Nullable x) {
            NSLog(@"%@", x);
        }];
    }];

    // 3 获取最新信号， 只能用于信号中的信号
    [command.executionSignals.switchToLatest subscribeNext:^(id _Nullable x) {
        NSLog(@"%@", x);
    }];

    // 2: 执行命令
    [command execute:@"1"];


    [command.executing subscribeNext:^(NSNumber *_Nullable x) {
        if ([x boolValue] == YES) {
            NSLog(@"当前正在执行");
        } else {
            NSLog(@"执行完成");
        }
    }];
}


@end
