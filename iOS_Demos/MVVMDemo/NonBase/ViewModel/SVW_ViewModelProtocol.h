//
//  SVW_ViewModelProtocol.h

#import <Foundation/Foundation.h>

@protocol SVW_ViewModelProtocol <NSObject>

@required

/**
 viewModel 初始化属性
 */
- (void)svw_initializeForViewModel;

@end
