//
//  NSObject+NonBase.h

#import <Foundation/Foundation.h>


@interface NSObject (NonBase)

/**
 去表征化参数列表
 */
@property (nonatomic, strong, readonly) NSDictionary *params;

/**
 初始化方法
 */
- (instancetype)initWithParams:(NSDictionary *)params;

@end
