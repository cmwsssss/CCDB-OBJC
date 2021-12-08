//
//  CCDBInstancePool.m
//  CCModelDemo
//
//  Created by cmw on 2021/7/1.
//

#import "CCDBInstancePool.h"
#import "NSThread+CCDB.h"
@implementation CCDBInstancePool

static NSMutableArray <NSThread *>*s_DBTransactionThreads;
static sqlite3 *s_DBInstances[DB_INSTANCE_POOL_SIZE];
static NSInteger s_index = 0;

+ (NSThread *)createThread {
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(createRunloop) object:nil];
    [thread start];
    return thread;
}

+ (void)createRunloop {
    CFRunLoopSourceContext context = {0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
    CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    
    BOOL runAlways = YES;
    while (runAlways) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, DISPATCH_TIME_FOREVER, true);
    }
    
    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    CFRelease(source);
}

+ (void)addDBInstance:(sqlite3 *)instance index:(NSInteger)index {
    if (!s_DBTransactionThreads) {
        s_DBTransactionThreads = [[NSMutableArray alloc] init];
    }
    s_DBInstances[index] = instance;
    NSThread *thread = [self createThread];
    [thread setDbInstanceWithIndex:index];
    
    [s_DBTransactionThreads addObject:thread];
}

+ (NSThread *)getDBTransactionThread {
    NSInteger index = s_index % DB_INSTANCE_POOL_SIZE;
    s_index++;
    return s_DBTransactionThreads[index];
}

+ (NSThread *)getDBThreadWithIndex:(NSInteger)index {
    return s_DBTransactionThreads[index];
}

+ (sqlite3 *)getDBInstanceWithIndex:(NSInteger)index {
    return s_DBInstances[index];
}

@end
