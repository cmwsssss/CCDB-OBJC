//
//  CCSavingProtocl.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/5.
//

#ifndef CCSavingProtocl_h
#define CCSavingProtocl_h

#import "CCDBMarco.h"
#import "CCModelMapperManager.h"
/**
 @brief
 Classes that implement the CCDBSaving protocol can access CCDB for related database operations
 
 @discussion
 If you want to write a data model that is not a CCModel to the CCDB database, then you should declare it like this
 @note Make sure your data is basic type(such as NSInteger, float, bool...) or NSString*
 @code
 
 @interface MyObject : NSObject <CCDBSaving>

 CC_PROPERTY((nonatomic, strong), NSString *, foo_1)
 CC_PROPERTY((nonatomic, strong), NSString *, foo_2)

 @end
 @endcode
 
 If your model properties contain types that cannot be serialized, such as @b NSArray<CustomClass @b *>*, or if you need to customize the logic for accessing the data, you need to implement the following two methods.
 @note Make sure the data in the cc_JSONDictionary can be serialized as a string;
 
 @code
 - (void)cc_updateWithJSONDictionary:(NSDictionary *)dic;
 - (NSMutableDictionary *)cc_JSONDictionary;
 @endcode
 */
@protocol CCDBSaving <NSObject>

/**
 @brief Update your object with data from the dictionary
 
 @param dic data dictionary
 */
- (void)cc_updateWithJSONDictionary:(NSDictionary *)dic;

/**
 @brief Your object's data dictionary
 @discussion
 CCDB will save cc_JSONDictionary to the database, and it will be retured in cc_updateWithJSONDictionary
 @code
 - (void)cc_updateWithJSONDictionary:(NSDictionary *)dic {
    //Update your object with dic
 }
 @endcode
 */

- (NSMutableDictionary *)cc_JSONDictionary;

@end

#endif /* CCSavingProtocl_h */
