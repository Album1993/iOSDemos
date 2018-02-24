//
//  RACMacroViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 14/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "RACMacroViewController.h"
#import <ReactiveObjc/ReactiveObjC.h>


@interface RACMacroViewController ()

@end


@implementation RACMacroViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    UITextField *textfield = [UITextField new];
    UILabel *    label     = [UILabel new];

    RAC(label, text) = textfield.rac_textSignal;

    [RACObserve(self.view, frame) subscribeNext:^(id _Nullable x){

    }];

    RACTuple *tuple = RACTuplePack(@1, @2, @3);
}


@end
