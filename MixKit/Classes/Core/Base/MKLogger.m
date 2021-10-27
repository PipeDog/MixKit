//
//  MKLogger.m
//  MixKit
//
//  Created by liang on 2021/6/4.
//

#import "MKLogger.h"

@implementation MKLogger {
    NSHashTable<id<MKLogListener>> *_listeners;
}

+ (MKLogger *)defaultLogger {
    static MKLogger *__defaultLogger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __defaultLogger = [[self alloc] init];
    });
    return __defaultLogger;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _listeners = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)logWithLevel:(MKLogLevel)level
                file:(const char *)file
                func:(const char *)func
                line:(NSUInteger)line
              format:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSArray<id<MKLogListener>> *listeners = _listeners.allObjects;
    for (id<MKLogListener> listener in listeners) {
        [listener logMessage:message level:level file:file func:func line:line];
    }
}

- (void)addListener:(id<MKLogListener>)listener {
    if ([listener respondsToSelector:@selector(logMessage:level:file:func:line:)]) {
        [_listeners addObject:listener];
    }
}

- (void)removeListener:(id<MKLogListener>)listener {
    if ([_listeners containsObject:listener]) {
        [_listeners removeObject:listener];
    }
}

@end
