//
//  CCDBExecuteModel.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/2.
//

#import <Foundation/Foundation.h>
#import "CCDBEnum.h"

@interface CCDBExecuteModel : NSObject

/**
 @brief The sql waiting to be executed.
 */
@property (nonatomic, strong) NSString *sql;

/**
 @brief Class name of the target model.
 */
@property (nonatomic, strong) NSString *className;

/**
 @brief Name of primary property.
 */

@property (nonatomic, strong) id primaryKey;

/**
 @brief Query results, either as an array or as an object.
 */

@property (nonatomic, strong) id res;

/**
 @brief ContainerId, Works when querying different list data.
 */

@property (nonatomic, assign) NSInteger containerId;

/**
 @brief Type of primary property.
 */

@property (nonatomic, assign) CCModelPropertyDataType primaryKeyType;

@end
