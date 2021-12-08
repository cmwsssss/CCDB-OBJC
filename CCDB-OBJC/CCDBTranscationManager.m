//
//  CCDBTranscationManager.m
//  CCModelDemo
//
//  Created by cmw on 2021/7/1.
//

#import "CCDBTranscationManager.h"
#import <sqlite3.h>
#import "NSThread+CCDB.h"

@implementation CCDBTranscationManager

+ (void)beginTransaction {
    char *errmsg;
    sqlite3_exec([NSThread currentThread].cc_dbInstance, "BEGIN", NULL, NULL, &errmsg);
}

+ (void)commitTransaction {
    char *errmsg;
    sqlite3_exec([NSThread currentThread].cc_dbInstance, "COMMIT", NULL, NULL, &errmsg);
}

+ (void)rollbackTransaction {
    char *errmsg;
    sqlite3_exec([NSThread currentThread].cc_dbInstance, "ROLLBACK", NULL, NULL, &errmsg);
}

@end
