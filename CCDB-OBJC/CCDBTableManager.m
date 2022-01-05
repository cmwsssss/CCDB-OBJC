//
//  CCDBTableManager.m
//  CCModelDemo
//
//  Created by cmw on 2021/7/1.
//

#import "CCDBTableManager.h"
#import "CCModelMapperManager.h"
#import "NSObject+Bitmap.h"
#import "CCModelUtils.h"
#import "CCDBExecuteModel.h"
#import "CCDBStatement.h"
#import "NSThread+CCDB.h"
#import "CCDBInstancePool.h"
@implementation CCDBTableManager

+ (void)createAllTable {
    unsigned int count;
    Class *classList = objc_copyClassList(&count);
    
    for (int i = 0; i < count; i++) {
        Class class = classList[i];
        if ([NSStringFromClass(class) containsString:@"-pure"]) {
            continue;
        }
        if(strcmp("CCModel", class_getName(class_getSuperclass(class)))== 0) {
            [self createTableWithClass:class];
        }
    }
    free(classList);
}

+ (void)updateAllTable {
    unsigned int count;
    Class *classList = objc_copyClassList(&count);
    
    for (int i = 0; i < count; i++) {
        Class class = classList[i];
        if ([NSStringFromClass(class) containsString:@"-pure"]) {
            continue;
        }
        if(strcmp("CCModel", class_getName(class_getSuperclass(class)))== 0) {
            [self updateTableWithClass:class];
        }
    }
    free(classList);
}

+ (NSString *)getSqlType:(CCModelPropertyDataType)dataType {
    switch (dataType) {
        case CCModelPropertyDataTypeLong:
            return @"INTEGER";
        case CCModelPropertyDataTypeInt:
            return @"INTEGER";
        case CCModelPropertyDataTypeFloat:
            return @"REAL";
        case CCModelPropertyDataTypeBool:
            return @"BLOB";
        case CCModelPropertyDataTypeString:
            return @"TEXT";
        default:
            break;
    }
    return nil;
}

+ (NSString *)getCreateTableString:(Class)class {
    NSString *className = NSStringFromClass([class class]);
    
    __block NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (",className];
    CCPropertyMapper *mapper = [[CCModelMapperManager sharedInstance].dicPropertyMapper objectForKey:className];
    const char *propertyTypeBitmap = [class cc_propertyTypeBitmap].UTF8String;
    const char *dataTypeBitmap = [class cc_dataTypeBitmap].UTF8String;
    [mapper.arrayDBPropertyName enumerateObjectsUsingBlock:^(NSString * _Nonnull name, NSUInteger idx, BOOL * _Nonnull stop) {
        if(idx != 0) {
            sql = [NSString stringWithFormat:@"%@,",sql];
        }
        CCModelPropertyDataType dataType = (int)dataTypeBitmap[idx];
        CCModelPropertyType propertyType = (int)propertyTypeBitmap[idx];
        switch (propertyType) {
            case CCModelPropertyTypeDefault:
                sql = [NSString stringWithFormat:@"%@ %@ %@",sql,name, [self getSqlType:dataType]];
                break;
            case CCModelPropertyTypeJSON:
            case CCModelPropertyTypeSavingProtocol:
            case CCModelPropertyTypeCustom:
                sql = [NSString stringWithFormat:@"%@ %@ TEXT",sql,name];
                break;
            case CCModelPropertyTypeModel: {
                objc_property_t modelProperty = class_getProperty(objc_getClass(className.UTF8String), name.UTF8String);
                Class subClass = [CCModelUtils loadClassFromProperty:modelProperty];
                sql = [NSString stringWithFormat:@"%@ %@ %@",sql,name, [self getSqlType:(int)[subClass cc_dataTypeBitmap].UTF8String[0]]];
            }
            default:
                break;
        }
    }];
    sql = [NSString stringWithFormat:@"%@, PRIMARY KEY(%@) );",sql,mapper.primaryKey];
    return sql;
}

+ (NSString *)getInsertTableStringFrom:(NSDictionary *)params class:(Class)class{
    NSString *oldTableName = [params objectForKey:@"oldTableName"];
    NSMutableArray *oldPropertyNames = [params objectForKey:@"oldPropertyNames"];
    NSString *className = NSStringFromClass(class);
    NSString *nameString = [oldPropertyNames componentsJoinedByString:@","];
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) SELECT %@", className, nameString, nameString];
    sql = [NSString stringWithFormat:@"%@ FROM %@;",sql,oldTableName];
    return sql;
}

+ (NSString *)getCreateContainerIndexTableString:(Class)class {
    NSString *className = NSStringFromClass(class);
    NSString *primaryKeyType = [self getSqlType:[class cc_dataTypeBitmap].UTF8String[0]];
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@_index (id TEXT, hash_id INTEGER, primary_key %@, update_time INTEGER, PRIMARY KEY(id));", className, primaryKeyType];
    return sql;
}

+ (void)executeWithSql:(NSString *)sql {
    CCDBStatement *stmt = [CCDBStatement statementWithDB:[NSThread currentThread].cc_dbInstance query:sql.UTF8String];
    if ([stmt step] != SQLITE_DONE) {
        
    }
    [stmt reset];
}

+ (void)executeWithModel:(CCDBExecuteModel *)model {
    CCDBStatement *stmt = [CCDBStatement statementWithDB:[NSThread currentThread].cc_dbInstance query:model.sql.UTF8String];
    NSMutableArray *oldPropertyNames = [[NSMutableArray alloc] init];
    while ([stmt step] == SQLITE_ROW) {
        [oldPropertyNames addObject:[stmt getString:1]];
    }
    model.res = oldPropertyNames;
    [stmt reset];
}

+ (void)createTableWithClass:(Class)class {
    [self performSelector:@selector(executeWithSql:) onThread:[CCDBInstancePool getDBTransactionThread] withObject:[self getCreateTableString:class] waitUntilDone:YES];
    
    [self performSelector:@selector(executeWithSql:) onThread:[CCDBInstancePool getDBTransactionThread] withObject:[self getCreateContainerIndexTableString:class] waitUntilDone:YES];
}


+ (void)updateTableWithClass:(Class)class {
    NSString *className = [NSString stringWithUTF8String:class_getName(class)];
    NSDate *date = [NSDate new];
    NSString *classNameTemp = [NSString stringWithFormat:@"%@_%d",class,(int)date.timeIntervalSince1970];
    NSString *renameSql = [NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@;",className,classNameTemp];
    
    [self performSelector:@selector(executeWithSql:) onThread:[CCDBInstancePool getDBTransactionThread] withObject:renameSql waitUntilDone:YES];
    
    [self performSelector:@selector(executeWithSql:) onThread:[CCDBInstancePool getDBTransactionThread] withObject:[self getCreateTableString:class] waitUntilDone:YES];

    CCDBExecuteModel *exeModel = [[CCDBExecuteModel alloc] init];
    exeModel.sql = [NSString stringWithFormat:@"PRAGMA table_info('%@')", classNameTemp];
    [self performSelector:@selector(executeWithModel:) onThread:[CCDBInstancePool getDBTransactionThread] withObject:exeModel waitUntilDone:YES];

    NSDictionary *params =@{@"oldTableName":classNameTemp, @"oldPropertyNames":exeModel.res};
    
    [self performSelector:@selector(executeWithSql:) onThread:[CCDBInstancePool getDBTransactionThread] withObject:[self getInsertTableStringFrom:params class:class] waitUntilDone:YES];
    
    [self performSelector:@selector(executeWithSql:) onThread:[CCDBInstancePool getDBTransactionThread] withObject:[NSString stringWithFormat:@"DROP TABLE %@;",classNameTemp] waitUntilDone:YES];

}



@end
