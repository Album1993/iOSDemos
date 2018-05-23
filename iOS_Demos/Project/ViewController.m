//
//  ViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 10/01/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "ViewController.h"
#import "GCDTableViewController.h"
#import "AppAccidentTableViewController.h"
#import "DeviceInformationTableViewController.h"
#import "HttpTableViewController.h"
#import "iOS_Demos-Swift.h"


@interface ViewController () <UITableViewDelegate, UITableViewDataSource, SVW_ViewControllerProtocol>

@property (nonatomic, strong) UITableView *tableview;

@property (nonatomic, strong) NSDictionary *dictionary;

@end


@implementation ViewController

- (void)svw_initialDefaultsForController {
}

// 这里可以使用rac绑定数据，也可以是基础数据类型的赋值
/// 绑定 vm
- (void)svw_bindViewModelForController {
    self.dictionary = @{
        @"GCD" : @"GCDTableViewController",
        @"AppAccident" : @"AppAccidentTableViewController",
        @"DeviceInformation" : @"DeviceInformationTableViewController",
        @"Http" : @"HttpTableViewController",
        @"Currying" : @"CurryingViewController",
        @"Sequence" : @"SequenceViewController",
        @"EscapingView" : @"EscapingViewController",
        @"BlurViewController" : @"BlurViewController",
        @"MirrorBinaryTreeViewController" : @"MirrorBinaryTreeViewController",
        @"RunLoopViewController" : @"RunLoopViewController",
        @"BizarreQuestionViewController" : @"BizarreQuestionViewController",
        @"OperationQueueViewController" : @"OperationQueueViewController"
    };
}

// 这里的创建视图并不是说我在这里初始化试图或者在这里创建视图元素，
// 而是给视图一些基础数据赋值
// 基本的创建视图都要新建一个view，然后在loadview中替换基础的view
// 非常不建议直接在controller中创建元素
/// 创建视图
- (void)svw_createViewForConctroller {
    // 这里这么写是因为如果没有任何自定义元素的空白view
    self.tableview = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.tableview];
    self.tableview.delegate                       = self;
    self.tableview.dataSource                     = self;
    self.tableview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    [self.tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"zymtableview"];


    Class cls = NSClassFromString(@"DispatchSemaphoreViewController");
    [self.navigationController pushViewController:[cls new] animated:YES];
}

/// 配置导航栏
- (void)svw_configNavigationForController {
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dictionary.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"zymtableview" forIndexPath:indexPath];

    cell.textLabel.text = self.dictionary[self.dictionary.allKeys[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Class cls = NSClassFromString(self.dictionary[self.dictionary.allKeys[indexPath.row]]);
    [self.navigationController pushViewController:[cls new] animated:YES];
}

@end
