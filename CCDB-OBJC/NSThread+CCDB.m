//
//  NSThread+CCDB.m
//  CCModelDemo
//
//  Created by cmw on 2021/7/1.
//

#import "NSThread+CCDB.h"
#import "CCDBInstancePool.h"
#import <objc/message.h>
@implementation NSThread (CCDB)

- (NSMutableDictionary *)cc_statementsMap {
    NSMutableDictionary *dic = objc_getAssociatedObject(self, "cc_statementsMap");
    if(!dic) {
        dic = [[NSMutableDictionary alloc] init];
    }
    objc_setAssociatedObject(self, "cc_statementsMap", dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return dic;
}

- (void)setDbInstanceWithIndex:(NSInteger)index {
    objc_setAssociatedObject(self, "cc_db_instance_index", @(index), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setCc_dbInstance:(sqlite3 *)cc_dbInstance {
    
}

- (void)setCc_statementsMap:(NSMutableDictionary *)cc_statementsMap {
    
}

- (sqlite3 *)cc_dbInstance {
    return [CCDBInstancePool getDBInstanceWithIndex:[objc_getAssociatedObject(self, "cc_db_instance_index") integerValue]];
}

@end
