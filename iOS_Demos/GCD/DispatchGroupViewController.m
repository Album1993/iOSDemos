//
//  DispatchGroupViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 12/01/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "DispatchGroupViewController.h"

@interface DispatchGroupViewController ()

@end

@implementation DispatchGroupViewController

// 常用方法 dispatch_group_async
// dispatch_group_enter(group)、dispatch_group_leave(group)（必须成对出现）
// dispatch_group_notify
// dispatch_group_wait

// 很多人在不同的线程调用async ，其实这样写并不好。 最好是使用dispatch_semaphore_t配合

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//这种就是非常不好的写法
- (void)groupSyncBad
{
    dispatch_queue_t disqueue =  dispatch_queue_create("com.shidaiyinuo.NetWorkStudy", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t disgroup = dispatch_group_create();
    dispatch_group_async(disgroup, disqueue, ^{
        
        NSLog(@"任务一完成");
    });
    
    dispatch_group_async(disgroup, disqueue, ^{
        
        sleep(8);
        NSLog(@"任务二完成");
    });
    
    dispatch_group_notify(disgroup, disqueue, ^{
        
        NSLog(@"dispatch_group_notify 执行");
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        dispatch_group_wait(disgroup, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC));
        NSLog(@"dispatch_group_wait 结束");
    });
}


// 这种就是enter 和 leave 的写法
- (void)groupSyncEnterAndLeave
{
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        sleep(5);
        NSLog(@"任务一完成");
        dispatch_group_leave(group);
    });
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        sleep(8);
        NSLog(@"任务二完成");
        dispatch_group_leave(group);
    });
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        
        NSLog(@"任务完成");
    });
}

//  这里要注意的就是并行异步的队列不能使用group
- (void)groupSync2
{
    dispatch_queue_t dispatchQueue = dispatch_queue_create("ted.queue.next1", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_group_t dispatchGroup = dispatch_group_create();
    dispatch_group_async(dispatchGroup, dispatchQueue, ^(){
        
        dispatch_async(globalQueue, ^{
            
            sleep(5);
            NSLog(@"任务一完成");
        });
    });
    dispatch_group_async(dispatchGroup, dispatchQueue, ^(){
        
        dispatch_async(globalQueue, ^{
            
            sleep(8);
            NSLog(@"任务二完成");
        });
    });
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(){
        NSLog(@"notify：任务都完成了");
    });
    dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER);
}




@end
