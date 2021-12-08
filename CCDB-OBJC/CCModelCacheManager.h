//
//  CCModelCacheManager.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/2.
//

#import <Foundation/Foundation.h>

/**
 @brief CCDB's cache manager
 @discussion
 CCModelCacheManager provides management services for CCDB's cache, whenever the object's @b replaceIntoDB is invoked, the object will be added to the cache, which can speed up the next load of the object
 */
@interface CCModelCacheManager : NSObject
/**
 @brief share a global CCModelCacheManager object
 @return CCModelCacheManager
 */
+ (instancetype)sharedInstance;

/**
 @brief Get the data from the cache by the value of the primary property and the name of the class
 @param primaryKey value of object's primary primaryKey
 @param className class name of object
 @return Query Result
 */
- (instancetype)modelWithPrimaryKey:(id)primaryKey className:(NSString *)className;

/**
 @brief Get the data in the container from the cache based on the id of the container and the name of the class
 @param containerId id of the specified container
 @param className class name of object
 @param isAsc Sort the data according to the order in which they were added to the container
 @return Query Results
 */
- (NSMutableArray *)modelsWithContainerId:(NSInteger)containerId className:(NSString *)className isAsc:(BOOL)isAsc;

/**
 @brief Save the data to the cache and put them into the specified container
 @param objects Data to be saved.
 @param containerId id of the specified container.
 @param className class name of object.
 @param isAsc YES Put the data into container in order NO Put the data into container in reverse order
 */
- (void)setModelsToCache:(NSMutableArray *)objects containerId:(NSInteger)containerId className:(NSString *)className isAsc:(BOOL)isAsc;

/**
 @brief Remove model from cache by the value of the primary property and the name of the class
 @param primaryKey value of object's primary primaryKey
 @param className class name of object
 */
- (void)removeModelWithPrimaryKey:(id)primaryKey className:(NSString *)className;

/**
 @brief Remove model from container by the value of the primary property, the name of the class and container id
 @param primaryKey value of object's primary primaryKey
 @param className class name of object
 @param containerId id of container
 */
- (void)removeModelWithPrimaryKey:(id)primaryKey className:(NSString *)className containerId:(NSInteger)containerId;

/**
 @brief Empty the data in the container by the name of the class
 @param containerId id of container
 @param className class name of object
 */
- (void)removeAllModelWithContainerId:(NSInteger)containerId className:(NSString *)className;

/**
 @brief Save the objects to the cache
 @param object Data to be saved.
 @param primaryKey value of object's primary primaryKey
 @param className class name of object
 */
- (void)addModelToCache:(id)object primaryKey:(id)primaryKey className:(NSString *)className;

/**
 @brief Save the object to the cache and put it into the specified container
 @param object Data to be saved.
 @param containerId id of the specified container.
 @param className class name of object.
 @param top YES put the object on top of the container, NO put the object on bottom of the container
 */
- (void)addModelToContainerCache:(id)object className:(NSString *)className containerId:(NSInteger)containerId top:(BOOL)top;

/**
 @brief Empty cache
 */
- (void)clearAllMemoryCache;

@end

