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


/**
 @brief Add object to update queue
 @discussion
 Add the data object to be updated to the database to the update queue, CCDB will update it to the database at the right time
 @param object CCmodel or CCDBUpdateModel object
 */
- (void)addObject:(id)object;

@end

NS_ASSUME_NONNULL_END
