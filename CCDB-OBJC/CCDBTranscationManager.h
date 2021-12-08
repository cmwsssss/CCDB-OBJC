//
//  CCDBTranscationManager.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/1.
//

#import <Foundation/Foundation.h>

@interface CCDBTranscationManager : NSObject

/**
 @brief Begin this transaction.
 */
+ (void)beginTransaction;
/**
 @brief Commit this transaction.
 */
+ (void)commitTransaction;
/**
 @brief Rollback this transaction.
 */
+ (void)rollbackTransaction;

@end

