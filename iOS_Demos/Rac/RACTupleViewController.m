//
//  RACTupleViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 14/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "RACTupleViewController.h"
#import <ReactiveObjc/ReactiveObjC.h>


@interface RACTupleViewController ()

@end


@implementation RACTupleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // RACTuple : 元祖类，类似nsarray
    RACTuple *tuple = [RACTuple tupleWithObjectsFromArray:@[ @"213", @"321", @1 ]];

    // RACSequence : RAC 中的集合类， 用于替换NSArray 和 NSDictionary
    NSArray *    array = @[ @"213", @"321", @1 ];
    RACSequence *seq   = array.rac_sequence;

    RACSignal *signal = seq.signal;

    [signal subscribeNext:^(id _Nullable x) {
        NSLog(@"%@", x);
    }];

    // 遍历数组
    [array.rac_sequence.signal subscribeNext:^(id _Nullable x) {
        NSLog(@"%@", x);
    }];


    NSDictionary *dict = @{ @"d" : @"d",
                            @"a" : @"a" };

    [dict.rac_sequence.signal subscribeNext:^(id _Nullable x) {
        NSLog(@"%@", x);
        NSString *key   = x[0];
        NSString *value = x[1];

        // 解析元祖
        // 传解析出的变量名
        RACTupleUnpack(NSString * key1, NSString * value2) = x;
        NSLog(@"%@ %@", key, value);

    }];


    // map 会把集合中所有元素都映射成一个新的对象,返回的是一个sequence
    [[dict.rac_sequence map:^id _Nullable(NSDictionary *_Nullable value) {
        // ..
        return nil;
    }] array];
}

@end
