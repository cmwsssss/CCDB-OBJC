//
//  CCDBConnection.m
//  CCModelDemo
//
//  Created by cmw on 2021/7/1.
//

#import "CCDBConnection.h"
#import "CCDBMarco.h"
#import "CCDBInstancePool.h"
#import "CCDBTableManager.h"
#import "NSThread+CCDB.h"
#import "CCDBMMAPCache.h"
#import "CCDBUpdateManager.h"
#define DB_FILE_NAME @"db"

@implementation CCDBConnection

+ (NSString *)dbDocumentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbDocumentPath = [documentsDirectory stringByAppendingPathComponent:@"CCDB_data"];
    BOOL directory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbDocumentPath isDirectory:&directory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dbDocumentPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dbDocumentPath;
}

+ (void)initializeDBWithVersion:(NSString *)version {
    NSString *dbFileName = [NSString stringWithFormat:@"%@-%@", DB_FILE_NAME, version];
    NSString *dbFilePath = [[self dbDocumentPath] stringByAppendingPathComponent:dbFileName];
    __block BOOL needUpgrade = NO;
    __block BOOL needCreate = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbFilePath]) {
        NSArray <NSString *>*file = [[NSFileManager defaultManager] subpathsAtPath:[self dbDocumentPath]];
        needCreate = YES;
        [file enumerateObjectsUsingBlock:^(NSString  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj containsString:DB_FILE_NAME]) {
                [[NSFileManager defaultManager] moveItemAtPath:obj toPath:dbFilePath error:nil];
                needUpgrade = YES;
                needCreate = NO;
            }
        }];
    }
    NSLog(@"%@", dbFilePath);
    for (int i = 0; i < DB_INSTANCE_POOL_SIZE; i++) {
        [CCDBInstancePool addDBInstance:[self openDatabase:dbFilePath] index:i];
    }
    ccdb_syncAllLocalCache();
    [[CCDBUpdateManager sharedInstance] waitInit];
    
    if (needUpgrade) {
        [CCDBTableManager updateAllTable];
    } else if (needCreate) {
        [CCDBTableManager createAllTable];
    } else {
        [CCDBTableManager createAllTable];
    }
}

+ (sqlite3 *)openDatabase:(NSString *)filePath {
    
    sqlite3 *instance;
    
    sqlite3_config(SQLITE_CONFIG_MULTITHREAD);
    if (sqlite3_open_v2([filePath UTF8String], &instance, SQLITE_OPEN_CREATE|SQLITE_OPEN_READWRITE|SQLITE_OPEN_NOMUTEX, NULL) != SQLITE_OK) {
        sqlite3_close(instance);
        return nil;
    }
    sqlite3_exec(instance, "PRAGMA journal_mode=WAL;", NULL, 0, NULL);
    sqlite3_exec(instance, "PRAGMA wal_autocheckpoint=100;", NULL, 0, NULL);
    return instance;
}

+ (CCDBStatement *)statementWithQuery:(NSString *)sql db:(sqlite3 *)db {
    NSThread *currentThread = [NSThread currentThread];
    CCDBStatement *stmt = [currentThread.cc_statementsMap objectForKey:sql];
    if (stmt) {
        return stmt;
    } else {
        stmt = [CCDBStatement statementWithDB:db query:sql.UTF8String];
        [currentThread.cc_statementsMap setObject:stmt forKey:sql];
    }
    return stmt;
}

@end
