//
//  NSObject+Property.m
//  iOS_Demos
//
//  Created by 张一鸣 on 13/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "NSObject+Property.h"


@implementation NSObject (Property)

- (NSString *)createPropertyCodeWithDict:(NSDictionary *)dict {
    __block NSString *str = @"";

    [dict enumerateKeysAndObjectsUsingBlock:^(id _Nonnull propertyName, id _Nonnull obj, BOOL *_Nonnull stop) {

        NSString *code;

        if ([obj isKindOfClass:NSClassFromString(@"__NSCFString")]) {
            code = [NSString stringWithFormat:@"@property (nonatomic, strong) NSString * %@;", propertyName];
        } else if ([obj isKindOfClass:NSClassFromString(@"__NSCFNumber")]) {
            code = [NSString stringWithFormat:@"@property (nonatomic, assign) int %@;", propertyName];
        } else if ([obj isKindOfClass:NSClassFromString(@"__NSCFArray")]) {
            code = [NSString stringWithFormat:@"@property (nonatomic, strong) NSArray * %@;", propertyName];
        } else if ([obj isKindOfClass:NSClassFromString(@"__NSCFDictionary")]) {
            code = [NSString stringWithFormat:@"@property (nonatomic, strong) NSDictionary * %@;", propertyName];
        }
        str = [NSString stringWithFormat:@"\n %@ \n", code];

    }];
    return str;
}

@end
