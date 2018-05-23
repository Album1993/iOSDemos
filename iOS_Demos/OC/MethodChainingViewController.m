//
//  MethodChainingViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 13/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "MethodChainingViewController.h"


@implementation Calculate

- (Calculate * (^)(int))add {
    return ^(int value) {
        _result += value;
        return self;
    };
}

@end


@implementation NSObject (Chaining)

+ (int)mm_makeCalculate:(void (^)(Calculate *))block {
    Calculate *c = [Calculate new];
    block(c);
    return c.result;
}

@end


@interface MethodChainingViewController ()

@end


@implementation MethodChainingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [NSObject mm_makeCalculate:^(Calculate *cal) {

        cal.add(5);
    }];
}

@end
