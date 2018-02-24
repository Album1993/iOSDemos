//
//  SVW_ViewModelIntercepter.m

#import "SVW_ViewModelIntercepter.h"
#import "NSObject+NonBase.h"
#import "SVW_ViewModelProtocol.h"
#import "Aspects.h"


@implementation SVW_ViewModelIntercepter

+ (void)load {
    [super load];
    [SVW_ViewModelIntercepter sharedInstance];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t           onceToken;
    static SVW_ViewModelIntercepter *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SVW_ViewModelIntercepter alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        /* 方法拦截 */

        [NSObject aspect_hookSelector:@selector(initWithParams:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, NSDictionary *param) {

            [self _initWithInstance:aspectInfo.instance params:param];
        } error:nil];
    }
    return self;
}

#pragma mark - Hook Methods
- (void)_initWithInstance:(NSObject<SVW_ViewModelProtocol> *)viewModel {
    if ([viewModel respondsToSelector:@selector(svw_initializeForViewModelsvw_initializeForViewModel)]) {
        [viewModel svw_initializeForViewModel];
    }
}

- (void)_initWithInstance:(NSObject<SVW_ViewModelProtocol> *)viewModel params:(NSDictionary *)param {
    if ([viewModel respondsToSelector:@selector(svw_initializeForViewModelsvw_initializeForViewModel)]) {
        [viewModel svw_initializeForViewModel];
    }
}

@end
