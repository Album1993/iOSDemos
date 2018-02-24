//
//  RacDisposibleViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 13/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "RacDisposibleViewController.h"
#import <ReactiveObjc/ReactiveObjC.h>

// RACSubscriber : 表示订阅者的意思， 用于发送信号，这是一个协议，不是一个类。只要遵守这个协议，就能create 创建信号，都有一个内部的订阅者，帮助他发送信号

// RACDisposible : 用于取消订阅，或者清理资源，当信号发送完成，或者发送错误的时候，就会触发它
// 使用场景： 不想监听某个信号时，可以通过他主动取消订阅信号


@interface RacDisposibleViewController ()

@property (nonatomic, strong) id<RACSubscriber> subscriber;

@end


@implementation RacDisposibleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    RACSignal *signal = [RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {

        [subscriber sendNext:@"123"];

        // 如果没有这个subscriber ，则取消立即执行，如果有这个subscriber 就不会执行dispose，就要手动去取消
        _subscriber = subscriber;
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"取消订阅");
        }];
    }];

    RACDisposable *disposable = [signal subscribeNext:^(id _Nullable x) {
        NSLog(@"%@", x);
    }];

    //这个就是主动取消，_scbscriber 在的情况下
    [disposable dispose];
}


@end
