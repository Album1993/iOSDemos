//
//  RACNormalViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 14/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "RACNormalViewController.h"
#import <ReactiveObjc/ReactiveObjC.h>
#import <ReactiveObjC/NSObject+RACKVOWrapper.h>


@interface RACNormalViewController ()

@property (nonatomic, strong) UIButton *btn;


@property (nonatomic, strong) UIView *lview;

@end


@implementation RACNormalViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 1. 代替代理 RacSubject
    // 查看某对象是否调用某方法
    [[self rac_signalForSelector:@selector(didReceiveMemoryWarning)] subscribeNext:^(RACTuple *_Nullable x) {
        NSLog(@"控制器有memory warning");
    }];

    // 2. 只要有传值，就使用racsubject , 没有传值， 就使用rac_signalforSelector
    [[_btn rac_signalForSelector:@selector(btnclick:)] subscribeNext:^(RACTuple *_Nullable x) {
        NSLog(@"按钮被点击了");
    }];

    //kvo
    [self.view rac_observeKeyPath:@"frame" options:NSKeyValueObservingOptionNew observer:nil block:^(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent){

    }];
    [[self.view rac_valuesForKeyPath:@"frame" observer:nil] subscribeNext:^(id _Nullable x) {
        NSLog(@"%@", x);
    }];

    // 3, 监听事件
    [[_btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl *_Nullable x) {
        NSLog(@"");
    }];

    // 代替通知
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(NSNotification *_Nullable x) {
        NSLog(@"%@", x);
    }];

    // 监听文本框
    UITextField *textfield = [UITextField new];
    [textfield.rac_textSignal subscribeNext:^(NSString *_Nullable x){

    }];
}


- (IBAction)btnclick:(id)sender {
}

@end
