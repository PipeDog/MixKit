//
//  MKSocketContext.h
//  MoonBridge
//
//  Created by liang on 2021/6/23.
//

#import <Foundation/Foundation.h>
#import "MKWebSocket.h"
#import "MKSocketEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKSocketContext : NSObject <MKSocketEngine>

@property (class, strong, readonly) MKSocketContext *globalContext;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (void)setWebSocket:(id<MKWebSocket>)webSocket;

@end

NS_ASSUME_NONNULL_END
