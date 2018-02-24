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
//@class CurryingViewController;
//@class SequenceViewController;
@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableview;

@property (nonatomic, strong) NSDictionary *dictionary;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    self.tableview = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.tableview];
    self.tableview.delegate   = self;
    self.tableview.dataSource = self;
    [self.tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"zymtableview"];
    self.dictionary = @{
        @"GCD" : @"GCDTableViewController",
        @"AppAccident" : @"AppAccidentTableViewController",
        @"DeviceInformation" : @"DeviceInformationTableViewController",
        @"Http" : @"HttpTableViewController",
        @"Currying" : @"CurryingViewController",
        @"Sequence" : @"SequenceViewController"

    };
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)testDD {
    NSLog(@"dddd--------");
}

@end
