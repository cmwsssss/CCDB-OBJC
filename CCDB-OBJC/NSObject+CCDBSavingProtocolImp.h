//
//  NSObject+CCDBSavingProtocolImp.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (CCDBSavingProtocolImp)

/**
 @brief For properties of type CCModelPropertyTypeCustom, if the CCDBSaving protocol method is not implemented, this method is used for automatic data parsing
 */
- (void)defaultUpdateWithJSONDictionaryIMP:(NSDictionary *)dic;
/**
 @brief For properties of type CCModelPropertyTypeCustom, if the CCDBSaving protocol method is not implemented, this method is used for automatic data parsing
 */
- (NSMutableDictionary *)defaultJSONDictionaryIMP;

@end

NS_ASSUME_NONNULL_END
