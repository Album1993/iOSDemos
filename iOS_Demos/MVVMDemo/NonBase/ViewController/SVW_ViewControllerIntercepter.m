//
//  SVW_ViewControllerIntercepter.m


#import "SVW_ViewControllerIntercepter.h"
#import "Aspects.h"


@implementation SVW_ViewControllerIntercepter

+ (void)load {
    [super load];

    [SVW_ViewControllerIntercepter sharedInstance];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t                onceToken;
    static SVW_ViewControllerIntercepter *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SVW_ViewControllerIntercepter alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        /* 方法拦截 */

        // 拦截 viewDidLoad 方法
        [UIViewController aspect_hookSelector:@selector(viewDidLoad) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {


            [self _viewDidLoad:aspectInfo.instance];
        } error:nil];

        // 拦截 viewWillAppear:
        [UIViewController aspect_hookSelector:@selector(viewWillAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated) {

            [self _viewWillAppear:animated controller:aspectInfo.instance];
        } error:NULL];
    }
    return self;
}

#pragma mark - Hook Methods
- (void)_viewDidLoad:(UIViewController<SVW_ViewControllerProtocol> *)controller {
    if ([controller conformsToProtocol:@protocol(SVW_ViewControllerProtocol)]) {
        // 只有遵守 SVW_ViewControllerProtocol 的 viewController 才进行 配置
        controller.edgesForExtendedLayout               = UIRectEdgeAll;
        controller.extendedLayoutIncludesOpaqueBars     = NO;
        //        controller.automaticallyAdjustsScrollViewInsets = NO;
        
        
        // 背景色设置为白色
        controller.view.backgroundColor = [UIColor whiteColor];
        
        // 执行协议方法
        [controller svw_initialDefaultsForController];
        [controller svw_bindViewModelForController];
        [controller svw_configNavigationForController];
        [controller svw_createViewForConctroller];
    }
    
    
}

- (void)_viewWillAppear:(BOOL)animated controller:(UIViewController<SVW_ViewControllerProtocol> *)controller {
}


@end
