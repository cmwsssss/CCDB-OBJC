//
//  CCModelCondition.m
//  CCModelDemo
//
//  Created by cmw on 2021/7/1.
//

#import "CCModelCondition.h"

@interface CCModelCondition ()

@property (nonatomic, strong) id value;
@property (nonatomic, strong) NSMutableArray *arrayAnd;
@property (nonatomic, strong) NSMutableArray *arrayOr;
@property (nonatomic, copy) NSString *conditionType;
@property (nonatomic, strong) NSString *orderBy;
@property (nonatomic, assign) BOOL isAsc;
@property (nonatomic, assign) CCValueType valueType;

@end

@implementation CCModelCondition

- (instancetype)init {
    self = [super init];
    if(self) {
        self.arrayAnd = [[NSMutableArray alloc]init];
        self.arrayOr = [[NSMutableArray alloc]init];
        self.orderBy = @"rowid";
        _offset = -1;
    }
    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    CCModelCondition *object = [[CCModelCondition allocWithZone:zone] init];
    _arrayAnd = [self.arrayAnd mutableCopy];
    _arrayOr = [self.arrayOr mutableCopy];
    object.ccLimited(self.limited)
    .ccWhere(self.where)
    .ccOffset(self.offset)
    .ccOrderBy(self.orderBy)
//    .ccKey(self.key)
    .ccValue(self.value)
    .ccConditionType(self.conditionType)
    .ccIsAsc(self.isAsc)
    .ccContainerId(self.containerId);
    object.valueType = self.valueType;
    return object;
}

- (CCModelCondition *(^)(NSString *))ccKey {
    return ^CCModelCondition *(NSString *key) {
        self->_key = key;
        return self;
    };
}

- (CCModelCondition *(^)(NSString *))ccValue {
    return ^CCModelCondition *(NSString *value) {
        self->_value = value;
        self.valueType = CCValueTypeString;
        return self;
    };
}

- (CCModelCondition *(^)(NSString *))ccWhere {
    return ^CCModelCondition *(NSString *value) {
        self->_where = value;
        return self;
    };
}

- (CCModelCondition *(^)(NSString *))ccStringValue {
    return ^CCModelCondition *(NSString *value) {
        self->_value = value;
        self.valueType = CCValueTypeString;
        return self;
    };
}

- (CCModelCondition *(^)(NSNumber *))ccNumberValue {
    return ^CCModelCondition *(NSNumber *value) {
        self->_value = value;
        self.valueType = CCValueTypeNumber;
        return self;
    };
}

- (CCModelCondition *(^)(NSString *))ccRawValue {
    return ^CCModelCondition *(NSString *value) {
        self->_value = value;
        self.valueType = CCValueTypeRaw;
        return self;
    };
}

- (CCModelCondition *(^)(NSString *))ccOrderBy {
    return ^CCModelCondition *(NSString *value) {
        self->_orderBy = value;
        return self;
    };
}

- (CCModelCondition *(^)(NSInteger))ccLimited {
    return ^CCModelCondition *(NSInteger value) {
        self->_limited = value;
        return self;
    };
}

- (CCModelCondition *(^)(NSInteger))ccOffset {
    return ^CCModelCondition *(NSInteger value) {
        self->_offset = value;
        return self;
    };
}

- (CCModelCondition *(^)(BOOL))ccIsAsc {
    return ^CCModelCondition *(BOOL value) {
        self->_isAsc = value;
        return self;
    };
}

- (CCModelCondition *(^)(NSString *))ccConditionType {
    return ^CCModelCondition *(NSString *conditionType) {
        self->_conditionType = conditionType;
        return self;
    };
}

- (CCModelCondition *(^)(CCModelCondition *))and {
    return ^CCModelCondition *(CCModelCondition *condition) {
        [self.arrayAnd addObject:condition];
        return self;
    };
}

- (CCModelCondition *(^)(CCModelCondition *))or {
    return ^CCModelCondition *(CCModelCondition *condition) {
        [self.arrayOr addObject:condition];
        return self;
    };
}

- (CCModelCondition *(^)(NSInteger))ccContainerId {
    return ^CCModelCondition *(NSInteger value) {
        self->_containerId = value;
        return self;
    };
}

- (NSString *(^)(void))innerSql {
    return ^() {
        NSMutableString *string = [[NSMutableString alloc] init];
        if (self.where) {
            [string appendString:self.where];
        }
//        if (self.key) {
//            switch (self.valueType) {
//                case CCValueTypeString:
//                    [string appendFormat:@"%@ %@ \"%@\"",self.key, self.conditionType, self.value];
//                    break;
//                case CCValueTypeRaw:
//                    [string appendFormat:@"%@ %@ %@",self.key, self.conditionType, self.value];
//                    break;
//                case CCValueTypeNumber:
//                    [string appendFormat:@"%@ %@ %@",self.key, self.conditionType, [self.value stringValue]];
//                    break;
//                default:
//                    break;
//            }
//        }
//
//        for(int i = 0; i < self.arrayAnd.count; i++) {
//            if(i == 0) {
//                [string insertString:@"(" atIndex:0];
//                [string appendString:@" AND "];
//                [string appendString:@"("];
//            }
//            [string appendString:((CCModelCondition *)[self.arrayAnd objectAtIndex:i]).innerSql()];
//            if(i == self.arrayAnd.count - 1) {
//                [string appendString:@")"];
//            }
//        }
//
//        for(int i = 0; i < self.arrayOr.count; i++) {
//            if(i == 0) {
//                if (self.arrayAnd.count > 0) {
//                    [string insertString:@"(" atIndex:0];
//                    [string appendString:@")"];
//                }
//                [string appendString:@" OR "];
//                [string appendString:@"("];
//            }
//            [string appendString:((CCModelCondition *)[self.arrayOr objectAtIndex:i]).innerSql()];
//            if(i == self.arrayOr.count - 1) {
//                [string appendString:@")"];
//            }
//        }
//
        return string;
    };
}

- (NSString *(^)(void))sql {
    return ^() {
        NSMutableString *string = [[NSMutableString alloc]initWithString:self.innerSql()];
        NSString *orderBy = self.orderBy;
        if (self.isAsc) {
            [string appendFormat:@" ORDER BY %@ ASC",orderBy];
        } else {
            [string appendFormat:@" ORDER BY %@ DESC",orderBy];
        }

        if (self.limited > 0 && self.offset == -1) {
            [string appendFormat:@" LIMIT %ld", self.limited];
        } else if (self.limited > 0 && self.offset >= 0) {
            [string appendFormat:@" LIMIT %ld OFFSET %ld", self.limited, self.offset];
        } else if (self.offset >= 0) {
            [string appendFormat:@" LIMIT 1000 OFFSET %ld", self.offset];
        }
        return string;
    };
}

+ (CCModelCondition *)createConditionWithCCKey:(NSString *)key conditionType:(NSString *)type ccRawValue:(NSString *)faValue {
    CCModelCondition *con = [self createConditionWithCCKey:key conditionType:type ccValue:faValue];
    con.valueType = CCValueTypeRaw;
    return con;
}

+ (CCModelCondition *)createConditionWithCCKey:(NSString *)key conditionType:(NSString *)type ccNumberValue:(NSNumber *)faValue {
    CCModelCondition *con = [self createConditionWithCCKey:key conditionType:type ccValue:faValue];
    con.valueType = CCValueTypeNumber;
    return con;
}

+ (CCModelCondition *)createConditionWithCCKey:(NSString *)key conditionType:(NSString *)type ccStringValue:(NSString *)faValue {
    CCModelCondition *con = [self createConditionWithCCKey:key conditionType:type ccValue:faValue];
    con.valueType = CCValueTypeString;
    return con;
}

+ (CCModelCondition *)createConditionWithCCKey:(NSString *)key conditionType:(NSString *)type ccValue:(id)value {
    CCModelCondition *condition = [[CCModelCondition alloc] init];
    condition.ccKey(key).ccConditionType(type).ccValue(value);
    return condition;
}

@end
