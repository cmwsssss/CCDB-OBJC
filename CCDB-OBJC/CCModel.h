//
//  CCModel.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/1.
//

#import <Foundation/Foundation.h>
#import "CCModelCondition.h"
#import "CCDBMarco.h"
#import "CCModelMapperManager.h"
/**
 @brief Models that inherit from CCModel can use the API provided by CCDB
 @discussion
 CCModel requires a primary property, Declare it in .m file
 @code
 @implementation MyModel
 
 CC_MODEL_PRIMARY_PROPERTY(primaryProperty)
 
 @end
 @endcode
 
 Declare the properties that need to access to the database like this:
 
 1. The type of property is a @b NSString or basic type such as @b int, @b float, @b double, @b long...
 @code
 @interface MyModel : CCModel
 
 CC_PROPERTY((nonatomic, strong), NSString *, foo_1)
 CC_PROPERTY((nonatomic, assign), NSinteger, foo_2)
 
 @end
 @endcode
 
 2. The class of the property is the type that implement the CCDBSaving protocol.
 @code
 @interface MyModel : CCModel
 
 CC_PROPERTY((nonatomic, strong), id<CCDBSaving> *, foo, CCModelPropertyTypeSavingProtocol)
 
 @end
 @endcode
 
 3. The class of the property is inherit from CCModel.
 @code
 @interface MyModel : CCModel
 
 CC_PROPERTY((nonatomic, strong), CCModel *, foo, CCModelPropertyTypeModel)
 
 @end
 @endcode
 
 4.The class of the property is a NSArray or NSDictionary and it can be serialized to a JSON string.
 @code
 @interface MyModel : CCModel
 
 CC_PROPERTY((nonatomic, strong), NSArray *, foo_1, CCModelPropertyTypeJSON)
 CC_PROPERTY((nonatomic, strong), NSDictionary *, foo_1, CCModelPropertyTypeJSON)
 
 @end
 @endcode
 
 5. The class of property is a custom class
 
 @code
 @interface MyModel : CCModel
 
 CC_PROPERTY((nonatomic, strong), CustomModel *, foo_1, CCModelPropertyTypeCustom)
 
 @end
 @endcode
 
 @attention implement these method in your .m file
 
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
 
 CCModel supports automatic JSON mapping, you just need to declare the property like this
 
 @note
 CCDB use @b __ to indicate the hierarchical relationship of json
 
 a__b__c means: {"a" : { "b":{ "c" : 1 } } }
 
 @code
 
 //If we want to automatically parse such a JSON
 //{
 //    "title":"hello",
 //    "content":"Nice to meet you",
 //    "user":{
 //        "userId":123,
 //        "username":"CCDB",
 //        "about":{
 //            "headline":"Nice persion",
 //            "tag" : "foo",
 //        },
 //        "tag": "foo"
 //    }
 //}
  
 @interface Message : CCModel

 CC_PROPERTY_JSON((nonatomic, strong), NSString *, title, title);
 CC_PROPERTY_JSON((nonatomic, strong), NSString *, content, content);
 CC_PROPERTY_JSON_TYPE((nonatomic, strong), UserModel *, user, CCModelPropertyTypeModel, user);
 CC_PROPERTY_JSON((nonatomic, strong), NSString *, tag, user__tag); //parse {"user":{"tag"}}
 CC_PROPERTY_JSON((nonatomic, strong), NSString *, aboutTag, user__about__tag);// parse {"user":{"about" : {"tag"}}}

 @end
  
 @interface UserModel : CCModel
 
 CC_PROPERTY_JSON((nonatomic, assign), NSInteger, userId, userId);
 CC_PROPERTY_JSON((nonatomic, strong), NSString *, username, username);
 CC_PROPERTY_JSON((nonatomic, strong), NSString *, headline, about__headline); // parse {"about" : {"headline"}}
 
 @end
  
 @endcode
 */
@interface CCModel : NSObject

/**
 @brief CCModel will automatically parse the json and populate it with data based on your property declaration
 @param dic JSONDictionary
 @return CCModel object
 */
- (instancetype)initWithJSONDictionary:(NSDictionary *)dic;

/**
 @brief CCModel will automatically parse the json and populate it with data based on your property declaration, and put the object into the specified container
 @param dic JSONDictionary
 @param containerId The object will be put into the container with containerId
 @return CCModel object
 */
- (instancetype)initWithJSONDictionary:(NSDictionary *)dic containerId:(NSInteger)containerId;

/**
 @brief CCDB will query from the cache based on the value of the primary property, and if there are no results, then look up from the database
 @param primaryProperty value of the primary property, can be NSNumber, NSString
 @return CCModel object
 */
- (instancetype)initWithPrimaryProperty:(id)primaryProperty;

/**
 @brief load all the data in the table corresponding to this model
 @param isAsc sort by rowid
 @return All data in this table
 */
+ (NSMutableArray *)loadAllDataWithAsc:(BOOL)isAsc;

/**
 @brief load all the data of the model's objects in this container
 @discussion
 @b Usage @b Scenarios:

 If we need to show two lists of viste me and my visit, both of which are to show UserModel(Inherited from CCModel) data, then we can do this.
 @code
 
 NSInteger visitMeId = 1;
 NSInteger myVisitId = 2;
 
 //init UserModel object
 UserModel *object = [[UserModel alloc] initWithJSONDictionary:data];
 
 //replace object into database and put it into visitMe container
 [object replaceIntoDBWithContainerId:visitMeId top:YES];
 
 //replace object into database and put it into myVisit container
 [object replaceIntoDBWithContainerId:myVisitId top:YES];
 
 //load all UserModel data from visitMeContainer
 NSArray *dataVisitMe = [loadAllDataWithAsc:NO containerId:visitMeId];
 
 //load all UserModel data from myVisitContainer
 NSArray *dataMyVisit = [loadAllDataWithAsc:NO containerId:myVisitId];

 
 @endcode
 @param isAsc Sort the data according to the order in which they were added to the container
 @param containerId container's id
 @return All data in this container
 */
+ (NSMutableArray *)loadAllDataWithAsc:(BOOL)isAsc containerId:(long)containerId;

/**
 @brief Query data based on conditions.
 @param condition sql which is wrapped as a CCModelCondition object.
 @return Objects which meet the conditions.
 */
+ (NSMutableArray *)loadDataWithCondition:(CCModelCondition *)condition;

/**
 @brief replace data into database;
 */
- (void)replaceIntoDB;

/**
 @brief replace data into database;
 @discussion
 @b Usage @b Scenarios:

 If we need to show two lists of viste me and my visit, both of which are to show UserModel(Inherited from CCModel) data, then we can do this.
 @code
 
 NSInteger visitMeId = 1;
 NSInteger myVisitId = 2;
 
 //init UserModel object
 UserModel *object = [[UserModel alloc] initWithJSONDictionary:data];
 
 //replace object into database and put it into visitMe container
 [object replaceIntoDBWithContainerId:visitMeId top:YES];
 
 //replace object into database and put it into myVisit container
 [object replaceIntoDBWithContainerId:myVisitId top:YES];
 
 //load all UserModel data from visitMeContainer
 NSArray *dataVisitMe = [loadAllDataWithAsc:NO containerId:visitMeId];
 
 //load all UserModel data from myVisitContainer
 NSArray *dataMyVisit = [loadAllDataWithAsc:NO containerId:myVisitId];

 
 @endcode
 @param top YES put the object on top of the container, NO put the object on bottom of the container
 @param containerId container's id
 */
- (void)replaceIntoDBWithContainerId:(NSInteger)containerId top:(BOOL)top;

/**
 @brief Create an index for a specified column of a database table
 @param propertyName column's Name
 */
+ (void)createIndexForProperty:(NSString *)propertyName;

/**
 @brief remove index for a specified column of a database table
 @param propertyName column's Name
 */
+ (void)removeIndexForProperty:(NSString *)propertyName;

/**
 @brief remove this object from database and cache;
 */
- (void)removeFromDB;

/**
 @brief remove this object from a specified container
 @param containerId Specified container id
 */
- (void)removeFromContainer:(long)containerId;

/**
 @brief Remove all the data from the table
 */
+ (void)removeAll;

/**
 @brief Remove all the data from a specified container
 @param containerId Specified container id
 */
+ (void)removeAllWithContainerId:(long)containerId;
/**
 @brief Get the count of the data in the table
 @return Count of the data
 */
+ (NSInteger)count;

/**
 @brief Get the count of the data that meets the condition
 @param condition sql which is wrapped as a CCModelCondition object.
 @return Count of the data
 */
+ (NSInteger)countBy:(CCModelCondition *)condition;

/**
 @brief The sum of the data for this property
 @param propertyName propertyName
 @return Sum of the data
 */
+ (NSInteger)sumProperty:(NSString *)propertyName;

@end
