//
//  NotifyRegisterDispatchViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 10/01/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "NotifyRegisterDispatchViewController.h"
#import <notify.h>

#define EVENT "com.mycompany.bs"


// 这个可以用来获取系统的一些通知
@interface NotifyRegisterDispatchViewController ()

@end

@implementation NotifyRegisterDispatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(50, 200, 200, 30)];
    [button setTitle:@"send Notification" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor blueColor]];
    
    [ button addTarget:self action:@selector(sendNotification) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    [self registerForNotifications];
}

-(void) sendNotification {
    double delayInSeconds = 0.001;
    
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0l);
    dispatch_async(q, ^(void) {
        notify_set_state(notifyToken, 2);
        notify_post(EVENT);
    });
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, q, ^(void){
        notify_set_state(notifyToken, 3);
        notify_post(EVENT);
    });
}

static int notifyToken = 0;

- (void)registerForNotifications {
    int result = notify_register_dispatch(EVENT,
                                          &notifyToken,
                                          dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0l),
                                          ^(int info) {
                                              uint64_t state;
                                              notify_get_state(notifyToken, &state);
                                              NSLog(@"notify_register_dispatch() : %d", (int)state);
                                          });
    if (result != NOTIFY_STATUS_OK) {
        NSLog(@"register failure = %d", result);
    }
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
                                    NULL, // observer
                                    notifyCallback, // callback
                                    CFSTR(EVENT), // event name
                                    NULL, // object
                                    CFNotificationSuspensionBehaviorCoalesce);
}

static void notifyCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    uint64_t state;
    notify_get_state(notifyToken, &state);
    NSLog(@"notifyCallback(): %d", (int)state);
}



@end
