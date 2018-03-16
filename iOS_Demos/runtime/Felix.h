//
//  Felix.h
//  iOS_Demos
//
//  Created by 张一鸣 on 09/03/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Aspects/Aspects.h>
#import <objc/runtime.h>
#import <JavaScriptCore/JavaScriptCore.h>


@interface Felix : NSObject
+ (void)fixIt;
+ (void)evalString:(NSString *)javascriptString;
@end
