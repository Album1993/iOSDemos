//
//  RACMapViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 17/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "RACMapViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <ReactiveObjC/RACReturnSignal.h>


@interface RACMapViewController ()

@end


@implementation RACMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    RACSubject *subject = [RACSubject subject];
    // flattenmap 不用验证返回值
    // flattemmap 用于验证信号中的信号
    //
    RACSignal *signal = [subject flattenMap:^__kindof RACSignal *_Nullable(id _Nullable value) {
        value = [NSString stringWithFormat:@"%@", value];
        return [RACReturnSignal return:value];
    }];

    [signal subscribeNext:^(id _Nullable x){

    }];

    [subject sendNext:@1];

    RACSubject *signalOfSignals = [RACSubject subject];
    RACSubject *signal2         = [RACSubject subject];
    [signalOfSignals subscribeNext:^(id _Nullable x) {
        [x subscribeNext:^(id _Nullable x) {
            NSLog(@"%@", x);
        }];
    }];


    [signalOfSignals sendNext:signal2];

    RACSignal *bindSignal = [signalOfSignals flattenMap:^__kindof RACSignal *_Nullable(id _Nullable value) {
        return value;
    }];

    [bindSignal subscribeNext:^(id _Nullable x) {
        NSLog(@"%@", x);
    }];


    // map 返回的类型是个id
    RACSignal *mapsignal = [subject map:^id _Nullable(id _Nullable value) {
        return @"111";
    }];

    [mapsignal subscribeNext:^(id _Nullable x) {
        NSLog(@"%@", x);
    }];

    [subject sendNext:@"123"];
}


@end
