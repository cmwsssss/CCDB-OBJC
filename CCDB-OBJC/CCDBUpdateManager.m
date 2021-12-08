//
//  CCBackgroundDBManager.m
//  CCModelDemo
//
//  Created by cmw on 2021/7/5.
//

#import "CCDBUpdateManager.h"
#import <mach/mach.h>
#import <sys/time.h>
#import <sys/lock.h>
#import <malloc/malloc.h>
#import "CCDBInstancePool.h"
#import "CCModel.h"
#import "CCModel+Update.h"
#import "CCDBTranscationManager.h"
static NSTimer *s_cpuUsageTimer;
static CCDBUpdateManager *s_instance;
static NSRecursiveLock *s_dataLock;
static NSThread *s_replaceBackgroundThread;

@interface CCDBUpdateManager ()

@property (nonatomic, strong) NSMutableArray <CCModel *> *models;
@property (nonatomic, strong) NSDate *lastCheckCPUTime;
@property (nonatomic, strong) dispatch_group_t group;
@property (nonatomic, strong) NSDate *dateCount;
@property (nonatomic, strong) NSThread *executeThread;

@end

@implementation CCDBUpdateManager

- (NSMutableArray <CCModel *> *)models {
    if (!_models) {
        _models = [[NSMutableArray alloc] init];
    }
    
    return _models;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        s_instance = [[CCDBUpdateManager alloc] init];
        s_dataLock = [[NSRecursiveLock alloc] init];
        s_cpuUsageTimer = [NSTimer timerWithTimeInterval:0.5 target:s_instance selector:@selector(startReplace) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:s_cpuUsageTimer forMode:NSRunLoopCommonModes];
        
    });
    return s_instance;
}

- (void)startReplace {
    if (self.lastCheckCPUTime && [self.lastCheckCPUTime timeIntervalSinceNow] > -0.5) {
        return;
    } else {
        self.lastCheckCPUTime = [NSDate date];
    }
    float usage = cpu_usage();
    if (usage < 20) {
        if (self.models.count > 0) {
            [self performSelector:@selector(replaceIntoDB) onThread:[CCDBInstancePool getDBTransactionThread] withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)replaceIntoDB {
    @try {
        [s_dataLock lock];
//        self.dateCount = [NSDate date];
        [CCDBTranscationManager beginTransaction];
        [self.models enumerateObjectsUsingBlock:^(CCModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!malloc_zone_from_ptr((__bridge const void *)obj)) {
                //if find one dealloc object, should remove all object;
                *stop = YES;
                return;
            }
            if ([obj isKindOfClass:[CCModel class]]) {
                CCModel *model = obj;
                [model db_replaceIntoDB];
            } else {
                CCDBUpdateModel *model = obj;
                [model.object db_replaceIntoDBWithContainerId:model.containerId top:model.top];
            }
        }];
//        NSLog(@"replaceTime: %f, %ld", [self.dateCount timeIntervalSinceNow], self.models.count);
        [CCDBTranscationManager commitTransaction];
        [self.models removeAllObjects];
        [s_dataLock unlock];
        [self startReplace];
    } @catch (NSException *exception) {
        
    } @finally {
    
    }
   
}

float cpu_usage()
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

- (void)createRunloop {
    CFRunLoopSourceContext context = {0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
    CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    
    BOOL runAlways = YES;
    while (runAlways) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, DISPATCH_TIME_FOREVER, YES);
    }
    
    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    CFRelease(source);
}

- (NSThread *)executeThread {
    if (!_executeThread) {
        _executeThread = [[NSThread alloc] initWithTarget:self selector:@selector(createRunloop) object:nil];
        _executeThread.threadPriority = 0.1;
        [_executeThread start];
    }
    return _executeThread;
}

- (void)executeAddObject:(CCModel *)object {
    [s_dataLock lock];
    [self.models addObject:object];
    [s_dataLock unlock];
    [self startReplace];
}

- (void)addObject:(CCModel *)object {
    [self performSelector:@selector(executeAddObject:) onThread:self.executeThread withObject:object waitUntilDone:NO];
}

@end
