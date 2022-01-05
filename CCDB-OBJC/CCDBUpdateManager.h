//
//  CCBackgroundDBManager.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/5.
//

#import <Foundation/Foundation.h>
#import "CCDBUpdateModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @brief Manager for database data updates.
 
 @discussion
 All database update operations for CCDB are managed by this manager, which has a separate runloop to handle the update queue
 */
@interface CCDBUpdateManager : NSObject

/**
 @brief Get CCDBUpdateManager instance
 @return CCDBUpdateManager instance
 */
+ (instancetype)sharedInstance;
- (void)waitInit;

@end

NS_ASSUME_NONNULL_END
