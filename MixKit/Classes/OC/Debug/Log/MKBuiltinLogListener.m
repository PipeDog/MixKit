//
//  MKBuiltinLogListener.m
//  MixKit
//
//  Created by liang on 2021/6/7.
//

#import "MKBuiltinLogListener.h"
#import "MKDefines.h"

static inline NSString *MKLogGetFlag(MKLogLevel level) {
    switch (level) {
        case MKLogLevelDebug: return @"Debug";
        case MKLogLevelInfo: return @"Info";
        case MKLogLevelWarn: return @"Warn";
        case MKLogLevelError: return @"Error";
        case MKLogLevelFatal: return @"Fatal";
        default: return @"Unknown";
    }
}

@implementation MKBuiltinLogListener {
    NSDateFormatter *_dateFormatter;
}

+ (void)load {
    MKBuiltinLogListener *listener = [[MKBuiltinLogListener alloc] init];
    [[MKLogger defaultLogger] addListener:listener];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeZone = [NSTimeZone systemTimeZone];
        _dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm:ss.SSSZ";
    }
    return self;
}

- (void)logMessage:(NSString *)message
             level:(MKLogLevel)level
              file:(const char *)file
              func:(const char *)func
              line:(NSUInteger)line {
    NSString *filename = [NSString stringWithUTF8String:file].lastPathComponent;
    NSString *funcName = [NSString stringWithUTF8String:func];
    
    NSString *formattedLog = [NSString stringWithFormat:@"%@ [%@][%@|%@|%lu] %@",
                              [_dateFormatter stringFromDate:[NSDate date]],
                              MKLogGetFlag(level),
                              filename, funcName, (unsigned long)line,
                              message];

    switch (level) {
        case MKLogLevelDebug:
        case MKLogLevelInfo: {
            NSLog(@"%@", formattedLog);
        } break;
        case MKLogLevelWarn:
        case MKLogLevelError:
        case MKLogLevelFatal: {
            NSLog(@"%@", formattedLog);
            NSAssert(NO, formattedLog);
        } break;
    }
}

@end
