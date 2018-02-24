//
//  SVW_RouterConstant.m

#import "SVW_RouterConstant.h"

NSString *const SVW_ControllerNameRouteParam = @"viewController";

#pragma mark - 路由模式

NSString *const SVW_DefaultRouteSchema = @"FXXKBaseMVVM";
NSString *const SVW_HTTPRouteSchema    = @"http";
NSString *const SVW_HTTPsRouteSchema   = @"https";
// ----
NSString *const SVW_ComponentsCallBackHandlerRouteSchema = @"AppCallBack";
NSString *const SVW_WebHandlerRouteSchema                = @"yinzhi";
NSString *const SVW_UnknownHandlerRouteSchema            = @"UnKnown";

#pragma mark - 路由表

NSString *const SVW_NavPushRoute            = @"/com_madao_navPush/:viewController";
NSString *const SVW_NavPresentRoute         = @"/com_madao_navPresent/:viewController";
NSString *const SVW_NavStoryBoardPushRoute  = @"/com_madao_navStoryboardPush/:viewController";
NSString *const SVW_ComponentsCallBackRoute = @"/com_madao_callBack/*";
