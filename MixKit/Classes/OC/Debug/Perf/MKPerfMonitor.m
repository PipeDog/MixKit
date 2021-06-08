//
//  MKPerfMonitor.m
//  MixKit
//
//  Created by liang on 2021/6/7.
//

#import <CoreFoundation/CoreFoundation.h>
#import "MKPerfMonitor.h"

NSString *const PERF_KEY_REGISTER_MODULE_DATA = @"PERF_KEY_REGISTER_MODULE_DATA";
NSString *const PERF_KEY_MATCH_MESSAGE_PARSER = @"PERF_KEY_MATCH_MESSAGE_PARSER";
NSString *const PERF_KEY_INVOKE_CALLBACK_FUNC = @"PERF_KEY_INVOKE_CALLBACK_FUNC";
NSString *const PERF_KEY_INVOKE_NATIVE_METHOD = @"PERF_KEY_INVOKE_NATIVE_METHOD";

#define Lock() [_lock lock]
#define Unlock() [_lock unlock]

@implementation MKPerfMonitor {
    NSLock *_lock;
    NSMutableDictionary *_perfDict;
    NSMutableArray *_perfQueue;
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
        _lock = [[NSLock alloc] init];
        _perfDict = [NSMutableDictionary dictionary];
        _perfQueue = [NSMutableArray array];
        _autoFlush = YES;
        _autoFlushCount = 10;
    }
    return self;
}

#pragma mark - Public Methods
- (void)flush {
    Lock();
    NSArray *perfRecords = [_perfQueue copy];
    [_perfQueue removeAllObjects];
    Unlock();
    
    if ([self.delegate respondsToSelector:@selector(perfMonitor:flushAllPerfRecords:)]) {
        [self.delegate perfMonitor:self flushAllPerfRecords:perfRecords];
    }
}

- (void)startPerf:(NSString *)key {
    if (!key.length) { return; }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"startTime"] = @([NSDate date].timeIntervalSince1970 * 1000);
    
    Lock();
    _perfDict[key] = dict;
    Unlock();
}

- (void)endPerf:(NSString *)key {
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

- (void)perfKey:(NSString *)key block:(void (^)(void))block {
    [self startPerf:key];
    !block ?: block();
    [self endPerf:key];
}

@end
