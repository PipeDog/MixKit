//
//  MKLogger.h
//  MixKit
//
//  Created by liang on 2021/6/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MKLogLevel) {
    MKLogLevelDebug = 0,
    MKLogLevelInfo  = 1,
    MKLogLevelWarn  = 2,
    MKLogLevelError = 3,
    MKLogLevelFatal = 4,
};

@protocol MKLogListener <NSObject>

- (void)logMessage:(NSString *)message
             level:(MKLogLevel)level
              file:(const char *)file
              func:(const char *)func
              line:(NSUInteger)line;

@end

@interface MKLogger : NSObject

@property (class, strong, readonly) MKLogger *defaultLogger;

- (void)logWithLevel:(MKLogLevel)level
                file:(const char *)file
                func:(const char *)func
                line:(NSUInteger)line
              format:(NSString *)format, ...;

- (void)addListener:(id<MKLogListener>)listener;
- (void)removeListener:(id<MKLogListener>)listener;

@end

#define LOG_MACRO(level, ...) \
    [[MKLogger defaultLogger] logWithLevel:level file:__FILE__ func:__PRETTY_FUNCTION__ line:__LINE__ format:[NSString stringWithFormat:__VA_ARGS__]]

#define MKLogDebug(...)   LOG_MACRO(MKLogLevelDebug, __VA_ARGS__)
#define MKLogInfo(...)    LOG_MACRO(MKLogLevelInfo, __VA_ARGS__)
#define MKLogWarn(...)    LOG_MACRO(MKLogLevelWarn, __VA_ARGS__)
#define MKLogError(...)   LOG_MACRO(MKLogLevelError, __VA_ARGS__)
#define MKLogFatal(...)   LOG_MACRO(MKLogLevelFatal, __VA_ARGS__)

NS_ASSUME_NONNULL_END
