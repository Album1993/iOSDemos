//
//  RACBindViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 17/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "RACBindViewController.h"
#import <ReactiveObjc/ReactiveObjC.h>
#import <ReactiveObjC/RACReturnSignal.h>


@interface RACBindViewController ()

@end


@implementation RACBindViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // bind ,给rac信号进行绑定，只要信号已发送数据，就能监听到，从而把发送数据改成自己想要的数据

    // 在开发中很少使用bind方法，bind 属于rac中的底层方法，rac 已经封装好了很多好用的方法。底层调用的首饰bind，用法比bind 简单

    // 创建信号
    RACSubject *subject = [RACSubject subject];
    // 绑定信号
    RACSignal *bindsignal = [subject bind:^RACSignalBindBlock _Nonnull {
        return ^RACSignal *(id value, BOOL *stop) {
            // 返回信号一定不能为nil
            return [RACReturnSignal return:value];
        };
    }];

    [bindsignal subscribeNext:^(id _Nullable x){

    }];

    [subject sendNext:@"123"];
}

@end
