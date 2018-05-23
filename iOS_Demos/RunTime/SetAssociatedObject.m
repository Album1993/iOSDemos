//
//  SetAssociatedObject.m
//  iOS_Demos
//
//  Created by 张一鸣 on 09/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "SetAssociatedObject.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>


@implementation SetAssociatedObject

@end


// 链接本质就是添加属性
//属性 其实就是get/set 方法。我们可以使用  objc_setAssociatedObject/objc_getAssociatedObject  实现 动态向类中添加属性
@interface UILabel (Associate)

- (void)setFlashColor:(UIColor *)flashColor;

- (UIColor *)getFlashColor;

@end


@implementation UILabel (Associate)

static char flashColorKey;

- (void)setFlashColor:(UIColor *)flashColor {
    objc_setAssociatedObject(self, &flashColorKey, flashColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)getFlashColor {
    return objc_getAssociatedObject(self, &flashColorKey);
}
@end


typedef void (^successBlock)(NSInteger buttonIndex);


@interface UIAlertView (Block)

- (void)showWithBlock:(successBlock)block;

@end


static const char alertKey;


@implementation UIAlertView (Block)

- (void)showWithBlock:(successBlock)block {
    if (block) {
        objc_setAssociatedObject(self, &alertKey, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        self.delegate = self;
    }

    [self show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    successBlock block = objc_getAssociatedObject(self, &alertKey);

    block(buttonIndex);
}

@end

typedef void (^btnBlock)(void);


@interface UIButton (Block)

- (void)handelWithBlock:(btnBlock)block;

@end

static const char btnKey;


@implementation UIButton (Block)

- (void)handelWithBlock:(btnBlock)block {
    if (block) {
        objc_setAssociatedObject(self, &btnKey, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    [self addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnAction {
    btnBlock block = objc_getAssociatedObject(self, &btnKey);

    block();
}

@end
