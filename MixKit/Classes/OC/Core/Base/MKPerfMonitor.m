//
//  MKPerfMonitor.m
//  MixKit
//
//  Created by liang on 2021/6/7.
//

#import <CoreFoundation/CoreFoundation.h>
#import "MKPerfMonitor.h"

NSString *const PERF_KEY_REGISTER_MODULE_DATA = @"PERF_KEY_REGISTER_MODULE_DATA";

#define Lock() [_lock lock]
#define Unlock() [_lock unlock]

@implementation MKPerfMonitor {
    NSLock *_lock;
    NSMutableDictionary *_perfDict;
    NSMutableArray *_perfQueue;
    NSHashTable *_delegates;
}

+ (MKPerfMonitor *)defaultMonitor {
    static MKPerfMonitor *__defaultMonitor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __defaultMonitor = [[self alloc] init];
    });
    return __defaultMonitor;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _autoFlush = YES;
        _autoFlushCount = 0;
        _lock = [[NSLock alloc] init];
        _perfDict = [NSMutableDictionary dictionary];
        _perfQueue = [NSMutableArray array];
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

#pragma mark - Public Methods
- (void)flush {
    Lock();
    NSArray *perfRecords = [_perfQueue copy];
    [_perfQueue removeAllObjects];
    Unlock();
    
    NSArray<id<MKPerfMonitorDelegate>> *allDelegates = _delegates.allObjects;
    for (id<MKPerfMonitorDelegate> delegate in allDelegates) {
        [delegate perfMonitor:self flushAllPerfRecords:perfRecords];
    }
}

- (void)startPerf:(NSString *)key {
    [self startPerf:key extra:nil];
}

- (void)endPerf:(NSString *)key {
    [self endPerf:key extra:nil];
}

- (void)startPerf:(NSString *)key extra:(NSDictionary *)extra {
    if (!key.length) { return; }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"startTime"] = @([NSDate date].timeIntervalSince1970 * 1000);
    dict[@"startExtra"] = extra;
    
    Lock();
    _perfDict[key] = dict;
    Unlock();
}

- (void)endPerf:(NSString *)key extra:(NSDictionary *)extra {
    if (!key.length) { return; }
    
    Lock();
    NSMutableDictionary *dict = _perfDict[key];
    Unlock();
    
    if (!dict) { return; }

    CFAbsoluteTime startTime = [dict[@"startTime"] doubleValue];
    CFAbsoluteTime endTime = [NSDate date].timeIntervalSince1970 * 1000;
    CFAbsoluteTime cost = endTime - startTime;
    
    dict[@"endTime"] = @(endTime);
    dict[@"cost"] = @(cost);
    dict[@"endExtra"] = extra;
    
    Lock();
    _perfDict[key] = nil;
    [_perfQueue addObject:@{key: dict}];
    
    BOOL shouldFlush = (self.autoFlush &&
                        _perfQueue.count >= self.autoFlushCount);
    Unlock();
    
    if (shouldFlush) {
        [self flush];
    }
}

- (void)perfBlock:(void (^)(void))block withKey:(NSString *)key {
    [self perfBlock:block withKey:key extra:nil];
}

- (void)perfBlock:(void (^)(void))block withKey:(NSString *)key extra:(NSDictionary *)extra {
    [self startPerf:key extra:extra];
    !block ?: block();
    [self endPerf:key];
}

- (void)bind:(id<MKPerfMonitorDelegate>)delegate {
    if ([delegate conformsToProtocol:@protocol(MKPerfMonitorDelegate)]) {
        [_delegates addObject:delegate];
    }
}

- (void)unbind:(id<MKPerfMonitorDelegate>)delegate {
    if ([_delegates containsObject:delegate]) {
        [_delegates removeObject:delegate];
    }
}

@end
