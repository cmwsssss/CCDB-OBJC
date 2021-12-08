//
//  CCDB.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/1.
//

#ifndef CCDB_h
#define CCDB_h

#import <Foundation/Foundation.h>
#import "CCModel.h"
#import "CCModelCondition.h"
#import "CCDBMarco.h"
#import "CCDBSavingProtocol.h"
#import "CCDBEnum.h"
@interface CCDB : NSObject

/**
 
 @brief  Used to perform conditional queries on CCDB.
 
 @discussion Please call this method before using the CCDB API. This method will determine whether to update the database based on the version, and when your data model changes, then the value of the version will need to be changed
 
 @param version Current version of the database

 */
+ (void)initializeDBWithVersion:(NSString *)version;

@end

#endif /* CCDB_h */
