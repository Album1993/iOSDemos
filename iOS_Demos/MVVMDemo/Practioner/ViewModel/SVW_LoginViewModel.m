//
//  SVW_LoginViewModel.m

#import "SVW_LoginViewModel.h"
#import "SVW_LoginRequest.h"


@interface SVW_LoginViewModel () <SVW_BaseRequestFeformDelegate, YTKRequestDelegate>

@end


@implementation SVW_LoginViewModel

- (instancetype)initWithParams:(NSDictionary *)params {
    if (self = [super initWithParams:params]) {
    }
    return self;
}

/**
 viewModel 初始化属性
 */
- (void)svw_initializeForViewModel {
    _cellTitleArray = @[
        @"账户",
        @"密码",
    ];


    // 是否可以登录
    RAC(self, isLoginEnable) = [[RACSignal combineLatest:@[
        RACObserve(self, userAccount),
        RACObserve(self, password)
    ]]
        map:^id _Nullable(RACTuple *_Nullable value) {
            RACTupleUnpack(NSString * account, NSString * pwd) = value;
            return @(account && pwd && account.length && pwd.length);
        }];
}

#pragma mark - Getter
- (RACCommand *)loginCommand {
    if (!_loginCommand) {
        @weakify(self);
        _loginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *_Nonnull(id _Nullable input) {
            @strongify(self);

            SVW_LoginRequest *loginRequest = [[SVW_LoginRequest alloc] initWithUsr:self.userAccount pwd:self.password];
            // 数据返回值reformat代理
            // loginRequest.reformDelegate = self;
            // 数据请求响应代理 通过代理回调
            // loginRequest.delegate = self;
            return [[[loginRequest rac_requestSignal] doNext:^(id _Nullable x) {


                // 解析数据
                [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"isLogin"];

            }] materialize];

        }];
    }
    return _loginCommand;
}

#pragma mark - SVW_BaseRequestFeformDelegate
- (id)request:(SVW_BaseRequest *)request reformJSONResponse:(id)jsonResponse {
    if ([request isKindOfClass:SVW_LoginRequest.class]) {
        // 在这里对json数据进行重新格式化
        return @{
            SVW_LoginAccessTokenKey : jsonResponse[@"token"],
            // SVW_LoginAccessTokenKey : DecodeStringFromDic(jsonResponse, @"token"),
        };
    }
    return jsonResponse;
}

#pragma mark - YTKRequestDelegate
- (void)requestFinished:(__kindof YTKBaseRequest *)request {
    // 解析数据
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"isLogin"];
}

- (void)requestFailed:(__kindof YTKBaseRequest *)request {
    // do something
}
@end
