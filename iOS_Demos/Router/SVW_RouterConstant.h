//
//  SVW_RouterConstant.h

#import <Foundation/Foundation.h>

// 路由默认控制器参数名
FOUNDATION_EXTERN NSString *const SVW_ControllerNameRouteParam;

#pragma mark - 路由模式 Schema
/**
 模式 Native：AppSchema://url/:param
 */

// 默认路由
FOUNDATION_EXTERN NSString *const SVW_DefaultRouteSchema;
// 网络跳转路由模式
FOUNDATION_EXTERN NSString *const SVW_HTTPRouteSchema;
FOUNDATION_EXTERN NSString *const SVW_HTTPsRouteSchema;
// WEB交互路由跳转模式
FOUNDATION_EXTERN NSString *const SVW_WebHandlerRouteSchema;
// 回调通信
FOUNDATION_EXTERN NSString *const SVW_ComponentsCallBackHandlerRouteSchema;
// 未知路由
FOUNDATION_EXTERN NSString *const SVW_UnknownHandlerRouteSchema;


#pragma mark - 路由表

// 导航栏 Push
FOUNDATION_EXTERN NSString *const SVW_NavPushRoute;

// 导航栏 Present
FOUNDATION_EXTERN NSString *const SVW_NavPresentRoute;

// StoryBoard Push
FOUNDATION_EXTERN NSString *const SVW_NavStoryBoardPushRoute;

// 组件通信回调
FOUNDATION_EXTERN NSString *const SVW_ComponentsCallBackRoute;
