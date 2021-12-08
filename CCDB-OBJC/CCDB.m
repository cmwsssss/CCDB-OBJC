//
//  CCDB.m
//  CCModelDemo
//
//  Created by cmw on 2021/7/6.
//

#import "CCDB.h"
#import "CCDBConnection.h"
#import "CCModelMapperManager.h"
@implementation CCDB

+ (void)initializeDBWithVersion:(NSString *)version {
    [[CCModelMapperManager sharedInstance] initializeAllMappers];
    [CCDBConnection initializeDBWithVersion:version];
}

@end

