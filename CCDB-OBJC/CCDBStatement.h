//
//  CCDBStatement.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/1.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "CCDBEnum.h"
/**
 @brief This class is a wrapper for sqlite3_stmt.
 */
@interface CCDBStatement : NSObject
/**
 @brief prepare statement with sqlite3 instance and sql
 @param db sqlite3 instance
 @param sql sql waiting to be compiled
 @return a CCDBStatement object
 */
+ (instancetype)statementWithDB:(sqlite3 *)db query:(const char *)sql;

/**
 @brief The wrapper of sqlite3_step.
 @return 1 means you can continue stepping.
         0 means the stepping has been completed or an error occurs.
 */
- (int)step;
/**
 @brief The wrapper of sqlite3_reset.
 */
- (void)reset;
/**
 @brief The wrapper of sqlite3_finalize.
 */
- (void)finish;

/**
 @brief The wrapper of sqlite3_column_text.
 @param index Begin with 1.
 @return string value
 */
- (NSString *)getString:(int)index;

/**
 @brief The wrapper of sqlite3_column_int.
 @param index Begin with 1.
 @return int value
 */
- (int)getInt32:(int)index;

/**
 @brief The wrapper of sqlite3_column_int64.
 @param index Begin with 1.
 @return long long value
 */
- (long)getInt64:(int)index;

/**
 @brief The wrapper of sqlite3_column_double.
 @param index Begin with 1.
 @return float value
 */
- (float)getFloat:(int)index;

/**
 @brief The wrapper of sqlite3_column_bytes.
 @param index Begin with 1.
 @return NSdata* value
 */
- (NSData *)getData:(int)index;

/**
 @brief The wrapper of sqlite3_bind_*.
 @param value The type can be NSString, NSNumber, NSData and nil.
 @param dataType CCDB does not do type determination for bind value in the sqlite3 instance worker thread, so you need to prepare the type of bind value in advance.
 @param index Begin with 1.
 */
- (void)bind:(id)value withDataType:(CCModelPropertyDataType)dataType forIndex:(int)index;

/**
 @brief The wrapper of sqlite3_bind_text.
 @param value NSString value.
 @param index Begin with 1.
 */
- (void)bindString:(NSString *)value forIndex:(int)index;

/**
 @brief The wrapper of sqlite3_bind_int.
 @param value int value.
 @param index Begin with 1.
 */
- (void)bindInt32:(int)value forIndex:(int)index;

/**
 @brief The wrapper of sqlite3_bind_int64.
 @param value long value.
 @param index Begin with 1.
 */
- (void)bindInt64:(long)value forIndex:(int)index;

/**
 @brief The wrapper of sqlite3_bind_double.
 @param value float value.
 @param index Begin with 1.
 */
- (void)bindFloat:(float)value forIndex:(int)index;

/**
 @brief The wrapper of sqlite3_bind_blob.
 @param data NSData value.
 @param index Begin with 1.
 */
- (void)bindData:(NSData *)data forIndex:(int)index;

/**
 @brief The wrapper of sqlite3_bind_double.
 @param value double value.
 @param index Begin with 1.
 */
- (void)bindDouble:(double)value forIndex:(int)index;

@end

