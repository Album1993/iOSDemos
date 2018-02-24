//
//  SVW_ViewControllerProtocol.h

#import <Foundation/Foundation.h>


/**
 为 ViewController 绑定方法协议
 */
@protocol SVW_ViewControllerProtocol <NSObject>

#pragma mark - 方法绑定
@required
/// 初始化数据
- (void)svw_initialDefaultsForController;

/// 绑定 vm
- (void)svw_bindViewModelForController;

/// 创建视图
- (void)svw_createViewForConctroller;

/// 配置导航栏
- (void)svw_configNavigationForController;

@end
