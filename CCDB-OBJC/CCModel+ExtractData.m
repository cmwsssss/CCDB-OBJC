//
//  CCModel+ExtractData.m
//  CCModelDemo
//
//  Created by cmw on 2021/7/5.
//

#import "CCModel+ExtractData.h"
#import "CCModelUtils.h"
#import "NSObject+CC_JSON.h"
#import "NSObject+CCDBSavingProtocolImp.h"
#import "CCDBSavingProtocol.h"
#import "CCModel+CustomProperty.h"
@implementation CCModel (ExtractData)

- (NSMutableDictionary *)cc_dbRawData {
    NSMutableDictionary *dic = objc_getAssociatedObject(self, "cc_dbRawData");
    if (!dic) {
        dic = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, "cc_dbRawData", dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dic;
}

- (void)setCc_dbRawData:(NSMutableDictionary *)cc_dbRawData {
    
}

- (void)extractDataWithProperty:(NSString *)propertyName type:(CCModelPropertyType)type{
    NSMutableDictionary *customJSONDictionary = [[NSMutableDictionary alloc] init];
    switch (type) {
        case CCModelPropertyTypeJSON:
            [self setValue:[[[self cc_dbRawData] objectForKey:propertyName] JSONValue] forKey:propertyName];
            break;
        case CCModelPropertyTypeCustom:
            [customJSONDictionary setNonNullValue:[[[self cc_dbRawData] objectForKey:propertyName] JSONValue] forKeyPath:propertyName];
            if ([self respondsToSelector:@selector(updateDataWithCustomJSONDictionary:)]) {
                [self updateDataWithCustomJSONDictionary:customJSONDictionary];
            }
            break;
        case CCModelPropertyTypeModel: {
            Class modelClass = [CCModelUtils loadClassFromProperty:class_getProperty([self class], propertyName.UTF8String)];
            id data = [[self cc_dbRawData] objectForKey:propertyName];
            if ([data isKindOfClass:[NSDictionary class]]) {
                id object = [[modelClass alloc] initWithJSONDictionary:data];
                [self setValue:object forKey:propertyName];
            } else {
                id object = [[modelClass alloc] initWithPrimaryProperty:data];
                [self setValue:object forKey:propertyName];
            }
            
        }
            break;
        case CCModelPropertyTypeSavingProtocol: {
            Class savingProtocolClass = [CCModelUtils loadClassFromProperty:class_getProperty([self class], propertyName.UTF8String)];
            NSObject <CCDBSaving> *protocolObject = [[savingProtocolClass alloc] init];
            if ([protocolObject respondsToSelector:@selector(cc_updateWithJSONDictionary:)]) {
                [protocolObject cc_updateWithJSONDictionary:[[[self cc_dbRawData] objectForKey:propertyName] JSONValue]];
            } else {
                [protocolObject defaultUpdateWithJSONDictionaryIMP:[[[self cc_dbRawData] objectForKey:propertyName] JSONValue]];
            }
            CFRetain((__bridge CFTypeRef)(protocolObject));
            [self setValue:protocolObject forKey:propertyName];
        }
            break;
        default:
            break;
    }
    
}

@end
