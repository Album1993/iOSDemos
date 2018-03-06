//
//  SVW_LoginRequest.h

#import "SVW_BaseRequest.h"

/* 大多时候Api只需要一种解析格式，所以此处跟着request走，其他情况下常量字符串建议跟着reformer走， */
// 登录token key
FOUNDATION_EXTERN NSString *SVW_LoginAccessTokenKey;
// 也可以写成 局部常量形式
static const NSString *SVW_LoginAccessTokenKey2 = @"accessToken";


@interface SVW_LoginRequest : SVW_BaseRequest

- (id)initWithUsr:(NSString *)usr pwd:(NSString *)pwd;

@end
