//
//  CCDBStatement.m
//  CCModelDemo
//
//  Created by cmw on 2021/7/1.
//

#import "CCDBStatement.h"
#import <objc/message.h>
@interface CCDBStatement ()

@property (nonatomic, assign) sqlite3_stmt *stmt;

@end

@implementation CCDBStatement

static NSMutableDictionary *s_dicPropertyType;

- (instancetype)initWithDB:(sqlite3 *)db query:(const char *)sql
{
    self = [super init];
    if (sqlite3_prepare_v2(db, sql, -1, &(_stmt), NULL) != SQLITE_OK) {
        NSAssert2(0, @"Failed to prepare statement '%s' (%s)", sql, sqlite3_errmsg(db));
    }
    return self;
}

+ (instancetype)statementWithDB:(sqlite3 *)db query:(const char *)sql {
    if (!db) {
        return nil;
    }
    if (s_dicPropertyType) {
        s_dicPropertyType = [[NSMutableDictionary alloc] init];
    }
    return [[CCDBStatement alloc] initWithDB:db query:sql];
}

- (int)step
{
    int result = sqlite3_step(self.stmt);
    return result;
}

- (void)reset
{
    sqlite3_reset(self.stmt);
}

- (void)finish {
    sqlite3_finalize(self.stmt);
}

- (void)dealloc
{
    if (@available (iOS 10.0, *)){
        sqlite3_finalize(self.stmt);
    }
    
}

- (NSString *)getString:(int)index
{
    if (sqlite3_column_text(self.stmt, index) == nil) {
        return @"";
    }
    else {
        char *text = (char *)sqlite3_column_text(self.stmt, index);
        CFStringRef string = CFStringCreateWithCString(kCFAllocatorDefault, text, kCFStringEncodingUTF8);
        return (__bridge_transfer NSString *)(string);
    }
}

- (int)getInt32:(int)index
{
    return (int)sqlite3_column_int(self.stmt, index);
}

- (long)getInt64:(int)index
{
    return (long)sqlite3_column_int64(self.stmt, index);
}

- (float)getFloat:(int)index
{
    return sqlite3_column_double(self.stmt, index);
}

- (id)getWithProperty:(objc_property_t) property index:(int)index {
    NSString *types = [NSString stringWithUTF8String:property_getAttributes(property)];
    NSString *type = [types componentsSeparatedByString:@","].firstObject;
    
    if(!strcmp(type.UTF8String, "Ti") || !strcmp(type.UTF8String, "Tc")) {
        return [NSNumber numberWithInt:[self getInt32:index]];
    }
    else if(!strcmp(type.UTF8String, "Tf") || !strcmp(type.UTF8String, "Td")) {
        return [NSNumber numberWithFloat:[self getFloat:index]];
    } else if(!strcmp(type.UTF8String, "Tq") || !strcmp(type.UTF8String, "Tl")) {
        return [NSNumber numberWithLong:[self getInt64:index]];
    } else if(!strcmp(type.UTF8String, "TB")) {
        return [NSNumber numberWithBool:[self getInt32:index]];
    }
    else {
        NSString *result = [self getString:index];
        if (result.length == 0) {
            return nil;
        }
        return [self getString:index];
    }
    
}

- (NSData *)getData:(int)index
{
    int length = sqlite3_column_bytes(self.stmt, index);
    return [NSData dataWithBytes:sqlite3_column_blob(self.stmt, index) length:length];
}

- (void)bindString:(NSString*)value forIndex:(int)index
{
    if ([value isKindOfClass:[NSNumber class]]) {
        sqlite3_bind_int(self.stmt, index, [value integerValue]);
    } else {
        sqlite3_bind_text(self.stmt, index, [value UTF8String], -1, SQLITE_TRANSIENT);
    }
}

- (void)bindInt32:(int)value forIndex:(int)index
{
    sqlite3_bind_int(self.stmt, index, value);
}

- (void)bindInt64:(long)value forIndex:(int)index
{
    sqlite3_bind_int64(self.stmt, index, value);
}

- (void)bindDouble:(double)value forIndex:(int)index {
    sqlite3_bind_double(self.stmt, index, value);
}

- (void)bindFloat:(float)value forIndex:(int)index
{
    
    sqlite3_bind_double(self.stmt, index, value);
}

- (void)bindData:(NSData *)value forIndex:(int)index
{
    sqlite3_bind_blob(self.stmt, index, value.bytes, (int)value.length, SQLITE_TRANSIENT);
}

- (void)bind:(id)value withDataType:(CCModelPropertyDataType)subType forIndex:(int)index {
    switch (subType) {
        case CCModelPropertyDataTypeInt:
            [self bindInt32:[value intValue] forIndex:index];
            break;
        case CCModelPropertyDataTypeFloat:
            [self bindFloat:[value floatValue] forIndex:index];
            break;
        case CCModelPropertyDataTypeLong:
            [self bindInt64:[value integerValue] forIndex:index];
            break;
        case CCModelPropertyDataTypeBool:
            [self bindInt32:[value boolValue] forIndex:index];
            break;
        default:
            [self bindString:value forIndex:index];
            break;
    }
}

@end
