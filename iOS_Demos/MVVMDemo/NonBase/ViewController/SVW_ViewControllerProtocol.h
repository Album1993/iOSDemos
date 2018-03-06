//
//  SVW_ViewControllerProtocol.h

#import <Foundation/Foundation.h>


/**
 为 ViewController 绑定方法协议
 */
@protocol SVW_ViewControllerProtocol <NSObject>

#pragma mark - 方法绑定
@required

// 这个方法是有一些关于viewcontroller本身属性的设置
// 请不要在这个方法中有任何view， model， naviagtor的代码涉及
/// 初始化数据
- (void)svw_initialDefaultsForController;

// 这里可以使用rac绑定数据，也可以是基础数据类型的赋值
/// 绑定 vm
- (void)svw_bindViewModelForController;

// 这里的创建视图并不是说我在这里初始化试图或者在这里创建视图元素，
// 而是给视图一些基础数据赋值
// 基本的创建视图都要新建一个view，然后在loadview中替换基础的view
// 非常不建议直接在controller中创建元素
/// 创建视图
- (void)svw_createViewForConctroller;

// 这里的导航栏是指默认的导航栏
// 如果有自定义新建的导航栏等等，
// 可以在项目统一的基础上，给这个协议添加变量
/// 配置导航栏
- (void)svw_configNavigationForController;

@end
