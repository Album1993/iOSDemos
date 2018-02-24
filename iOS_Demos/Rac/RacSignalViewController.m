//
//  RacSignalViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 13/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "RacSignalViewController.h"
#import <ReactiveObjc/ReactiveObjC.h>


// RACSignal : 信号类， 一般表示将来有数据传递， 只要有数据改变， 信号内部接收到数据， 就会马上发出数据。

// 信号类（RACSignal）, 只是表示当数据改变时， 信号内部会发出数据，它本身不具备发送信号的能力， 而是交给一个订阅者去发出

// 默认一个信号是冷信号， 也就是值改变了，也不会触发，只有订阅这个信号了，这个信号才会成为热信号。

// 如何订阅信号，调用信号RACSignal 的subscribeNext就能订阅


@interface RacSignalViewController ()

@end


@implementation RacSignalViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 创建信号
    // 订阅信号
    // 发送信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
        // didSubscribe调用：只要一个信号被订阅之后就会调用
        // didSubscribe :发送数据
        [subscriber sendNext:@1];
        return nil;
    }];

    [signal subscribeNext:^(id _Nullable x) {
        // x: 信号发送的内容
        NSLog(@"%@", x);
    }];
}

@end
