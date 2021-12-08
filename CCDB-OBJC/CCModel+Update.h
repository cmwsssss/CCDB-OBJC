//
//  CCModel+Update.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/5.
//

#import "CCModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @brief A category works for update data to the database
 */
@interface CCModel (Update)

/**
 @brief CCDB uses the "replace into" sql to update the database data, so every update sql is the same, here the update sql of the model is saved, next time you can omit the sql collocation process
 */
@property (nonatomic, strong) NSString *cc_updateSql;

/**
 @brief replace data into database;
 @note Do not invoke this method directly
 */
- (void)db_replaceIntoDB;
/**
 @brief replace data into database and container;
 @note Do not invoke this method directly
 @param top YES put the object on top of the container, NO put the object on bottom of the container
 @param containerId container's id
 */
- (void)db_replaceIntoDBWithContainerId:(long)containerId top:(BOOL)top;

@end

NS_ASSUME_NONNULL_END
