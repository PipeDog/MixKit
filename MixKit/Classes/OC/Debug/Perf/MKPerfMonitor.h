//
//  MKPerfMonitor.h
//  MixKit
//
//  Created by liang on 2021/6/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const PERF_KEY_REGISTER_MODULE_DATA;
extern NSString *const PERF_KEY_MATCH_MESSAGE_PARSER;
extern NSString *const PERF_KEY_INVOKE_CALLBACK_FUNC;
extern NSString *const PERF_KEY_INVOKE_NATIVE_METHOD;

@class MKPerfMonitor;

@protocol MKPerfMonitorDelegate <NSObject>

- (void)perfMonitor:(MKPerfMonitor *)perfMonitor flushAllPerfRecords:(NSArray<NSDictionary *> *)perfRecords;

@end

@interface MKPerfMonitor : NSObject

@property (class, strong, readonly) MKPerfMonitor *defaultMonitor;
@property (nonatomic, weak) id<MKPerfMonitorDelegate> delegate;
@property (nonatomic, assign) BOOL autoFlush;
@property (nonatomic, assign) NSInteger autoFlushCount;

- (void)flush;

- (void)startPerf:(NSString *)key;
- (void)endPerf:(NSString *)key;

- (void)perfKey:(NSString *)key block:(void (^)(void))block;

@end

NS_ASSUME_NONNULL_END
