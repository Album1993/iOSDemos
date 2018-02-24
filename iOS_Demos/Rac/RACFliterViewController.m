//
//  RACFliterViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 20/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "RACFliterViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>


@interface RACFliterViewController ()

@end


@implementation RACFliterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.


    UITextField *textfield = [UITextField new];

    [[textfield.rac_textSignal filter:^BOOL(NSString *_Nullable value) {
        return value.length > 5;
    }] subscribeNext:^(NSString *_Nullable x){

    }];

    [[textfield.rac_textSignal ignore:@1] subscribeNext:^(NSString *_Nullable x){

    }];

    //take 获取多少次信号
    [[textfield.rac_textSignal take:1] subscribeNext:^(NSString *_Nullable x){

    }];


    [[textfield.rac_textSignal takeUntil:self.rac_deallocDisposable] subscribeNext:^(NSString *_Nullable x){

    }];

    // 和上一个信号相同就不会发送

    [[textfield.rac_textSignal distinctUntilChanged] subscribeNext:^(NSString *_Nullable x){

    }];

    [[textfield.rac_textSignal skip:2] subscribeNext:^(NSString *_Nullable x){

    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
