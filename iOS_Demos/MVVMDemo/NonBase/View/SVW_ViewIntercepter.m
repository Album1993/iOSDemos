//
//  SVW_ViewIntercepter.m

#import "SVW_ViewIntercepter.h"
#import "SVW_ViewProtocol.h"
#import <Aspects/Aspects.h>


@implementation SVW_ViewIntercepter

+ (void)load {
    [SVW_ViewIntercepter sharedInstance];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t      onceToken;
    static SVW_ViewIntercepter *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SVW_ViewIntercepter alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        /* 方法拦截 */

        // 代码方式唤起view
        [UIView aspect_hookSelector:@selector(initWithFrame:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, CGRect frame) {

            [self _init:aspectInfo.instance withFrame:frame];
        } error:nil];

        // xib方式唤起view
        [UIView aspect_hookSelector:@selector(initWithCoder:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, NSCoder *aDecoder) {

            // 在此时 IBOut 中 view 都为空， 需要Hook awakeFromNib 方法
            [self _init:aspectInfo.instance withCoder:aDecoder];
        } error:nil];

        // xib方式唤起view
        [UIView aspect_hookSelector:@selector(awakeFromNib) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {

            // 这时候可以初始化视图
            [self _awakFromNib:aspectInfo.instance];
        } error:nil];
    }
    return self;
}

#pragma mark - Hook Methods
- (void)_init:(UIView<SVW_ViewProtocol> *)view withFrame:(CGRect)frame {
    if ([view respondsToSelector:@selector(svw_initializeForView)]) {
        [view svw_initializeForView];
    }

    if ([view respondsToSelector:@selector(svw_createViewForView)]) {
        [view svw_createViewForView];
    }
}

- (void)_init:(UIView<SVW_ViewProtocol> *)view withCoder:(NSCoder *)aDecoder {
    if ([view respondsToSelector:@selector(svw_initializeForView)]) {
        [view svw_initializeForView];
    }
}

- (void)_awakFromNib:(UIView<SVW_ViewProtocol> *)view {
    if ([view respondsToSelector:@selector(svw_createViewForView)]) {
        [view svw_createViewForView];
    }
}


@end
