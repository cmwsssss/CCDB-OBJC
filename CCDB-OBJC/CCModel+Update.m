//
//  CCModel+Update.m
//  CCModelDemo
//
//  Created by cmw on 2021/7/5.
//

#import "CCModel+Update.h"
#import "CCModelMapperManager.h"
#import "CCDBConnection.h"
#import "CCModel+CustomProperty.h"
#import "NSObject+Bitmap.h"
#import "CCModel+ExtractData.h"
#import "NSObject+CC_JSON.h"
#import "CCDBStatement.h"
#import "CCDBSavingProtocol.h"
#import "NSObject+CCDBSavingProtocolImp.h"
#import <objc/message.h>
#import "CCModel+ExtractData.h"
#import "NSThread+CCDB.h"
@implementation CCModel (Update)

- (void)setCc_updateSql:(NSString *)cc_updateSql {
    objc_setAssociatedObject([self class], "cc_updateSql", cc_updateSql, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)cc_updateSql {
    return objc_getAssociatedObject([self class], "cc_updateSql");
}

- (void)db_replaceIntoDB {
    NSString *className = NSStringFromClass([self class]);
    CCPropertyMapper *propertyMapper = [[CCModelMapperManager sharedInstance].dicPropertyMapper objectForKey:className];
    NSArray *arrayPropertyDBList = propertyMapper.arrayDBPropertyName;
    NSString *sql = self.cc_updateSql;
    
    if (!sql) {

        sql = [NSString stringWithFormat:@"REPLACE INTO %@ ",className];
        
        NSString *key = @"(";
        NSString *value = @" VALUES(";
        
        BOOL hasPropertyToReplace = NO;
        
        for(int i = 0; i < arrayPropertyDBList.count; i++) {

            NSString *name = [arrayPropertyDBList objectAtIndex:i];

            hasPropertyToReplace = YES;

            key = ([key isEqualToString:@"("])
            ?[NSString stringWithFormat:@"%@%@",key,name]
            :[NSString stringWithFormat:@"%@,%@",key,name];

            value = ([value isEqualToString:@" VALUES("])
            ?[NSString stringWithFormat:@"%@?",value]
            :[NSString stringWithFormat:@"%@,?",value];

            if(i == arrayPropertyDBList.count-1) {
                key = [NSString stringWithFormat:@"%@)",key];
                value = [NSString stringWithFormat:@"%@)",value];
            }
        }
        sql = [NSString stringWithFormat:@"%@%@%@",sql,key,value];
        self.cc_updateSql = sql;
    }
    CCDBStatement *stmt = [CCDBConnection statementWithQuery:sql db:[NSThread currentThread].cc_dbInstance];
    NSMutableArray *replaceModels = [[NSMutableArray alloc] init];
    [self doBind:arrayPropertyDBList statement:stmt replaceModels:replaceModels];
    int state = [stmt step];
    if (state != SQLITE_DONE) {
    }
    [stmt reset];
    [replaceModels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj replaceIntoDB];
    }];
}

- (void)doBind:(NSArray *)arrayDBPropertyList statement:(CCDBStatement *)stmt replaceModels:(NSMutableArray *)replaceModels {
    
    NSString *className = NSStringFromClass([self class]);
    CCPropertyMapper *propertyMapper = [[CCModelMapperManager sharedInstance].dicPropertyMapper objectForKey:className];
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
                    [stmt bindString:[[self valueForKey:name] JSONString] forIndex:j];
                    break;
                case CCModelPropertyTypeSavingProtocol: {
                    id object = [self valueForKey:name];
                    if ([object respondsToSelector:@selector(cc_JSONDictionary)]) {
                        [stmt bindString:[[object cc_JSONDictionary] JSONString] forIndex:j];
                    } else {
                        [stmt bindString:[[object defaultJSONDictionaryIMP] JSONString] forIndex:j];
                    }
                }
                    break;
                case CCModelPropertyTypeCustom: {
                    id object = [customDic objectForKey:name];
                    if (object) {
                        [stmt bindString:[object JSONString] forIndex:j];
                    }
                }
                    break;
                case CCModelPropertyTypeModel: {
                    id model = [self valueForKey:name];
                    if (model) {
                        CCPropertyMapper *subModelMapper = [[CCModelMapperManager sharedInstance].dicPropertyMapper objectForKey:NSStringFromClass([model class])];
                        NSString *primaryKey = subModelMapper.primaryKey;
                        id data = [model valueForKey: primaryKey];
                        [stmt bind:data withDataType:(int)(dataTypeBitmap[0]) forIndex:j];
                        [replaceModels addObject:model];
                    }
                }
                    break;
                default:
                    break;
            }
        } else {
            NSInteger dataType = dataTypeBitmap[i];
            [stmt bind:[self valueForKey:name] withDataType:dataType forIndex:j];
        }
    }
}

- (void)db_replaceIntoDBWithContainerId:(long)containerId top:(BOOL)top {
    NSString *className = NSStringFromClass([self class]);
    NSString *containerTableName = [NSString stringWithFormat:@"%@_index",className];
    NSInteger timestamp = 0;
    if (top) {
        NSString *minUpdateTime = [NSString stringWithFormat:@"select min(update_time) from %@ where hash_id = %ld", containerTableName, containerId];
        CCDBStatement *queryStmt = [CCDBStatement statementWithDB:[NSThread currentThread].cc_dbInstance query:minUpdateTime.UTF8String];
        if ([queryStmt step] == SQLITE_ROW) {
            timestamp = [queryStmt getInt64:0];
            timestamp--;
        }
        [queryStmt reset];
        
    } else {
        NSDate *time = [NSDate date];
        timestamp = [time timeIntervalSince1970];
    }

    NSString *sql = [NSString stringWithFormat:@"REPLACE INTO %@ (id,hash_id,primarykey,update_time) VALUES(?,?,?,?)",containerTableName];
    
    CCDBStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [CCDBStatement statementWithDB:[NSThread currentThread].cc_dbInstance query:sql.UTF8String];
    }
    
    [stmt bindInt64:containerId forIndex:2];
    CCPropertyMapper *propertyMapper = [[CCModelMapperManager sharedInstance].dicPropertyMapper objectForKey:className];
    id primaryValue = [self valueForKey:propertyMapper.primaryKey];
    
    const char *dataTypeBitmap = self.cc_dataTypeBitmap.UTF8String;
    
    NSString *containerPrimaryKeyValue;
    
    switch ((CCModelPropertyDataType)dataTypeBitmap[0]) {
        case CCModelPropertyDataTypeInt:
            [stmt bindInt32:[primaryValue intValue] forIndex:3];
            containerPrimaryKeyValue = [NSString stringWithFormat:@"%d-%ld",[primaryValue intValue], containerId];
            break;
        case CCModelPropertyDataTypeFloat:
            [stmt bindFloat:[primaryValue floatValue] forIndex:3];
            containerPrimaryKeyValue = [NSString stringWithFormat:@"%f-%ld",[primaryValue floatValue], containerId];
            break;
        case CCModelPropertyDataTypeString:
            [stmt bindString:primaryValue forIndex:3];
            containerPrimaryKeyValue = [NSString stringWithFormat:@"%@-%ld",primaryValue, containerId];
            break;
        case CCModelPropertyDataTypeBool:
            [stmt bindInt32:[primaryValue intValue] forIndex:3];
            containerPrimaryKeyValue = [NSString stringWithFormat:@"%d-%ld",[primaryValue intValue], containerId];
            break;
        case CCModelPropertyDataTypeLong:
            [stmt bindInt64:[primaryValue integerValue] forIndex:3];
            containerPrimaryKeyValue = [NSString stringWithFormat:@"%d-%ld",[primaryValue intValue], containerId];
            break;
        default:
            break;
    }
    [stmt bindString:containerPrimaryKeyValue forIndex:1];
    [stmt bindInt64:timestamp forIndex:4];    
    if ([stmt step] != SQLITE_DONE) {
        
    }
    [stmt reset];
    
    [self db_replaceIntoDB];
}

@end
