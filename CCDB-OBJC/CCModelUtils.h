//
//  CCModelUtils.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/2.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>
#import "CCDBEnum.h"
NS_ASSUME_NONNULL_BEGIN

@interface CCModelUtils : NSObject

/**
 @brief get class from a property
 @param property a objc_property_t instance
 @return target class;
 */
+ (Class)loadClassFromProperty:(objc_property_t)property;
/**
 @brief parse data type from objc type encode
 @param type objc type encode
 @return CCModelPropertyDataType, it can be CCModelPropertyDataTypeBool, CCModelPropertyDataTypeString, CCModelPropertyDataTypeInt, CCModelPropertyDataTypeFloat, CCModelPropertyDataTypeLong, CCModelPropertyDataTypeRaw.
 */
+ (CCModelPropertyDataType)getDataTypeWithTypeString:(NSString *)type;
/**
 @brief get property type from CCDBPropertyTag
 @param string String of CCModelPropertyType
 @return CCModelPropertyType, it can be CCModelPropertyTypeDefault, CCModelPropertyTypeModel, CCModelPropertyTypeJSON, CCModelPropertyTypeCustom, CCModelPropertyTypeSavingProtocol,
 */
+ (CCModelPropertyType)getPropertyTypeWithString:(NSString *)string;

/**
 @brief get value from formatedDic, only used to get primary property
 @param JSONDic JSON data dictionary
 @param keyPath keyPath from CCJSONPathMapper
 @return Value of primary property
 */
+ (id)getValueFromJSONDic:(NSDictionary *)JSONDic keyPath:(NSString *)keyPath;

/**
 @brief Dimensionalizing JSON data
 @code
 
 NSDictionary *JSONDic = @{@"title":@"title",
                           @"user":@{@"name" : @"123",
                                     @"about" : @{@"headline" : @"Hello"}
                           }
 };
 
 @endcode
 
 Change to
 
 @code
 NSDictionary *formatedDic = @{@"title" : @"title",
                               @"user__name":@"123,
                               @"user__about__headline":@"Hello"
 };
 @endcode
 */
+ (void)setupFormatDic:(NSMutableDictionary *)formatedDic JSONDic:(NSDictionary *)JSONDic parentKey:(NSString *)parentKey;
@end

NS_ASSUME_NONNULL_END
