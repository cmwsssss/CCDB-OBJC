//
//  NSObject+CCDBSavingProtocolImp.m
//  CCModelDemo
//
//  Created by cmw on 2021/7/5.
//

#import "NSObject+CCDBSavingProtocolImp.h"
#import <objc/message.h>
#import "CCModelMapperManager.h"
@implementation NSObject (CCDBSavingProtocolImp)

- (NSMutableDictionary *)defaultJSONDictionaryIMP {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSString *className = NSStringFromClass([self class]);
    CCJSONModelMapper *JSONMapper = [[CCModelMapperManager sharedInstance].dicJSONMapper objectForKey:className];
    NSMutableDictionary *dicPropertyToJSON = JSONMapper.dicPropertyToJSON;
    [dicPropertyToJSON enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        id propertyValue = [self valueForKey:key];
        if (propertyValue) {
            [dic setObject:propertyValue forKey:obj];
        }
    }];
    return dic;
}

- (void)defaultUpdateWithJSONDictionaryIMP:(NSDictionary *)dic {
    NSString *className = NSStringFromClass([self class]);
    CCJSONModelMapper *JSONMapper = [[CCModelMapperManager sharedInstance].dicJSONMapper objectForKey:className];
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self setValue:obj forKey:[JSONMapper.dicPropertyToJSON objectForKey:key]];
    }];
}

@end
