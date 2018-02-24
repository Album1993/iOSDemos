//
//  RacLifeSelectorViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 14/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "RacLifeSelectorViewController.h"
#import <ReactiveObjc/ReactiveObjC.h>


@interface RacLifeSelectorViewController ()

@end


@implementation RacLifeSelectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 多次请求完成才能搭建界面
    RACSignal *hotSignal = [RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
        [subscriber sendNext:@"hot"];
        return nil;
    }];

    RACSignal *newSignal = [RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
        [subscriber sendNext:@"newd"];
        return nil;
    }];

    [self rac_liftSelector:@selector(updateUI:newd:) withSignalsFromArray:@[ hotSignal, newSignal ]];
}

- (void)updateUI:(NSString *)hot newd:(NSString *)newd {
}

@end
