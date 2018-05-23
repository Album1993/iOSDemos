//
//  FunctionProgrammingViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 13/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "FunctionProgrammingViewController.h"


@interface CalculateMan : NSObject

@property (nonatomic, assign) int result;

- (CalculateMan *)calculate:(int (^)(int))calB;

- (void)dd;

@end


@implementation CalculateMan

- (CalculateMan *)calculate:(int (^)(int))calB {
    _result = calB(_result);
    return self;
}

- (void)dd {
}

@end


@interface FunctionProgrammingViewController ()

@end


@implementation FunctionProgrammingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CalculateMan *c = [CalculateMan new];

    [[c calculate:^(int value) {
        return value + 5;
        // 存放所有的计算方法
    }] dd];
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
