//
//  NSObject+CC_JSON.m
//  CCModelDemo
//
//  Created by cmw on 2021/7/5.
//

#import "NSObject+CC_JSON.h"

@implementation NSObject (CC_JSON)

- (void)setNonNullValue:(NSObject *)value forKeyPath:(NSString *)keyPath {
    if (!value) {
        return;
    }
    [self setValue:value forKeyPath:keyPath];
}

- (id)JSONValue {
    if ([self isKindOfClass:[NSString class]]) {
        NSData *jsonData = [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        if (jsonData.length == 0) {
            return nil;
        }
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        if(err) {
            NSLog(@"%@", self);
            NSLog(@"json解析失败：%@",err);
            return nil;
        }
        return dic;
    } else {
        return self;
    }
}

- (NSString *)JSONString {
    if ([self isKindOfClass:[NSDictionary class]] || [self isKindOfClass:[NSArray class]]) {
        NSData *data=[NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        return jsonStr;
    } else {
        return nil;
    }
}


@end
