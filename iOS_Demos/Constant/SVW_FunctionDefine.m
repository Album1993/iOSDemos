//
//  SVWFunctionDefine.m


#import "SVW_FunctionDefine.h"

#pragma mark - Decode
SVW_EXTERN NSString *DecodeObjectFromDic(NSDictionary *dic, NSString *key) {
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    id        temp  = [dic objectForKey:key];
    NSString *value = @"";
    if (NotNilAndNull(temp)) {
        if ([temp isKindOfClass:[NSString class]]) {
            value = temp;
        } else if ([temp isKindOfClass:[NSNumber class]]) {
            value = [temp stringValue];
        }
        return value;
    }
    return nil;
}

SVW_EXTERN NSString *DecodeDefaultStrFromDic(NSDictionary *dic, NSString *key, NSString *defaultStr) {
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    id        temp  = [dic objectForKey:key];
    NSString *value = defaultStr;
    if (NotNilAndNull(temp)) {
        if ([temp isKindOfClass:[NSString class]]) {
            value = temp;
        } else if ([temp isKindOfClass:[NSNumber class]]) {
            value = [temp stringValue];
        }

        return value;
    }
    return value;
}

SVW_EXTERN id DecodeSafeObjectAtIndex(NSArray *arr, NSInteger index) {
    if (IsArrEmpty(arr)) {
        return nil;
    }

    if ([arr count] - 1 < index) {
        SVW_Assert([arr count] - 1 < index);
        return nil;
    }

    return [arr objectAtIndex:index];
}


SVW_EXTERN NSString *DecodeStringFromDic(NSDictionary *dic, NSString *key) {
    if (IsNilOrNull(dic)) {
        return nil;
    }
    id temp = [dic objectForKey:key];
    if ([temp isKindOfClass:[NSString class]]) {
        if ([temp isEqualToString:@"(null)"]) {
            return @"";
        }
        return temp;
    } else if ([temp isKindOfClass:[NSNumber class]]) {
        return [temp stringValue];
    }
    return nil;
}

SVW_EXTERN NSNumber *DecodeNumberFromDic(NSDictionary *dic, NSString *key) {
    if (IsNilOrNull(dic)) {
        return nil;
    }
    id temp = [dic objectForKey:key];
    if ([temp isKindOfClass:[NSString class]]) {
        return [NSNumber numberWithDouble:[temp doubleValue]];
    } else if ([temp isKindOfClass:[NSNumber class]]) {
        return temp;
    }
    return nil;
}

SVW_EXTERN NSDictionary *DecodeDicFromDic(NSDictionary *dic, NSString *key) {
    if (IsNilOrNull(dic)) {
        return nil;
    }
    id temp = [dic objectForKey:key];
    if ([temp isKindOfClass:[NSDictionary class]]) {
        return temp;
    }
    return nil;
}

SVW_EXTERN NSArray *DecodeArrayFromDic(NSDictionary *dic, NSString *key) {
    id temp = [dic objectForKey:key];
    if ([temp isKindOfClass:[NSArray class]]) {
        return temp;
    }
    return nil;
}

SVW_EXTERN NSArray *DecodeArrayFromDicUsingParseBlock(NSDictionary *dic, NSString *key, id (^parseBlock)(NSDictionary *innerDic)) {
    NSArray *tempList = DecodeArrayFromDic(dic, key);
    if ([tempList count]) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:[tempList count]];
        for (NSDictionary *item in tempList) {
            id dto = parseBlock(item);
            if (dto) {
                [array addObject:dto];
            }
        }
        return array;
    }
    return nil;
}


#pragma mark - Encode

SVW_EXTERN void EncodeUnEmptyStrObjctToDic(NSMutableDictionary *dic, NSString *object, NSString *key) {
    if (IsNilOrNull(dic)) {
        return;
    }

    if (IsStrEmpty(object)) {
        return;
    }

    if (IsStrEmpty(key)) {
        return;
    }

    [dic setObject:object forKey:key];
}

SVW_EXTERN void EncodeUnEmptyObjctToArray(NSMutableArray *arr, id object) {
    if (IsNilOrNull(arr)) {
        return;
    }

    if (IsNilOrNull(object)) {
        return;
    }

    [arr addObject:object];
}

SVW_EXTERN void EncodeDefaultStrObjctToDic(NSMutableDictionary *dic, NSString *object, NSString *key, NSString *defaultStr) {
    if (IsNilOrNull(dic)) {
        return;
    }

    if (IsStrEmpty(object)) {
        object = defaultStr;
    }

    if (IsStrEmpty(key)) {
        return;
    }

    [dic setObject:object forKey:key];
}

void EncodeUnEmptyObjctToDic(NSMutableDictionary *dic, NSObject *object, NSString *key) {
    if (IsNilOrNull(dic)) {
        return;
    }
    if (IsNilOrNull(object)) {
        return;
    }
    if (IsStrEmpty(key)) {
        return;
    }

    [dic setObject:object forKey:key];
}
