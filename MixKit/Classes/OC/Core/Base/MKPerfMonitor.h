//
//  MKPerfMonitor.h
//  MixKit
//
//  Created by liang on 2021/6/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const PERF_KEY_REGISTER_MODULE_DATA;
extern NSString *const PERF_KEY_CONVERT_DATA_TO_JSON;

@class MKPerfMonitor;

@protocol MKPerfMonitorDelegate <NSObject>

- (void)perfMonitor:(MKPerfMonitor *)perfMonitor flushAllPerfRecords:(NSArray<NSDictionary *> *)perfRecords;

@end

@interface MKPerfMonitor : NSObject

@property (class, strong, readonly) MKPerfMonitor *defaultMonitor;
@property (nonatomic, assign) BOOL autoFlush;
@property (nonatomic, assign) NSInteger autoFlushCount;

- (void)flush;

- (void)startPerf:(NSString *)key;
- (void)endPerf:(NSString *)key;

- (void)perfBlock:(void (^)(void))block forKey:(NSString *)key;

- (void)bind:(id<MKPerfMonitorDelegate>)delegate;
- (void)unbind:(id<MKPerfMonitorDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
