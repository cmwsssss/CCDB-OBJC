//
//  CCDBInstancePool.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/1.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#define DB_INSTANCE_POOL_SIZE 4

/**
 @brief sqlite3 instances manager, The number of instances depends on the number of cores on your cpu
 */
@interface CCDBInstancePool : NSObject
/**
 @abstract Get a sqlite3 worker thread
 
 @discussion CCDB works on the @b"multi-thread" threading mode, it binds threads and instances directly.
 
 CCDB's operation is absolutely thread-safe, No need to put a lock on any operation, the sqlite3 instance will only work on the binded thread, so only NSThread will be returned here, if you want to perform database operation directly, you should do it like this
 @code
 
 - (void)db_update:(NSString *)sql {
    CCDBStatement *stmt = [CCDBConnection statementWithQuery:sql db:[NSThread currentThread].cc_dbInstance];
    [stmt step];
    [stmt reset];
 }
 
 - (void)update {
    NSString *sql = @"update sql";
    NSThread *worker = [CCDBInstancePool getDBTransactionThread];
    [self performSelector:@selector(db_update:) onThread:[CCDBInstancePool getDBTransactionThread] withObject:sql waitUntilDone:NO];
 }
 @endcode
 
 @return Work thread for a sqlite3 instance
 
 */

+ (NSThread *)getDBTransactionThread;

/**
 @abstract Get a specified sqlite3 worker thread
 
 @param index thread index
 @return a sqlite3 worker thread
 */

+ (NSThread *)getDBThreadWithIndex:(NSInteger)index;

/**
 @brief Get a specified sqlite3 instance
 
 @note Do not use this method directly, it is not thread-safe
 
 @param index sqlite3 instance index
 @return a sqlite3 instance
 */

+ (sqlite3 *)getDBInstanceWithIndex:(NSInteger)index;

/**
 @brief Add a sqlite3 instance to the instance pool
 
 @param instance sqlite3 instance.
 @param index instance index
 */

+ (void)addDBInstance:(sqlite3 *)instance index:(NSInteger)index;

@end
