//
//  SVW_ViewProtocol.h

#import <Foundation/Foundation.h>

@protocol SVW_ViewProtocol <NSObject>

/**
 为视图绑定 viewModel
 
 @param viewModel 要绑定的ViewModel
 @param params 额外参数
 */
- (void)bindViewModel:(id<SVW_ViewProtocol>)viewModel withParams:(NSDictionary *)params;

@required

/**
 初始化额外数据
 */
- (void)svw_initializeForView;

/**
 初始化视图
 */
- (void)svw_createViewForView;

@end
