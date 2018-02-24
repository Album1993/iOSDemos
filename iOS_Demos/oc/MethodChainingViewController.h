//
//  MethodChainingViewController.h
//  iOS_Demos
//
//  Created by 张一鸣 on 13/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MethodChainingViewController : UIViewController

@end


@interface Calculate : NSObject

// 响应式方法之后千万不能带参数
- (Calculate * (^)(int))add;

@property (nonatomic, assign) int result;


@end


@interface NSObject (Chaining)

+ (int)mm_makeCalculate:(void (^)(Calculate *))block;

@end
