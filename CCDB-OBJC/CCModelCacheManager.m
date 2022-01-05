//
//  CCModelCacheManager.m
//  CCModelDemo
//
//  Created by cmw on 2021/7/2.
//

#import "CCModelCacheManager.h"
#import "CCDBMarco.h"
#import "CCDBLock.h"
@interface CCModelCacheManager ()

@property (nonatomic, strong) NSMutableDictionary *modelCache;
@property (nonatomic, strong) NSMutableDictionary *containerCache;


@end

@implementation CCModelCacheManager

static CCModelCacheManager *s_instance;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[CCModelCacheManager alloc] init];
    });
    
    return s_instance;
}

- (NSMutableDictionary *)modelCache {
    if (!_modelCache) {
        _modelCache = [[NSMutableDictionary alloc] init];
    }
    return _modelCache;
}

- (NSMutableDictionary *)containerCache {
    if (!_containerCache) {
        _containerCache = [[NSMutableDictionary alloc] init];
    }
    return _containerCache;
}

- (instancetype)modelWithPrimaryKey:(id)primaryKey className:(NSString *)className {
    if (!className || !primaryKey) {
        return nil;
    }
    ccdb_readLock();
    NSDictionary *dic = [self.modelCache objectForKey:className];
    id res = [dic objectForKey:primaryKey];
    ccdb_unlock();
    return res;
}

- (void)addModelToCache:(id)model primaryKey:(id)primaryKey className:(NSString *)className {
    if (!className || !model || !primaryKey) {
        return;
    }
    ccdb_writeLock();
    if (![self.modelCache objectForKey:className]) {
        [self.modelCache setObject:[[NSMutableDictionary alloc] init] forKey:className];
    }
    [(NSMutableDictionary *)[self.modelCache objectForKey:className] setObject:model forKey:primaryKey];
    ccdb_unlock();
}

- (void)removeModelWithPrimaryKey:(id)primaryKey className:(NSString *)className {
    ccdb_writeLock();
    if ([self.modelCache objectForKey:className]) {
        [(NSMutableDictionary *)[self.modelCache objectForKey:className] removeObjectForKey:primaryKey];
    }
    ccdb_unlock();
}

- (void)setModelsToCache:(NSMutableArray *)models containerId:(NSInteger)containerId className:(NSString *)className isAsc:(BOOL)isAsc {
    if (!className || containerId == NOContainerId || !models.count) {
        return;
    }
    ccdb_writeLock();
    if (![self.containerCache objectForKey:className]) {
        [self.containerCache setObject:[[NSMutableDictionary alloc] init] forKey:className];
    }
    if (!isAsc) {
        NSMutableArray *waitAddModels = [[NSMutableArray alloc] initWithArray:models.reverseObjectEnumerator.allObjects];
        [(NSMutableDictionary *)[self.containerCache objectForKey:className] setObject:waitAddModels forKey:@(containerId)];
    } else {
        [(NSMutableDictionary *)[self.containerCache objectForKey:className] setObject:models forKey:@(containerId)];
    }
    ccdb_unlock();
}

- (NSMutableArray *)modelsWithContainerId:(NSInteger)containerId className:(NSString *)className isAsc:(BOOL)isAsc {
    if (!className || containerId == NOContainerId) {
        return nil;
    }
    if (isAsc) {
        ccdb_readLock();
        id res = [(NSDictionary *)[self.containerCache objectForKey:className] objectForKey:@(containerId)];
        ccdb_unlock();
        return res;
    } else {
        ccdb_readLock();
        NSMutableArray *array = [(NSDictionary *)[self.containerCache objectForKey:className] objectForKey:@(containerId)];
        id res = [[NSMutableArray alloc] initWithArray:array.reverseObjectEnumerator.allObjects];
        ccdb_unlock();
        return res;
    }
}

- (void)removeAllModelWithContainerId:(NSInteger)containerId className:(NSString *)className {
    if (!className || containerId == NOContainerId) {
        return;
    }
    ccdb_writeLock();
    [(NSMutableDictionary *)[self.containerCache objectForKey:className] removeObjectForKey:@(containerId)];
    ccdb_unlock();
}

- (void)removeModelWithPrimaryKey:(id)primaryKey className:(NSString *)className containerId:(NSInteger)containerId{
    if (!className || containerId == NOContainerId || !primaryKey) {
        return;
    }
    ccdb_writeLock();
    [(NSMutableArray *)[(NSMutableDictionary *)[self.containerCache objectForKey:className] objectForKey:@(containerId)] removeObject:primaryKey];
    ccdb_unlock();
}

- (void)addModelToContainerCache:(id)model className:(NSString *)className containerId:(NSInteger)containerId top:(BOOL)top {
    if (!className || !model || containerId == NOContainerId) {
        return;
    }
    ccdb_writeLock();
    if (![self.containerCache objectForKey:className]) {
        [self.containerCache setObject:[[NSMutableDictionary alloc] init] forKey:className];
    }
    NSMutableArray *containerDatas = [(NSDictionary *)[self.containerCache objectForKey:className] objectForKey:@(containerId)];
    if (!containerDatas) {
        containerDatas = [[NSMutableArray alloc] init];
        [(NSMutableDictionary *)[self.containerCache objectForKey:className] setObject:containerDatas forKey:@(containerId)];
    }
    [containerDatas removeObject:model];
    if (top) {
        [containerDatas insertObject:model atIndex:0];
    } else {
        [containerDatas addObject:model];
    }
    ccdb_unlock();
}

- (void)clearAllMemoryCache {
    ccdb_writeLock();
    [self.modelCache enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSMapTable  *_Nonnull obj, BOOL * _Nonnull stop) {
        [obj removeAllObjects];
    }];
    
    [self.containerCache enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSMutableDictionary  *_Nonnull obj, BOOL * _Nonnull stop) {
        [obj removeAllObjects];
    }];
    ccdb_unlock();
}

@end
