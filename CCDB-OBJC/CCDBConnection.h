//
//  CCDBConnection.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/1.
//

#import <Foundation/Foundation.h>
#import "CCDBStatement.h"
#import <sqlite3.h>


@interface CCDBConnection : NSObject
/**
 
 @brief Create a statement with sql string and sqlite3 instance.
 
 @note Do not use this method directly, it is not thread-safe
 
 @param sql sql
 
 @param db sqlite3 instance;
 
 */

+ (CCDBStatement *)statementWithQuery:(NSString *)sql db:(sqlite3 *)db;

/**
 @brief
 This method will initialize your database, and you need to call it before you can manipulate it.
 
 @discussion
 CCDB will decide whether to migrate the data based on your version. If your CCModel has changed properties, please use a different version number so that the CCDB will migrate the data.
 
 @param version
 Database version, CCDB compares this param with the current version number and migrates the data if it is different.
 
 */

+ (void)initializeDBWithVersion:(NSString *)version;

@end

