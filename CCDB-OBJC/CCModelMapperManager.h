//
//  CCModelMapperManager.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/2.
//

#import <Foundation/Foundation.h>

/**
 @brief Used to mark the JSON parsing path of the property, Do not use it directly
 @code
 
 //You can mark the JSON parsing path of a property like this
 @property (nonatomic, strong) CCJSONPathTag *zcc___yourPropertyName___jsonLevel1__jsonLevel2__target;

 
 @endcode
 */
@interface CCJSONPathTag : NSObject

@end

/**
 @brief Used to mark the type of the property
 
 @code
 
 //You can mark mark the type of the property like this
 @property (nonatomic, strong) CCDBPropertyTag *zcc___yourPropertyName___CCModelPropertyTypeDefault;
 
 @endcode
 
 */

@interface CCDBPropertyTag : NSObject

@end

/**
 @brief CCModel performs JSON parsing based on the information provided by Mapper
 */

@interface CCJSONModelMapper : NSObject

/**
 @brief Dictionary containing the mapping relationship between JSON Key and property names;
 @code
 
 dicJSONToProperty = @{@"userIdJSONKey" : @"userIdProperty"};
 
 @endcode
 */
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString *> *dicJSONToProperty;
/**
 @brief Dictionary containing the JSON key corresponding to the primary property
 @discussion
 Works for cache, when parsing JSON, the value of the main property is obtained, and if the corresponding object can be found in the cache through the main property, the object is directly load from the cache.
 */
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSNumber *> *dicJSONPrimaryKey;
/**
 @brief Dictionary containing the mapping relationship between property names and JSON Key;
 @code
 
 dicJSONToProperty = @{@"userIdProperty" : @"userIdJSONKey"};
 
 @endcode
 */
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString *> *dicPropertyToJSON;

@end

/**
 @brief CCModel maps database fields and properties based on Mapper information
 */

@interface CCPropertyMapper : NSObject
/**
 @brief Primary property name
 @discussion
 CCMode requires every table to have a primary key
 */
@property (nonatomic, strong) NSString *primaryKey;
/**
 @brief Array of properties that need to be mapped to database columns
 
 @note
 The primary property is always at the top of this array
 */
@property (nonatomic, strong) NSMutableArray <NSString *> *arrayDBPropertyName;

/**
 @brief The type of property that determines how the CCModel maps the property to the database
 @discussion
 It can be

 @b CCModelPropertyTypeDefault

 @b CCModelPropertyTypeModel

 @b CCModelPropertyTypeJSON

 @b CCModelPropertyTypeCustom

 @b CCModelPropertyTypeSavingProtocol
 */
@property (nonatomic, strong) NSMutableDictionary *dicPropertyType;

@property (nonatomic, assign) NSInteger mmapIndex;

@end

@interface CCModelMapperManager : NSObject

+ (instancetype)sharedInstance;

/**
 @brief Dictionary containing the JSONModelMapper
 
 @code
 
 dicJSONMapper = @{@"yourCCModelClassName" : JSONModelMapperInstance};
 
 @endcode
 */
@property (nonatomic, strong) NSMutableDictionary <NSString *, CCJSONModelMapper*> *dicJSONMapper;
/**
 @brief Dictionary containing the PropertyMapper
 
 @code
 
 dicJSONMapper = @{@"yourCCModelClassName" : CCPropertyMapperInstance};
 
 @endcode
 */
@property (nonatomic, strong) NSMutableDictionary <NSString *, CCPropertyMapper*> *dicPropertyMapper;

/**
 @brief Initialize the JSONMapper and PropertyMapper of the CCModel. The CCModel can parse the JSON data into objects according to the JSONMapper, and parse the data inside the objects into the database according to the PropertyMapper.
 @param class Subclass of CCModel
 */
- (void)initializeMapperWithClass:(Class)class;
/**
 @brief Initialize the JSONMapper and PropertyMapper of all CCModel subclasses
 */
- (void)initializeAllMappers;

@end

