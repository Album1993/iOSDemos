//
//  SVW_BaseRequestIntercepter.h

#import <Foundation/Foundation.h>
#import "SVW_BaseRequest.h"


@interface SVW_BaseRequestIntercepter : NSObject

- (void)hookRequestArgumentWithInstance:(SVW_BaseRequest *)request SVW_Deprecated("Do not use any more");

@end
