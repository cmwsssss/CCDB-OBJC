//
//  CCModelUtils.m
//  CCModelDemo
//
//  Created by cmw on 2021/7/2.
//

#import "CCModelUtils.h"
#import <objc/message.h>
#import "CCDBMarco.h"
@implementation CCModelUtils

+ (Class)loadClassFromProperty:(objc_property_t)property {
    NSString *attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
    NSInteger startIndex = 0;
    NSInteger endIndex = 0;
    for (int i = 0; i < attributes.length; i++) {
        if ([attributes characterAtIndex:i] == '"') {
            if (startIndex == 0) {
                startIndex = i + 1;
            } else {
                endIndex = i;
            }
        }
    }
    if (endIndex < attributes.length && endIndex > startIndex) {
        return objc_getClass([attributes substringWithRange:NSMakeRange(startIndex, endIndex - startIndex)].UTF8String);
    }
    
    return nil;
}

+ (CCModelPropertyType)getPropertyTypeWithString:(NSString *)string {
    if ([string isEqualToString:CC_TYPE_STR(CCModelPropertyTypeDefault)]) {
        return CCModelPropertyTypeDefault;
    } else if ([string isEqualToString:CC_TYPE_STR(CCModelPropertyTypeJSON)]) {
        return CCModelPropertyTypeJSON;
    } else if ([string isEqualToString:CC_TYPE_STR(CCModelPropertyTypeModel)]) {
        return CCModelPropertyTypeModel;
    } else if ([string isEqualToString:CC_TYPE_STR(CCModelPropertyTypeCustom)]) {
        return CCModelPropertyTypeCustom;
    } else if ([string isEqualToString:CC_TYPE_STR(CCModelPropertyTypeSavingProtocol)]) {
        return CCModelPropertyTypeSavingProtocol;
    }
    return CCModelPropertyTypeDefault;
}

+ (CCModelPropertyDataType)getDataTypeWithTypeString:(NSString *)type {
    if(!strcmp(type.UTF8String, "Ti") || !strcmp(type.UTF8String, "Tc")) {
        return CCModelPropertyDataTypeInt;
    }
    else if(!strcmp(type.UTF8String, "Tf") || !strcmp(type.UTF8String, "Td")) {
        return CCModelPropertyDataTypeFloat;
    }
    else if(!strcmp(type.UTF8String, "TB")) {
        return CCModelPropertyDataTypeBool;
    }
    else if(!strcmp(type.UTF8String, "Tq") || !strcmp(type.UTF8String, "Tl")) {
        return CCModelPropertyDataTypeLong;
    }
    else {
        return CCModelPropertyDataTypeString;
    }
}

+ (id)getValueFromJSONDic:(NSDictionary *)JSONDic keyPath:(NSString *)keyPath {
    if ([JSONDic objectForKey:keyPath]) {
        return [JSONDic objectForKey:keyPath];
    }
    NSMutableDictionary *formatedDic = [[NSMutableDictionary alloc] init];
    [self setupFormatDic:formatedDic JSONDic:JSONDic parentKey:nil];
    return [formatedDic objectForKey:keyPath];
}

+ (void)setupFormatDic:(NSMutableDictionary *)formatedDic JSONDic:(NSDictionary *)JSONDic parentKey:(NSString *)parentKey {
    [JSONDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [formatedDic setObject:obj forKey:key];
            if (parentKey && parentKey.length > 0) {
                [self setupFormatDic:formatedDic JSONDic:obj parentKey:[NSString stringWithFormat:@"%@__%@", parentKey,key]];
            } else {
                [self setupFormatDic:formatedDic JSONDic:obj parentKey:key];
            }
        }
        else {
            if (parentKey && parentKey.length > 0) {
                NSString *formatedKey = [NSString stringWithFormat:@"%@__%@", parentKey, key];
                [formatedDic setObject:obj forKey:formatedKey];
            } else {
                [formatedDic setObject:obj forKey:key];
            }
        }
    }];
}

@end
