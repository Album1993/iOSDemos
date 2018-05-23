//
//  IMPDemo.m
//  iOS_Demos
//
//  Created by 张一鸣 on 09/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "IMPDemo.h"
#import <objc/runtime.h>

//IMP就是Implementation的缩写，顾名思义，它是指向一个方法实现的指针，每一个方法都有一个对应的IMP，
//所以，我们可以直接调用方法的IMP指针，来避免方法调用死循环的问题。

typedef id (*_IMP)(id, SEL, ...);    // 给有返回值的函数使用
typedef void (*_VIMP)(id, SEL, ...); // 给没有返回值的函数使用


@implementation IMPDemo

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method pick     = class_getClassMethod(self, @selector(pick));
        _VIMP  pick_imp = (_VIMP)method_getImplementation(pick);
        method_setImplementation(pick, imp_implementationWithBlock(^(id target, SEL selector) {
            pick_imp(target, @selector(pick));
            NSLog(@"%@ did load", target);
        }));
    });
}

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)pick {
}

@end
