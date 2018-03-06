//
//  ViewController+NonBase.h

#import <UIKit/UIKit.h>
#import "SVW_ViewControllerProtocol.h"


@interface UIViewController (NonBase)

/**
 去Model&&表征化参数列表
 */
@property (nonatomic, strong) NSDictionary *params;

/**
 ViewModel 属性
 */
@property (nonatomic, strong) id<SVW_ViewControllerProtocol> viewModel;

#pragma mark - 通用类

/**
 返回Controller的当前bounds
 
 @param hasNav 是否有导航栏
 @param hasTabBar 是否有tabbar
 @return 坐标
 */
- (CGRect)svw_visibleBoundsShowNav:(BOOL)hasNav showTabBar:(BOOL)hasTabBar;

/**
 隐藏键盘
 */
- (void)svw_hideKeyBoard;

@end
