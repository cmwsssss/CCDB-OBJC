//
//  CCModelCacheManager.m
//  CCModelDemo
//
//  Created by cmw on 2021/7/2.
//

#import "CCModelCacheManager.h"
#import "CCDBMarco.h"
@interface CCModelCacheManager ()

@property (nonatomic, strong) NSMutableDictionary *modelCache;
@property (nonatomic, strong) NSMutableDictionary *containerCache;
@property (nonatomic, strong) dispatch_semaphore_t modelCacheSem;
@property (nonatomic, strong) dispatch_semaphore_t containerCacheSem;


@end

@implementation CCModelCacheManager

static CCModelCacheManager *s_instance;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[CCModelCacheManager alloc] init];
        s_instance.modelCacheSem = dispatch_semaphore_create(1);
        s_instance.containerCacheSem = dispatch_semaphore_create(1);
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
    
    dispatch_semaphore_wait(self.modelCacheSem, DISPATCH_TIME_FOREVER);
    NSDictionary *dic = [self.modelCache objectForKey:className];
    id res = [dic objectForKey:primaryKey];
    dispatch_semaphore_signal(self.modelCacheSem);
    return res;
}

- (void)addModelToCache:(id)model primaryKey:(id)primaryKey className:(NSString *)className {
    if (!className || !model || !primaryKey) {
        return;
    }
    dispatch_semaphore_wait(self.modelCacheSem, DISPATCH_TIME_FOREVER);
    if (![self.modelCache objectForKey:className]) {
        [self.modelCache setObject:[[NSMutableDictionary alloc] init] forKey:className];
    }
    [(NSMutableDictionary *)[self.modelCache objectForKey:className] setObject:model forKey:primaryKey];
    dispatch_semaphore_signal(self.modelCacheSem);
}

- (void)removeModelWithPrimaryKey:(id)primaryKey className:(NSString *)className {
    dispatch_semaphore_wait(self.modelCacheSem, DISPATCH_TIME_FOREVER);
    if ([self.modelCache objectForKey:className]) {
        [(NSMutableDictionary *)[self.modelCache objectForKey:className] removeObjectForKey:primaryKey];
    }
    dispatch_semaphore_signal(self.modelCacheSem);
}

- (void)setModelsToCache:(NSMutableArray *)models containerId:(NSInteger)containerId className:(NSString *)className isAsc:(BOOL)isAsc {
    if (!className || containerId == NOContainerId || !models.count) {
        return;
    }
    dispatch_semaphore_wait(self.containerCacheSem, DISPATCH_TIME_FOREVER);
    if (![self.containerCache objectForKey:className]) {
        [self.containerCache setObject:[[NSMutableDictionary alloc] init] forKey:className];
    }
    if (!isAsc) {
        NSMutableArray *waitAddModels = [[NSMutableArray alloc] initWithArray:models.reverseObjectEnumerator.allObjects];
        [(NSMutableDictionary *)[self.containerCache objectForKey:className] setObject:waitAddModels forKey:@(containerId)];
    } else {
        [(NSMutableDictionary *)[self.containerCache objectForKey:className] setObject:models forKey:@(containerId)];
    }
    dispatch_semaphore_signal(self.containerCacheSem);
}

- (NSMutableArray *)modelsWithContainerId:(NSInteger)containerId className:(NSString *)className isAsc:(BOOL)isAsc {
    if (!className || containerId == NOContainerId) {
        return nil;
    }
    if (isAsc) {
        dispatch_semaphore_wait(self.containerCacheSem, DISPATCH_TIME_FOREVER);
        id res = [(NSDictionary *)[self.containerCache objectForKey:className] objectForKey:@(containerId)];
        dispatch_semaphore_signal(self.containerCacheSem);
        return res;
    } else {
        dispatch_semaphore_wait(self.containerCacheSem, DISPATCH_TIME_FOREVER);
        NSMutableArray *array = [(NSDictionary *)[self.containerCache objectForKey:className] objectForKey:@(containerId)];
        id res = [[NSMutableArray alloc] initWithArray:array.reverseObjectEnumerator.allObjects];
        dispatch_semaphore_signal(self.containerCacheSem);
        return res;
    }
}

- (void)removeAllModelWithContainerId:(NSInteger)containerId className:(NSString *)className {
    if (!className || containerId == NOContainerId) {
        return;
    }
    dispatch_semaphore_wait(self.containerCacheSem, DISPATCH_TIME_FOREVER);
    [(NSMutableDictionary *)[self.containerCache objectForKey:className] removeObjectForKey:@(containerId)];
    dispatch_semaphore_signal(self.containerCacheSem);
}

- (void)removeModelWithPrimaryKey:(id)primaryKey className:(NSString *)className containerId:(NSInteger)containerId{
    if (!className || containerId == NOContainerId || !primaryKey) {
        return;
    }
    dispatch_semaphore_wait(self.containerCacheSem, DISPATCH_TIME_FOREVER);
    [(NSMutableArray *)[(NSMutableDictionary *)[self.containerCache objectForKey:className] objectForKey:@(containerId)] removeObject:primaryKey];
    dispatch_semaphore_signal(self.containerCacheSem);
}

- (void)addModelToContainerCache:(id)model className:(NSString *)className containerId:(NSInteger)containerId top:(BOOL)top {
    if (!className || !model || containerId == NOContainerId) {
        return;
    }
    dispatch_semaphore_wait(self.containerCacheSem, DISPATCH_TIME_FOREVER);
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
    dispatch_semaphore_signal(self.containerCacheSem);
}

- (void)clearAllMemoryCache {
    dispatch_semaphore_wait(self.modelCacheSem, DISPATCH_TIME_FOREVER);
    [self.modelCache enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSMapTable  *_Nonnull obj, BOOL * _Nonnull stop) {
        [obj removeAllObjects];
    }];
    dispatch_semaphore_signal(self.modelCacheSem);
    
    dispatch_semaphore_wait(self.containerCacheSem, DISPATCH_TIME_FOREVER);
    [self.containerCache enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSMutableDictionary  *_Nonnull obj, BOOL * _Nonnull stop) {
        [obj removeAllObjects];
    }];
    dispatch_semaphore_signal(self.containerCacheSem);
}

@end
