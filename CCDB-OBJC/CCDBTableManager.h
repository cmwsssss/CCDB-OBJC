//
//  CCDBTableManager.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/1.
//

#import <Foundation/Foundation.h>

@interface CCDBTableManager : NSObject

/**
 @brief Create database table
 
 @discussion
 Create database tables using information about the properties of CCModel subclasses or class that implement the CCDBSaving protocol
 */
+ (void)createAllTable;

/**
 @brief update database table
 
 @discussion
 CCDB updates the database table and migrates the data when the properties of the model change
 */
+ (void)updateAllTable;

@end

