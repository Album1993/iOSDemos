//
//  BaseNaviViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 10/01/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "BaseNaviViewController.h"


@interface BaseNaviViewController ()

@end


@implementation BaseNaviViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (![[super topViewController] isKindOfClass:[viewController class]]) {
        // 如果和上一个控制器一样，隔绝此操作
        [super pushViewController:viewController animated:animated];
    }
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
