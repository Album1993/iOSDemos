//
//  RACConcatViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 17/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "RACConcatViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>


@interface RACConcatViewController ()

@end


@implementation RACConcatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    RACSignal *signal = [RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
        NSLog(@"发送上半部分请求");
        [subscriber sendNext:@"上半部分数据"];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"上半部分结束");
        }];
    }];

    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
        [subscriber sendNext:@2];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"下半部分结束");
        }];

    }];

    // 连续连接

    RACSignal *concatsignal = [signal concat:signal2];
    [concatsignal subscribeNext:^(id _Nullable x) {
        // 会输出上半部分数据
        NSLog(@"%@", x);
    }];

    // 使用then
    RACSignal *thensignal = [signal then:^RACSignal *_Nonnull {
        return signal2;
    }];

    [thensignal subscribeNext:^(id _Nullable x) {
        // 只输出下半部分数据
        // 上半部分必须使用sendcomplete
        NSLog(@"%@", x);
    }];


    RACSubject *subject1 = [RACSubject subject];

    RACSubject *subject2 = [RACSubject subject];

    RACSignal *mergeSignal = [subject1 merge:subject2];

    [mergeSignal subscribeNext:^(id _Nullable x){
        // 任意信号发送的时候，都会来这个block

    }];


    // zip 必须所有信号都满足的情况，才能触发
    // 界面多个请求
    RACSignal *zipsignal = [subject1 zipWith:subject2];
    [zipsignal subscribeNext:^(id _Nullable x){
        // 返回{1，2}
    }];

    [subject1 sendNext:@1];
    [subject2 sendNext:@2];

    // 至少每个subject 发送一次数据
    // 比如页面多个文本框，并且文本框的值发生改变

    UITextField *text1 = [UITextField new];
    UITextField *text2 = [UITextField new];

    UIButton *btn = [UIButton new];

    // reduce 聚合的意思
    // reduce 的参数和数组的顺序是一致的
    RACSignal *combineLatestsignal = [RACSignal combineLatest:@[ text1, text2 ] reduce:^id(NSString *text1, NSString *text2) {
        return @(text1.length && text2.length);
    }];

    [combineLatestsignal subscribeNext:^(id _Nullable x){

    }];

    RAC(btn, enabled) = combineLatestsignal;
}


@end
