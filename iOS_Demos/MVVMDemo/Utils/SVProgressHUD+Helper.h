//
//  SVProgressHUD+Helper.h

#import <SVProgressHUD/SVProgressHUD.h>


@interface SVProgressHUD (Helper)

/// 显示不带文字的overflow
+ (void)svw_displayOverFlowActivityView;
+ (void)svw_displayOverFlowActivityView:(NSTimeInterval)maxShowTime;

/// 显示成功状态
+ (void)svw_displaySuccessWithStatus:(NSString *)status;

/// 显示失败状态
+ (void)svw_displayErrorWithStatus:(NSString *)status;

/// 显示提示信息
+ (void)svw_dispalyInfoWithStatus:(NSString *)status;

/// 显示提示信息
+ (void)svw_dispalyMsgWithStatus:(NSString *)status;

/// 显示加载圈 加文本
+ (void)svw_dispalyLoadingMsgWithStatus:(NSString *)status;

/// 显示进度，带文本
+ (void)svw_dispalyProgress:(CGFloat)progress status:(NSString *)status;

/// 显示进度，不带文本
+ (void)svw_dispalyProgress:(CGFloat)progress;


@end
