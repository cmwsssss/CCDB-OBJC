//
//  NSThread+CCDB.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/1.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
NS_ASSUME_NONNULL_BEGIN

@interface NSThread (CCDB)

/**
 @brief The sqlite3 instance binded to the current thread
 */
@property (nonatomic, assign) sqlite3 *cc_dbInstance;
/**
 @brief Compiled statements in the current thread
 @discussion
 If the same sql needs to be compiled next time, the corresponding statement will be taken out and used directly, no need to compile again.
 */
@property (nonatomic, strong) NSMutableDictionary *cc_statementsMap;

/**
 Only the index of sqlite3 instance is stored in the thread, not the specific sqlite3 instance
 */
- (void)setDbInstanceWithIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
