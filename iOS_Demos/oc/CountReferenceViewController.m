//
//  CountReferenceViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 09/03/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "CountReferenceViewController.h"


@interface CountReferenceViewController ()


@end


@implementation CountReferenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.button = [UIButton new];
    [self.button setFrame:CGRectMake(100, 200, 70, 60)];
    [self.button setTitle:@"lllll" forState:UIControlStateNormal];
    [self.view addSubview:self.button];
    [self.button addTarget:self action:@selector(btncl) forControlEvents:UIControlEventTouchUpInside];
}


- (void)btncl {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"0----------");
}

@end
