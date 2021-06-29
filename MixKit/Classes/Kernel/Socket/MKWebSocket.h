//
//  MKWebSocket.h
//  MoonBridge
//
//  Created by liang on 2021/6/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKWebSocket;

@protocol MKWebSocketDelegate <NSObject>

- (void)webSocket:(id<MKWebSocket>)webSocket didReceiveMessage:(id)message;

@end

@protocol MKWebSocket <NSObject>

@property (nonatomic, weak) id<MKWebSocketDelegate> webSocketDelegate;

- (BOOL)sendData:(id)data error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
