//
//  UIControl+Permission.m
//  iOS_Demos
//
//  Created by 张一鸣 on 06/03/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "UIControl+Permission.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>


@implementation UIControl (Permission)


- (void)setNeedsCameraPermission {
    NSString *className = [NSString stringWithFormat:@"CameraPermission_%@", self.class];
    Class kclass        = objc_getClass([className UTF8String]);
    if (!kclass) {
        kclass = objc_allocateClassPair([self class], [className UTF8String], 0);
    }
    SEL    setterSelector = NSSelectorFromString(@"sendAction:to:forEvent:");
    Method setterMethod   = class_getInstanceMethod([self class], setterSelector);
    object_setClass(self, kclass);
    const char *types = method_getTypeEncoding(setterMethod);
    class_addMethod(kclass, setterSelector, (IMP)camerapermission_SendAction, types);
    objc_registerClassPair(kclass);
}

static void camerapermission_SendAction(id self, SEL _cmd, SEL action, id target, UIEvent *event) {
    struct objc_super superclass = {
        .receiver    = self,
        .super_class = class_getSuperclass(object_getClass(self))};
    void (*objc_msgSendSuperCasted)(const void *, SEL, SEL, id, UIEvent *) = (void *)objc_msgSendSuper;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    objc_msgSendSuperCasted(&superclass, _cmd, action, target, event);
                });
            }
        }];
    } else {
        objc_msgSendSuperCasted(&superclass, _cmd, action, target, event);
    }
}

@end
