//
//  iOS_9ViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 20/01/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "iOS_9ViewController.h"

@interface iOS_9ViewController ()

@end

@implementation iOS_9ViewController

//- (void)setName:(NSString *)name
//{
//    if (name == nil) {
//        name = @"123";
//    }
//    _name = name;
//}
//- (NSString *)name
//{
//    if (_name == nil) {
//        _name = @"123";
//    }
//    return _name;
//}

// iOS9新出的关键字:用来修饰属性,或者方法的参数,方法的返回值
// 好处:
// 1.迎合swift
// 2.提高我们开发人员开发规范,减少程序员之间交流

// 注意:iOS9新出关键字nonnull,nullable只能修饰对象,不能修饰基本数据类型
//- (UIView *)view
//{
//    if (_view == nil) {
//        [self loadView];
//        [self viewDidLoad];
//    }
//
//    return _view;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //    _Null_unspecified:
    
    
    
    //    self setName:(NSString * _Nullable)
    
}

@end


@implementation test

-(void) testNullable {
    iOS_9ViewController * v = [iOS_9ViewController new];
}

@end
