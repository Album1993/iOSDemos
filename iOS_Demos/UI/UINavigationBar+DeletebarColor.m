//
//  UINavigationBar+DeletebarColor.m
//  iOS_Demos
//
//  Created by 张一鸣 on 09/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "UINavigationBar+DeletebarColor.h"
#import <objc/runtime.h>


@implementation UINavigationBar (DeletebarColor)

+ (void)load {
    //方法交换应该被保证，在程序中只会执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        //首先动态添加方法。如果类中不存在这个方法的实现，添加成功
        BOOL notAdded = class_addMethod(self, @selector(layoutSubviews), [self instanceMethodForSelector:@selector(__layoutSubviews)], method_getTypeEncoding(class_getInstanceMethod(self, @selector(__layoutSubviews))));

        //因为UINavigationBar已经包含了layoutSubviews的实现，所以不会被添加成功
        if (notAdded) {
            //如果UINavigationBar没有layoutSubviews这个方法的实现，那么添加成功，将被交换方法的实现替换到这个并不存在的实现
            class_replaceMethod(self, @selector(__layoutSubviews), [self instanceMethodForSelector:@selector(layoutSubviews)], method_getTypeEncoding(class_getInstanceMethod(self, @selector(layoutSubviews))));
        } else {
            //否则交换两个方法的实现
            method_exchangeImplementations(class_getInstanceMethod(self, @selector(layoutSubviews)), class_getInstanceMethod(self, @selector(__layoutSubviews)));
        }

    });
}

- (void)__layoutSubviews {
    //这不是递归，其实调用了[self layoutSubviews];
    [self __layoutSubviews];

    if (self.ky_hideStatusBarBackgroungView) {
        Class backgroundClass          = NSClassFromString(@"_UINavigationBarBackground");
        Class statusBarBackgroundClass = NSClassFromString(@"_UIBarBackgroundTopCurtainView");

        for (UIView *aSubview in self.subviews) {
            if ([aSubview isKindOfClass:backgroundClass]) {
                aSubview.backgroundColor = [UIColor clearColor];

                for (UIView *aaSubview in aSubview.subviews) {
                    if ([aaSubview isKindOfClass:statusBarBackgroundClass]) {
                        //aaSubview.hidden = YES;
                        aaSubview.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.01];
                    }
                    //                    这个就是去寻找他添加图片的那个layer ，做下mask遮挡就行了
                    //                    if ([aaSubview isKindOfClass:navBarBackgoundImageClass]) {
                    //                        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:aaSubview.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(4.5, 4.5)];
                    //                        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
                    //                        maskLayer.frame = aaSubview.bounds;
                    //                        maskLayer.path = maskPath.CGPath;
                    //                        aaSubview.layer.mask = maskLayer;
                    //                    }
                }
            }
        }
    }
}

//添加关联对象
- (void)setKy_hideStatusBarBackgroungView:(BOOL)yesOrno {
    objc_setAssociatedObject(self, @selector(ky_hideStatusBarBackgroungView), @(yesOrno), OBJC_ASSOCIATION_ASSIGN);

    [self setNeedsLayout];
}

//获取关联对象
- (BOOL)ky_hideStatusBarBackgroungView {
    return objc_getAssociatedObject(self, _cmd);
}


@end
