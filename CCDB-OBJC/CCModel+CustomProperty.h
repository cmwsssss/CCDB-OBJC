//
//  CCModel+Custom.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/5.
//

#import "CCModel.h"
/**
 @brief A Category works for CCModelPropertyTypeCustom
 @discussion
 If the object has a property of type CCModelPropertyTypeCustom, then you need to implement the following two methods in your class .m file, otherwise the value of the property will not be saved to the database.
 
 @code
 @implementation MyModel
 
 - (NSMutableDictionary *)customJSONDictionary {
     NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
     //Serialization of data...
     [dic setObject:serializedFoo_1 forKey:@"foo_1"];
     return dic;
 }

 - (void)updateDataWithCustomJSONDictionary:(NSMutableDictionary *)dic {
     id serializedFoo_1 = [dic objectForKey:@"foo_1"];
     //update foo_1 with serializedFoo_1
 }
 
 @end
 @endcode
 */
@interface CCModel (CustomProperty)

/**
 @brief implement this method like this:
 
 @code
 
 @interface MyModel
 
 CC_PROPERTY_TYPE((nonatomic, strong), Foo_1*, foo_1, CCModelPropertyTypeCustom)
 CC_PROPERTY_TYPE((nonatomic, strong), Foo_2*, foo_2, CCModelPropertyTypeCustom)
 
 @end
 
 @implementation MyModel
 
 - (NSMutableDictionary *)customJSONDictionary {
     NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
     //Serialization of data...
     [dic setObject:serializedFoo_1 forKey:@"foo_1"];
     [dic setObject:serializedFoo_2 forKey:@"foo_2"];
     return dic;
 }
 
 @end

 @endcode
 */
- (NSMutableDictionary *)customJSONDictionary;

/**
 @brief implement this method like this:
 
 @code
 
 @interface MyModel
 
 CC_PROPERTY_TYPE((nonatomic, strong), Foo_1*, foo_1, CCModelPropertyTypeCustom)
 CC_PROPERTY_TYPE((nonatomic, strong), Foo_2*, foo_2, CCModelPropertyTypeCustom)
 
 @end
 
 @implementation MyModel
 
 - (void)updateDataWithCustomJSONDictionary:(NSMutableDictionary *)dic {
     id serializedFoo_1 = [dic objectForKey:@"foo_1"];
     id serializedFoo_2 = [dic objectForKey:@"foo_2"];
     //update foo_1 with serializedFoo_1
     //update foo_2 with serializedFoo_2
 }
 
 @end

 @endcode
 */
- (void)updateDataWithCustomJSONDictionary:(NSMutableDictionary *)dic;

@end
