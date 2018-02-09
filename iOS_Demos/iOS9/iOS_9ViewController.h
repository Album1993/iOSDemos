//
//  iOS_9ViewController.h
//  iOS_Demos
//
//  Created by 张一鸣 on 20/01/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "ViewController.h"


@interface iOS_9ViewController : ViewController

/*
 nullable作用:表示可以为空
 nullable书写规范:
 // 方式一:
 @property (nonatomic, strong, nullable) NSString *name;
 // 方式二:
 @property (nonatomic, strong) NSString *_Nullable name;
 // 方式三:
 @property (nonatomic, strong) NSString *__nullable name;
 
 */
//@property (nonatomic, strong) NSString *__nullable name;
//@property (nonatomic, strong) NSString * name;

/*
 nonnull: non:非 null:空
 
 书写格式:
 @property (nonatomic, strong, nonnull) NSString *icon;
 
 @property (nonatomic, strong) NSString * _Nonnull icon;
 
 @property (nonatomic, strong) NSString * __nonnull icon;
 
 */

/*
 在NS_ASSUME_NONNULL_BEGIN和NS_ASSUME_NONNULL_END之间,定义的所有对象属性和方法默认都是nonnull
 */

// 方法中,关键字书写规范
/**
 - (nonnull NSString *)test:(nonnull NSString *)str;
 - (NSString * _Nonnull)test1:(NSString * _Nonnull)str;
 */

//@property (nonatomic, assign) int age;

/*
 null_resettable: get:不能返回为空, set可以为空
 // 注意;如果使用null_resettable,必须 重写get方法或者set方法,处理传递的值为空的情况
 // 书写方式:
 @property (nonatomic, strong, null_resettable) NSString *name;
 */


/*
 _Null_unspecified:不确定是否为空
 书写方式只有这种
 方式一
 @property (nonatomic, strong) NSString *_Null_unspecified name;
 方式二
 @property (nonatomic, strong) NSString *__null_unspecified name;
 */


@end


@interface test : NSObject

@end
