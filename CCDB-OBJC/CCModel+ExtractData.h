//
//  CCModel+ExtractData.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/5.
//

#import "CCModel.h"
#import "CCDBEnum.h"
/**
 @brief A Category works for Lazy load to property which has a special type
 */
@interface CCModel (ExtractData)

/**
 @Discussion
 For properties of type other than CCModelPropertyTypeDefault, the data will not be updated to the corresponding property immediately after the data query result is obtained, but will only be updated when the property is invoked, and the data of these properties to be updated will be saved here
 */
@property (nonatomic, strong)NSMutableDictionary *cc_dbRawData;
/**
 @brief Extract data from cc_dbRawData to the specified property
 @note Do not invoke this method directly
 @param propertyName The specified property name
 @param type The specified Property type, it can be CCModelPropertyTypeModel, CCModelPropertyTypeJSON, CCModelPropertyTypeCustom and CCModelPropertyTypeSavingProtocol.
 */
- (void)extractDataWithProperty:(NSString *)propertyName type:(CCModelPropertyType)type;


@end

