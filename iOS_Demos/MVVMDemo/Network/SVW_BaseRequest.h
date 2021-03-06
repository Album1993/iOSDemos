//
//  SVW_BaseRequest.h

#import <YTKNetwork/YTKNetwork.h>

// 获取服务器响应状态码 key
FOUNDATION_EXTERN NSString *const SVW_BaseRequest_StatusCodeKey;
// 服务器响应数据成功状态码 value
FOUNDATION_EXTERN NSString *const SVW_BaseRequest_DataValueKey;
// 获取服务器响应状态信息 key
FOUNDATION_EXTERN NSString *const SVW_BaseRequest_StatusMsgKey;
// 获取服务器响应数据 key
FOUNDATION_EXTERN NSString *const SVW_BaseRequest_DataKey;


@class SVW_BaseRequest;
@protocol SVW_BaseRequestFeformDelegate <NSObject>

/**
 自定义解析器解析响应参数

 @param request 当前请求
 @param jsonResponse 响应数据
 @return 自定reformat数据
 */
- (id)request:(SVW_BaseRequest *)request reformJSONResponse:(id)jsonResponse;

@end


@interface SVW_BaseRequest : YTKRequest

/**
 数据重塑代理
 */
@property (nonatomic, weak) id<SVW_BaseRequestFeformDelegate> reformDelegate;

#pragma mark - Override

/**
 自定义解析器解析响应参数
 
 @param jsonResponse json响应
 @return 解析后的json
 */
- (id)reformJSONResponse:(id)jsonResponse;

#pragma mark - Subclass Ovrride

/**
 添加额外的参数

 @return 额外参数
 */
- (id)extraRequestArgument;
@end
