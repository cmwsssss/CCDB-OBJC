//
//  CCModel.m
//  CCModelDemo
//
//  Created by cmw on 2021/7/1.
//

#import "CCModel.h"
#import "CCModelMapperManager.h"
#import "CCModelUtils.h"
#import "CCModelCacheManager.h"
#import "CCModel+ExtractData.h"
#import "CCDBExecuteModel.h"
#import "NSObject+Bitmap.h"
#import "CCDBConnection.h"
#import "NSObject+CC_JSON.h"
#import "CCModel+CustomProperty.h"
#import "CCDBUpdateManager.h"
#import "NSThread+CCDB.h"
#import "CCDBInstancePool.h"
#import "CCDBMMAPCache.h"
#import "NSObject+CCDBSavingProtocolImp.h"
#import "CCDBSavingProtocol.h"
@implementation CCDBPropertyTag

@end

@implementation CCJSONPathTag

@end

@implementation CCModel

+ (NSString *)getSelectSqlHeaderPart:(NSString *)className joinTableName:(NSString *)joinTableName {
    CCPropertyMapper *propertyMapper = [[CCModelMapperManager sharedInstance].dicPropertyMapper objectForKey:className];
    NSArray *arrayPropertyDBList = propertyMapper.arrayDBPropertyName;
    
    NSString *sql = @"SELECT ";
    
    for(int i = 0; i < arrayPropertyDBList.count; i++) {
        NSString *name = [arrayPropertyDBList objectAtIndex:i];
        
        sql = (i == 0)
        ?[NSString stringWithFormat:@"%@%@",sql,name]
        :[NSString stringWithFormat:@"%@, %@",sql,name];
    }
    sql = [NSString stringWithFormat:@"%@ FROM %@",sql,className];
    if(joinTableName) {
        sql = [NSString stringWithFormat:@"%@, %@ as i",sql,joinTableName];
    }
    return sql;
}

- (void)updateWithJSONDictionary:(NSDictionary *)dic containerId:(NSInteger)containerId {
    NSMutableDictionary *formatDic = [[NSMutableDictionary alloc] init];
    NSString *className = NSStringFromClass([self class]);
    [CCModelUtils setupFormatDic:formatDic JSONDic:dic parentKey:nil];
    CCJSONModelMapper *JSONMapper = [[CCModelMapperManager sharedInstance].dicJSONMapper objectForKey:className];
    CCPropertyMapper *propertyMapper = [[CCModelMapperManager sharedInstance].dicPropertyMapper objectForKey:className];
    [formatDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *propertyName = [JSONMapper.dicJSONToProperty objectForKey:key];
        if (propertyName) {
            CCModelPropertyType type = [[propertyMapper.dicPropertyType objectForKey:propertyName] integerValue];
            if (type == CCModelPropertyTypeDefault) {
                [self setValue:obj forKey:propertyName];
            } else {
                [self.cc_dbRawData setObject:obj forKey:propertyName];
            }
        }
    }];
    
    [self replaceIntoDBWithContainerId:containerId top:YES];
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dic containerId:(NSInteger)containerId {
    NSString *className = NSStringFromClass([self class]);
    Class class = objc_getClass(className.UTF8String);
    CCJSONModelMapper *JSONMapper = [[CCModelMapperManager sharedInstance].dicJSONMapper objectForKey:className];
    NSArray *JSONPrimaryKeys = JSONMapper.dicJSONPrimaryKey.allKeys;
    for (NSString *keyPath in JSONPrimaryKeys) {
        id primaryValue = [CCModelUtils getValueFromJSONDic:dic keyPath:keyPath];
        if (primaryValue) {
            self = [[CCModelCacheManager sharedInstance] modelWithPrimaryKey:primaryValue className:className];
            if (self) {
                break;
            }
            self = [[class alloc] initWithPrimaryProperty:primaryValue];
            if (self) {
                break;;
            }
        }
    }
    if (!self) {
        self = [[class alloc] init];
    }
    if (self) {
        [self updateWithJSONDictionary:dic containerId:containerId];
    }
    return self;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dic {
    return [[[self class] alloc] initWithJSONDictionary:dic containerId:NOContainerId];
}

+ (instancetype)createModelWithStatement:(CCDBStatement *)stmt
                     arrayDBPropertyList:(NSArray *)arrayDBPropertyList
                          dataTypeBitmap:(const char *)dataTypeBitmap
                     primaryPropertyName:(NSString *)primaryPropertyName
                               className:(NSString *)className {
    id model = [[self alloc]init];
    for(int i = 0; i < arrayDBPropertyList.count; i++) {
        NSString *propertyName = [arrayDBPropertyList objectAtIndex:i];
        CCModelPropertyDataType dataType = (int)dataTypeBitmap[i];
        id value = nil;
        switch (dataType) {
            case CCModelPropertyDataTypeInt:
                value = @([stmt getInt32:i]);
                [model setValue:value forKey:propertyName];
                break;
            case CCModelPropertyDataTypeFloat:
                value = @([stmt getFloat:i]);
                [model setValue:value forKey:propertyName];
                break;
            case CCModelPropertyDataTypeBool:
                value = @([stmt getInt32:i]);
                [model setValue:value forKey:propertyName];
                break;
            case CCModelPropertyDataTypeLong:
                value = @([stmt getInt64:i]);
                [model setValue:value forKey:propertyName];
                break;
            case CCModelPropertyDataTypeString: {
                value = [stmt getString:i];
                [model setValue:value forKey:propertyName];
            }
                break;
            case CCModelPropertyDataTypeRaw: {
                [[model cc_dbRawData] setNonNullValue:[stmt getString:i] forKeyPath:arrayDBPropertyList[i]];
            }
            default:
                break;
        }
        if (i == 0 && value) {
            id memoryObj = [[CCModelCacheManager sharedInstance] modelWithPrimaryKey:value className:className];
            if (memoryObj) {
                return memoryObj;
            } else {
                [[CCModelCacheManager sharedInstance] addModelToCache:model primaryKey:value className:className];
            }
        }
    }
    return model;
}

+ (instancetype)initWithStatement:(CCDBStatement*)stmt  {

    NSString *className = NSStringFromClass([self class]);
    
    CCPropertyMapper *propertyMapper = [[CCModelMapperManager sharedInstance].dicPropertyMapper objectForKey:className];
    NSArray *arrayDBPropertyList = propertyMapper.arrayDBPropertyName;
    NSString *primaryPropertyName = propertyMapper.primaryKey;
        
    const char *dataTypeBitmap = [self cc_dataTypeBitmap].UTF8String;
    
    return [self createModelWithStatement:stmt arrayDBPropertyList:arrayDBPropertyList dataTypeBitmap:dataTypeBitmap primaryPropertyName:primaryPropertyName className:className];
}

- (void)initWithExecuteModel:(CCDBExecuteModel *)model {
    CCDBStatement *stmt = [CCDBConnection statementWithQuery:model.sql db:[NSThread currentThread].cc_dbInstance];
    [stmt bind:model.primaryKey withDataType:model.primaryKeyType  forIndex:1];
    if ([stmt step] == SQLITE_ROW) {
        model.res = [[self class] initWithStatement:stmt];
    }
    else {
        model.res = nil;
    }
    
    [stmt reset];
}

- (instancetype)initWithPrimaryProperty:(id)primaryProperty {
    if (!primaryProperty) {
        return nil;
    }
    NSString *className = NSStringFromClass([self class]);
    id model = [[CCModelCacheManager sharedInstance] modelWithPrimaryKey:primaryProperty className:className];
    if (model) {
        return model;
    }
    [[CCDBUpdateManager sharedInstance] waitInit];
    CCPropertyMapper *propertyMapper = [[CCModelMapperManager sharedInstance].dicPropertyMapper objectForKey:className];
    NSString *sql = @"SELECT ";
    NSArray *arrayPropertyList = propertyMapper.arrayDBPropertyName;
    for(int i = 0; i < arrayPropertyList.count; i++) {
        NSString *name = [arrayPropertyList objectAtIndex:i];
        sql = (i == 0)
        ?[NSString stringWithFormat:@"%@%@",sql,name]
        :[NSString stringWithFormat:@"%@, %@",sql,name];
    }
    sql = [NSString stringWithFormat:@"%@ FROM %@ WHERE %@ = ?",sql,className,propertyMapper.primaryKey];

    CCDBExecuteModel *executeModel = [[CCDBExecuteModel alloc] init];
    executeModel.primaryKey = primaryProperty;
    executeModel.sql = sql;
    executeModel.primaryKeyType = (int)self.cc_dataTypeBitmap.UTF8String[0];
    [self performSelector:@selector(initWithExecuteModel:) onThread:[CCDBInstancePool getDBTransactionThread] withObject:executeModel waitUntilDone:YES];
    [[CCModelCacheManager sharedInstance] addModelToCache:self primaryKey:primaryProperty className:className];
    return executeModel.res;
}
+ (NSMutableArray *)loadDatasWithStatement:(CCDBStatement *)stmt className:(NSString *)className {
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    CCPropertyMapper *propertyMapper = [[CCModelMapperManager sharedInstance].dicPropertyMapper objectForKey:className];
    NSArray *arrayDBPropertyList = propertyMapper.arrayDBPropertyName;
    NSString *primaryPropertyName = propertyMapper.primaryKey;
    const char *dataTypeBitmap = [self cc_dataTypeBitmap].UTF8String;
    
    while ([stmt step] == SQLITE_ROW) {
        id model = [self createModelWithStatement:stmt arrayDBPropertyList:arrayDBPropertyList dataTypeBitmap:dataTypeBitmap primaryPropertyName:primaryPropertyName className:className];
        [data addObject:model];
    }
    return data;
}

+ (void)loadDatasWithExecuteModel:(CCDBExecuteModel *)model {
    CCDBStatement *stmt = [CCDBConnection statementWithQuery:model.sql db:[NSThread currentThread].cc_dbInstance];
    model.res = [self loadDatasWithStatement:stmt className:model.className];
    [stmt reset];
}

+ (NSMutableArray *)prepareForSyncDBLoad:(NSString *)className headerPartSql:(NSString *)headerPartSql condition:(CCModelCondition *)condition {
    [[CCDBUpdateManager sharedInstance] waitInit];
    NSInteger count = 0;
    __block NSInteger offset = 0;
    if (condition.limited > 0) {
        count = condition.limited;
    } else {
        count = [self countBy:condition];
    }
    if (condition.offset > 0) {
        offset = condition.offset;
    } else {
        offset = 0;
    }
    NSInteger limit = count / DB_INSTANCE_POOL_SIZE;
    limit = (limit == 0) ? 1 : limit;
    condition.ccLimited(limit);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    NSMutableDictionary *dicIndex = [[NSMutableDictionary alloc] init];
    dispatch_queue_t queryQueue = dispatch_queue_create("_queryQueue", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < DB_INSTANCE_POOL_SIZE; i++) {
        dispatch_async(queryQueue, ^{
            NSDate *date = [NSDate date];
            NSString *sql = [headerPartSql copy];
            CCModelCondition *subCondition = [condition copy];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (i == DB_INSTANCE_POOL_SIZE - 1) {
                subCondition.ccLimited(count);
            }
            subCondition.ccOffset(offset);
            offset += limit;
            dispatch_semaphore_signal(semaphore);
            if (subCondition.where) {
                sql = [sql stringByAppendingFormat:@" where %@", subCondition.sql()];
            } else {
                sql = [sql stringByAppendingFormat:@" %@", subCondition.sql()];
            }
            CCDBExecuteModel *resModel = [[CCDBExecuteModel alloc] init];
            resModel.className = className;
            resModel.sql = sql;
            NSThread *thread = [CCDBInstancePool getDBTransactionThread];
            [self performSelector:@selector(loadDatasWithExecuteModel:) onThread:thread withObject:resModel waitUntilDone:YES];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            [dicIndex setObject:resModel forKey:@(subCondition.offset)];
            dispatch_semaphore_signal(semaphore);
            NSLog(@"%f", [date timeIntervalSinceNow]);
        });
        
    }
    
    NSMutableArray *res = [[NSMutableArray alloc] init];
    dispatch_barrier_sync(queryQueue, ^{
        if (condition.offset > 0) {
            offset = condition.offset;
        } else {
            offset = 0;
        }
        for (int i = 0; i < DB_INSTANCE_POOL_SIZE; i++) {
            CCDBExecuteModel *resModel = [dicIndex objectForKey:@(offset)];
            [res addObjectsFromArray:resModel.res];
            offset += limit;
        }
    });
    
    return res;
}

+ (NSMutableArray *)loadAllDataWithAsc:(BOOL)isAsc {
    NSString *className = NSStringFromClass([self class]);
    CCModelCondition *condition = [[CCModelCondition alloc] init];
    NSString *headerPart = [self getSelectSqlHeaderPart:className joinTableName:nil];
    condition.ccOrderBy(@"rowid").ccIsAsc(isAsc);
    NSMutableArray *datas = [self prepareForSyncDBLoad:className headerPartSql:headerPart condition:condition];
    return [[NSMutableArray alloc] initWithArray:datas];
}

+ (NSMutableArray *)loadAllDataWithAsc:(BOOL)isAsc containerId:(long)containerId {
    NSString *className = NSStringFromClass([self class]);
    NSMutableArray *cacheDatas = [[CCModelCacheManager sharedInstance] modelsWithContainerId:containerId className:className isAsc:isAsc];
    if (cacheDatas.count > 0) {
        return [[NSMutableArray alloc] initWithArray:cacheDatas];
    }
    NSString *containerTableName = [NSString stringWithFormat:@"%@_index",className];
    NSString *headerPart = [self getSelectSqlHeaderPart:className joinTableName:containerTableName];
    CCPropertyMapper *propertyMapper = [[CCModelMapperManager sharedInstance].dicPropertyMapper objectForKey:className];
    NSString *primaryKey = propertyMapper.primaryKey;
    
    CCModelCondition *condition = [[CCModelCondition alloc] init];
    condition.ccWhere([NSString stringWithFormat:@"%@.%@ = i.primary_key and i.hash_id = %ld", className, primaryKey, containerId])
    .ccContainerId(containerId)
    .ccOrderBy(@"i.update_time")
    .ccIsAsc(isAsc);
    NSMutableArray *datas = [self prepareForSyncDBLoad:className headerPartSql:headerPart condition:condition];
    [[CCModelCacheManager sharedInstance] setModelsToCache:datas containerId:containerId className:className isAsc:isAsc];
    return [[NSMutableArray alloc] initWithArray:datas];
}

+ (NSMutableArray *)loadDataWithCondition:(CCModelCondition *)condition {
    NSString *className = NSStringFromClass([self class]);
    NSString *containerTableName = [NSString stringWithFormat:@"%@_index",className];
    NSString *sql = [self getSelectSqlHeaderPart:className joinTableName:containerTableName];
    CCPropertyMapper *propertyMapper = [[CCModelMapperManager sharedInstance].dicPropertyMapper objectForKey:className];
    
    NSString *primaryKey = propertyMapper.primaryKey;
    if (condition.containerId != NOContainerId) {
        NSString *where = condition.where;
        condition.ccWhere([NSString stringWithFormat:@"%@ and i.hash_id = %ld and %@.%@ = i.primary_key", where, condition.containerId, className, primaryKey]);
    }
    NSMutableArray *datas = [self prepareForSyncDBLoad:className headerPartSql:sql condition:condition];
    return datas;
}

- (void)insertIntoMMAPCache:(id)value type:(CCModelPropertyDataType)type mmapIndex:(NSInteger)mmapIndex propertyName:(NSString *)propertyName {
    if (!value) {
        ccdb_insertMMAPCacheWithNull(propertyName, mmapIndex);
        return;
    }
    switch (type) {
        case CCModelPropertyDataTypeInt:
            ccdb_insertMMAPCacheWithInt([value integerValue], propertyName, mmapIndex);
            break;
        case CCModelPropertyDataTypeFloat:
            ccdb_insertMMAPCacheWithDouble([value doubleValue], propertyName, mmapIndex);
            break;
        case CCModelPropertyDataTypeLong:
            ccdb_insertMMAPCacheWithInt([value integerValue], propertyName, mmapIndex);
            break;
        case CCModelPropertyDataTypeBool:
            ccdb_insertMMAPCacheWithBool([value boolValue], propertyName, mmapIndex);
            break;
        default:
            ccdb_insertMMAPCacheWithString(value, propertyName, mmapIndex);
            break;
    }
}

- (void)replaceIntoDB {
    NSString *className = NSStringFromClass([self class]);
    CCPropertyMapper *propertyMapper = [[CCModelMapperManager sharedInstance].dicPropertyMapper objectForKey:className];
    
    NSArray *arrayDBPropertyList = propertyMapper.arrayDBPropertyName;
    
    ccdb_beginMMAPCacheTransaction(propertyMapper.mmapIndex, CCDBMMAPTransactionTypeUpdate);
    
    NSMutableDictionary *customDic = [self customJSONDictionary];
    int j = 0;
    const char *dataTypeBitmap = self.cc_dataTypeBitmap.UTF8String;
    const char *propertyTypeBitmap = self.cc_propertyTypeBitmap.UTF8String;
    for(int i = 0; i < arrayDBPropertyList.count; i++) {
        NSString *name = [arrayDBPropertyList objectAtIndex:i];
        j++;
        if ((int)propertyTypeBitmap[i] != CCModelPropertyTypeDefault) {
            if (![self valueForKey:name]) {
                [self extractDataWithProperty:name type:(int)propertyTypeBitmap[i]];
            }
            switch ((int)propertyTypeBitmap[i]) {
                case CCModelPropertyTypeJSON:
                    ccdb_insertMMAPCacheWithString([[self valueForKey:name] JSONString], name, propertyMapper.mmapIndex);
                    break;
                case CCModelPropertyTypeSavingProtocol: {
                    id object = [self valueForKey:name];
                    if ([object respondsToSelector:@selector(cc_JSONDictionary)]) {
                        ccdb_insertMMAPCacheWithString([[object cc_JSONDictionary] JSONString], name, propertyMapper.mmapIndex);
                    } else {
                        ccdb_insertMMAPCacheWithString([[object defaultJSONDictionaryIMP] JSONString], name, propertyMapper.mmapIndex);
                    }
                }
                    break;
                case CCModelPropertyTypeCustom: {
                    id object = [customDic objectForKey:name];
                    if (object) {
                        ccdb_insertMMAPCacheWithString([object JSONString], name, propertyMapper.mmapIndex);
                    }
                }
                    break;
                case CCModelPropertyTypeModel: {
                    CCModel *model = [self valueForKey:name];
                    if (model) {
                        CCPropertyMapper *subModelMapper = [[CCModelMapperManager sharedInstance].dicPropertyMapper objectForKey:NSStringFromClass([model class])];
                        NSString *primaryKey = subModelMapper.primaryKey;
                        id data = [model valueForKey: primaryKey];
                        const char *subDataTypeBitmap = self.cc_dataTypeBitmap.UTF8String;
                        [self insertIntoMMAPCache:data type:subDataTypeBitmap[0] mmapIndex:propertyMapper.mmapIndex propertyName:name];
                    }
                }
                    break;
                default:
                    break;
            }
        } else {
            [self insertIntoMMAPCache:[self valueForKey:name] type:dataTypeBitmap[i] mmapIndex:propertyMapper.mmapIndex propertyName:name];
        }
    }
    
    ccdb_commitMMAPCacheTransaction(propertyMapper.mmapIndex);
    
    [[CCModelCacheManager sharedInstance] addModelToCache:self primaryKey:[self valueForKey:propertyMapper.primaryKey] className:className];
}

- (void)replaceIntoDBWithContainerId:(NSInteger)containerId top:(BOOL)top {
    if(containerId != NOContainerId) {
        NSString *className = NSStringFromClass([self class]);
        [[CCModelCacheManager sharedInstance] addModelToContainerCache:self className:className containerId:containerId top:top];
    }
    
    [self replaceIntoDB];
    
    NSString *className = NSStringFromClass([self class]);
    CCPropertyMapper *propertyMapper = [[CCModelMapperManager sharedInstance].dicPropertyMapper objectForKey:className];
    id primaryValue = [self valueForKey:propertyMapper.primaryKey];
    ccdb_beginMMAPCacheTransaction(propertyMapper.mmapIndex, CCDBMMAPTransactionTypeContainerUpdate);
    ccdb_insertMMAPCacheWithString([NSString stringWithFormat:@"%ld-%@",containerId, primaryValue], @"id", propertyMapper.mmapIndex);
    ccdb_insertMMAPCacheWithInt(containerId, @"hash_id", propertyMapper.mmapIndex);
    [self insertIntoMMAPCache:primaryValue type:(int)(self.cc_dataTypeBitmap.UTF8String[0]) mmapIndex:propertyMapper.mmapIndex propertyName:@"primary_key"];
    if (top) {
        ccdb_insertMMAPCacheWithDouble(-[NSDate date].timeIntervalSince1970, @"update_time", propertyMapper.mmapIndex);
    } else {
        ccdb_insertMMAPCacheWithDouble([NSDate date].timeIntervalSince1970, @"update_time", propertyMapper.mmapIndex);
    }
    ccdb_commitMMAPCacheTransaction(propertyMapper.mmapIndex);
}

- (void)executeWithSql:(NSString *)sql {
    CCDBStatement *stmt = [CCDBConnection statementWithQuery:sql db:[NSThread currentThread].cc_dbInstance];
    [stmt step];
    [stmt reset];
}

+ (void)createIndexForProperty:(NSString *)propertyName {
    NSString *className = NSStringFromClass([self class]);
    NSString *sql = [NSString stringWithFormat:@"CREATE INDEX %@_%@_index ON %@ (%@)", propertyName, className, className, propertyName];
    [self performSelector:@selector(executeWithSql:) onThread:[CCDBInstancePool getDBTransactionThread] withObject:sql waitUntilDone:NO];
}

+ (void)removeIndexForProperty:(NSString *)propertyName {
    NSString *className = NSStringFromClass([self class]);
    NSString *sql = [NSString stringWithFormat:@"Drop INDEX %@_%@_index", propertyName, className];
    [self performSelector:@selector(executeWithSql:) onThread:[CCDBInstancePool getDBTransactionThread] withObject:sql waitUntilDone:NO];
}

- (void)removeFromDBWithExecuteModel:(CCDBExecuteModel *)model {
    CCDBStatement *stmt = [CCDBStatement statementWithDB:[NSThread currentThread].cc_dbInstance query:model.sql.UTF8String];
    if (model.containerId != NOContainerId) {
        [stmt bindInt64:model.containerId forIndex:1];
        [stmt bind:model.primaryKey withDataType:model.primaryKeyType forIndex:2];
    } else {
        [stmt bind:model.primaryKey withDataType:model.primaryKeyType forIndex:1];
    }
    [stmt step]; // ignore error
    [stmt reset];
}

- (void)removeFromDB {
    NSString *className = NSStringFromClass([self class]);
    CCPropertyMapper *propertyMapper = [[CCModelMapperManager sharedInstance].dicPropertyMapper objectForKey:className];
    NSString *primaryKey = propertyMapper.primaryKey;
    id primaryValue = [self valueForKey:primaryKey];
    CCModelPropertyDataType type = (int)self.cc_dataTypeBitmap.UTF8String[0];
    
    ccdb_beginMMAPCacheTransaction(propertyMapper.mmapIndex, CCDBMMAPTransactionTypeDelete);
    [self insertIntoMMAPCache:primaryValue type:type mmapIndex:propertyMapper.mmapIndex propertyName:primaryKey];
    ccdb_commitMMAPCacheTransaction(propertyMapper.mmapIndex);
    
    ccdb_beginMMAPCacheTransaction(propertyMapper.mmapIndex, CCDBMMAPTransactionTypeDeleteObjectFromContainer);
    [self insertIntoMMAPCache:primaryValue type:type mmapIndex:propertyMapper.mmapIndex propertyName:@"primary_key"];
    ccdb_commitMMAPCacheTransaction(propertyMapper.mmapIndex);
}

- (void)removeFromContainer:(long)containerId {
    NSString *className = NSStringFromClass([self class]);
    NSString *containerTableName = [NSString stringWithFormat:@"%@_index",className];
    CCPropertyMapper *propertyMapper = [[CCModelMapperManager sharedInstance].dicPropertyMapper objectForKey:className];
    NSString *primaryKey = propertyMapper.primaryKey;
    id primaryValue = [self valueForKey:primaryKey];
    CCModelPropertyDataType type = (int)self.cc_dataTypeBitmap.UTF8String[0];
    
    ccdb_beginMMAPCacheTransaction(propertyMapper.mmapIndex, CCDBMMAPTransactionTypeContainerDelete);
    ccdb_insertMMAPCacheWithInt(containerId, @"hash_id", propertyMapper.mmapIndex);
    [self insertIntoMMAPCache:primaryValue type:type mmapIndex:propertyMapper.mmapIndex propertyName:@"primary_key"];
    ccdb_commitMMAPCacheTransaction(propertyMapper.mmapIndex);
    
}

+ (void)removeAll {
    NSString *className = NSStringFromClass([self class]);
    CCPropertyMapper *propertyMapper = [[CCModelMapperManager sharedInstance].dicPropertyMapper objectForKey:className];

    ccdb_beginMMAPCacheTransaction(propertyMapper.mmapIndex, CCDBMMAPTransactionTypeDeleteAll);
    ccdb_commitMMAPCacheTransaction(propertyMapper.mmapIndex);
    
    ccdb_beginMMAPCacheTransaction(propertyMapper.mmapIndex, CCDBMMAPTransactionTypeDeleteAllObjectFromContainer);
    ccdb_commitMMAPCacheTransaction(propertyMapper.mmapIndex);
}

+ (void)removeAllWithContainerId:(long)containerId {
    NSString *className = NSStringFromClass([self class]);
    CCPropertyMapper *propertyMapper = [[CCModelMapperManager sharedInstance].dicPropertyMapper objectForKey:className];

    ccdb_beginMMAPCacheTransaction(propertyMapper.mmapIndex, CCDBMMAPTransactionTypeContainerDeleteAll);
    ccdb_insertMMAPCacheWithInt(containerId, @"hash_id", propertyMapper.mmapIndex);
    ccdb_commitMMAPCacheTransaction(propertyMapper.mmapIndex);
}

+ (void)loadCountWithExecuteModel:(CCDBExecuteModel *)model {
    CCDBStatement *stmt = [CCDBConnection statementWithQuery:model.sql db:[NSThread currentThread].cc_dbInstance];
    NSInteger count = 0;
    while ([stmt step] == SQLITE_ROW) {
        count = [stmt getInt64:0];
    }
    model.res = @(count);
    [stmt reset];
}

+ (NSInteger)count {
    NSString *className = NSStringFromClass([self class]);
    NSString *sql = [[NSString alloc] initWithFormat:@"select count(*) from %@", className];
    CCDBExecuteModel *model = [[CCDBExecuteModel alloc] init];
    model.sql = sql;
    [self performSelector:@selector(loadCountWithExecuteModel:) onThread:[CCDBInstancePool getDBTransactionThread] withObject:model waitUntilDone:YES];
    return [model.res integerValue];
}

+ (NSInteger)countBy:(CCModelCondition *)condition {
    NSString *className = NSStringFromClass([self class]);
    CCPropertyMapper *propertyMapper = [[CCModelMapperManager sharedInstance].dicPropertyMapper objectForKey:className];
    NSString *propertyName = propertyMapper.primaryKey;
    NSString *sql = [[NSString alloc] initWithFormat:@"select count(*) from %@ ", className];
    if (condition.containerId != NOContainerId) {
        sql = [NSString stringWithFormat:@"%@, %@_index as i where %@.%@ = i.primary_key and i.hash_id = %ld", sql, className, className, propertyName, condition.containerId];
        if (!condition.where) {
            sql = [[NSString alloc] initWithFormat:@"%@ %@", sql, condition.innerSql()];
        } else {
            sql = [NSString stringWithFormat:@"%@ and %@",sql, condition.innerSql()];
        }
    } else {
        if (!condition.where) {
            sql = [[NSString alloc] initWithFormat:@"%@ %@", sql, condition.innerSql()];
        } else {
            sql = [NSString stringWithFormat:@"%@ where %@",sql, condition.innerSql()];
        }
    }
    
    CCDBExecuteModel *model = [[CCDBExecuteModel alloc] init];
    model.sql = sql;
    [self performSelector:@selector(loadCountWithExecuteModel:) onThread:[CCDBInstancePool getDBTransactionThread] withObject:model waitUntilDone:YES];
    return [model.res integerValue];
}

+ (NSInteger)sumProperty:(NSString *)propertyName {
    NSString *className = NSStringFromClass([self class]);
    NSString *sql = [[NSString alloc] initWithFormat:@"select sum(%@) from %@",propertyName, className];
    CCDBExecuteModel *model = [[CCDBExecuteModel alloc] init];
    model.sql = sql;
    [self performSelector:@selector(loadCountWithExecuteModel:) onThread:[CCDBInstancePool getDBTransactionThread] withObject:model waitUntilDone:YES];
    return [model.res integerValue];
}


@end
