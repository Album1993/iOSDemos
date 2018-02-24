//
//  RACSubjectViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 13/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "RACSubjectViewController.h"
#import <ReactiveObjc/ReactiveObjC.h>


@interface RACSubjectViewController ()

@property (nonatomic, assign) RACSubject *btnclick;

@end


@implementation RACSubjectViewController


// RACSubject : 信号的提供者，自己可以充当信号，又能发送信号
// 使用场景，通常代替代理，有了它就可以不需要使用代理了

- (void)viewDidLoad {
    [super viewDidLoad];

    // 1. 创建信号，
    RACSubject *subject = [RACSubject subject];

    // 2. 订阅信号
    [subject subscribeNext:^(id _Nullable x) {
        NSLog(@"订阅者1：%@", x);
    }];

    [subject subscribeNext:^(id _Nullable x) {
        NSLog(@"订阅者2：%@", x);
    }];


    // 3. 发送数据
    [subject sendNext:@1];

    // 执行流程
    // 创建subscribers 数组，订阅信号，创建个subscriber，保存订阅者，发送数据，遍历所有订阅者，

    // RACSubject被订阅，仅仅只是保存订阅者吗，其他什么都不干
    // 只用sendnext 的时候，才触发下订阅事件
}

- (void)racreplaysubject {
    RACReplaySubject *subject = [RACReplaySubject subject];

    [subject sendNext:@1];

    [subject subscribeNext:^(id _Nullable x) {
        NSLog(@"%@", x);
    }];


    // 流程
    // 创建_subscribers 和 _valuereceiver

    // RACReplaySubject 发送数据
    // 1. 保存值
    // 2. 遍历所有订阅者

    // RACReplaySubject 可以先发送信号
}


- (RACSubject *)btnclick {
    if (_btnclick == nil) {
        _btnclick = [RACSubject subject];
    }
    return _btnclick;
}

- (IBAction)btnclick:(id)sender {
    [_btnclick sendNext:@"1"];
}

@end
