//
//  MKSocketContext.m
//  MoonBridge
//
//  Created by liang on 2021/6/23.
//

#import "MKSocketContext.h"
#import "MKSocketBridge.h"
#import "MKDataUtils.h"
#import "MKLogger.h"

@interface MKSocketContext () <MKWebSocketDelegate, MKSocketBridgeDelegate>

@property (nonatomic, strong) id<MKWebSocket> webSocket;
@property (nonatomic, strong) MKSocketBridge *socketBridge;

@end

@implementation MKSocketContext

+ (MKSocketContext *)globalContext {
    static MKSocketContext *__globalContext;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __globalContext = [[self alloc] init];
    });
    return __globalContext;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _socketBridge = [[MKSocketBridge alloc] initWithBridgeDelegate:self];
    }
    return self;
}

#pragma mark - Public Methods
- (void)setWebSocket:(id<MKWebSocket>)webSocket {
    // Reset old webSocketDelegate to nil
    _webSocket.webSocketDelegate = nil;
    // Set new webSocket instance
    _webSocket = webSocket;
    _webSocket.webSocketDelegate = self;
}

#pragma mark - MKSocketEngine
- (BOOL)sendData:(id)data error:(NSError *__autoreleasing  _Nullable *)error {
    if (!data) {
        NSAssert(NO, @"Could not send nil data!");
        return NO;
    }
    
    return [_webSocket sendData:data error:error];
}

#pragma mark - MKWebSocketDelegate
- (void)webSocket:(id<MKWebSocket>)webSocket didReceiveMessage:(id)message {
    NSDictionary *dict = MKValueToJSONObject(message);
    if (!dict) { return; }
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        NSAssert(NO, @"Invalid message format, check it, message = %@!", message);
        return;
    }

    id<MKExecutor> executor = _socketBridge.bridgeExecutor;
    [executor invokeMethodOnMainQueue:dict];
}

#pragma mark - MKSocketBridgeDelegate
- (id<MKSocketEngine>)socketEngine {
    return self;
}

@end
