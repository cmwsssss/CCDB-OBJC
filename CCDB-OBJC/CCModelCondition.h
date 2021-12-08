//
//  CCModelCondition.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/1.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CCValueType) {
    CCValueTypeString,
    CCValueTypeNumber,
    CCValueTypeRaw,
};

#define CC_STRING_VALUE(value) ccStringValue:value
#define CC_NUMBER_VALUE(value) ccNumberValue:value
#define CC_RAW_VALUE(value) ccRawValue:value


#define CC_MODEL_CONDITION(key, type, value) [CCModelCondition createConditionWithCCKey:key conditionType:type value]

/**
 @brief This class is a wrapper of sql
 @code
 const char *where = "where (id = '1' and createdTime > 0) or(id = '2' and createdTime < 20) order by createdTime asc limit 20 offset 0"
 @endcode
 Equals
 @code
 
 CC_MODEL_CONDITION(@"id", @"=", CC_STRING_VALUE(@"1"))
 .and(CC_MODEL_CONDITION(@"createdTime" , @">", CC_NUMBER_VALUE(@(0))))
 .or(CC_MODEL_CONDITION(@"id", @"=", CC_STRING_VALUE(@"2"))
    .and(CC_MODEL_CONDITION(@"createdTime", @"<", CC_NUMBER_VALUE(@(20)))
 ))
 .ccOrderBy(@"createdTime")
 .ccLimited(20)
 .ccOffset(0);
 
 @endcode
 */
@interface CCModelCondition : NSObject <NSCopying>

/**
 @brief The wrapper of sql
 @code
 [CCModelCondition createConditionWithCCKey:@"userId" conditionType:@"=" ccStringValue:@"123"];
 @endcode
 
 Equals
 
 @code
 "userId = '123'"
 @endcode
 */
+ (CCModelCondition *)createConditionWithCCKey:(NSString *)key conditionType:(NSString *)type ccStringValue:(NSString *)ccValue __attribute__((unavailable("Only a tag for CCDB")));
/**
 @brief The wrapper of sql
 @code
 [CCModelCondition createConditionWithCCKey:@"createdTime" conditionType:@">" ccNumberValue:0];
 @endcode
 
 Equals
 
 @code
 "createdTime > 123"
 @endcode
 */
+ (CCModelCondition *)createConditionWithCCKey:(NSString *)key conditionType:(NSString *)type ccNumberValue:(NSNumber *)ccValue __attribute__((unavailable("Only a tag for CCDB")));
/**
 @brief The wrapper of sql
 @code
 [CCModelCondition createConditionWithCCKey:@"user.id" conditionType:@"=" ccRawValue:@"about.id"];
 @endcode
 
 Equals
 
 @code
 "user.id = about.id"
 @endcode
 */
+ (CCModelCondition *)createConditionWithCCKey:(NSString *)key conditionType:(NSString *)type ccRawValue:(NSString *)ccValue __attribute__((unavailable("Not support now!")));

@property (nonatomic, assign, readonly) NSInteger containerId;
@property (nonatomic, assign, readonly) NSInteger limited;
@property (nonatomic, assign, readonly) NSInteger offset;
@property (nonatomic, strong, readonly) NSString *key __attribute__((unavailable("Not support now!")));
@property (nonatomic, strong, readonly) NSString *where;

- (CCModelCondition *(^)(NSInteger))ccContainerId;
- (CCModelCondition *(^)(NSString *))ccKey __attribute__((unavailable("Not support now!")));
- (CCModelCondition *(^)(NSString *))ccValue __attribute__((unavailable("Not support now!")));
- (CCModelCondition *(^)(NSString *))ccWhere;
- (CCModelCondition *(^)(NSString *))ccStringValue __attribute__((unavailable("Not support now!")));
- (CCModelCondition *(^)(NSNumber *))ccNumberValue __attribute__((unavailable("Not support now!")));
- (CCModelCondition *(^)(NSString *))ccRawValue __attribute__((unavailable("Not support now!")));
- (CCModelCondition *(^)(NSString *))ccConditionType __attribute__((unavailable("Not support now!")));
- (CCModelCondition *(^)(CCModelCondition *))and __attribute__((unavailable("Not support now!")));
- (CCModelCondition *(^)(CCModelCondition *))or __attribute__((unavailable("Not support now!")));
- (CCModelCondition *(^)(NSInteger))ccLimited;
- (CCModelCondition *(^)(NSInteger))ccOffset;
- (CCModelCondition *(^)(NSString *))ccOrderBy;
- (CCModelCondition *(^)(BOOL))ccIsAsc;

- (NSString *(^)(void))sql;
- (NSString *(^)(void))innerSql;

@end
