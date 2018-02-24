//
//  SVW_BaseRequest+Rac.h

#import "SVW_BaseRequest.h"


@interface SVW_BaseRequest (Rac)


- (RACSignal *)rac_requestSignal;

@end
