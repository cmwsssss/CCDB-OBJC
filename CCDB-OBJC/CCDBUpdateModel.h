//
//  CCDBUpdateModel.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/5.
//

#import <Foundation/Foundation.h>
#import "CCModel.h"
NS_ASSUME_NONNULL_BEGIN

/**
 @brief Used to update both the model and the associated container
 */
@interface CCDBUpdateModel : NSObject

/**
 @brief object to be updated to the database
 */
@property (nonatomic, strong) CCModel *object;

/**
 @brief The associated container id
 */
@property (nonatomic, assign) NSInteger containerId;

/**
 @brief
 @b YES put the object in the top of the container, @b NO put the object in the bottom of the container.
 */
@property (nonatomic, assign) BOOL top;

@end

NS_ASSUME_NONNULL_END
