//
//  SVW_BaseRequest+Rac.m

#import "SVW_BaseRequest+Rac.h"
#import "NSObject+RACDescription.h"


@implementation SVW_BaseRequest (Rac)

- (RACSignal *)rac_requestSignal {
    [self stop];
    @weakify(self);
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
        // 请求起飞
        [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *_Nonnull request) {

            [subscriber sendNext:[request responseJSONObject]];
            [subscriber sendCompleted];

        } failure:^(__kindof YTKBaseRequest *_Nonnull request) {

            [subscriber sendError:[request error]];
        }];

        return [RACDisposable disposableWithBlock:^{
            @strongify(self);
            if (!self.isCancelled) {
                [self stop];
            }
        }];
    }] takeUntil:[self rac_willDeallocSignal]];

    //设置名称 便于调试
    if (DEBUG) {
        [signal setNameWithFormat:@"%@ -rac_svw_Request", RACDescription(self)];
    }

    return signal;
}

@end
