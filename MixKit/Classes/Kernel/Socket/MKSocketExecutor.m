//
//  MKSocketExecutor.m
//  MoonBridge
//
//  Created by liang on 2021/6/23.
//

#import "MKSocketExecutor.h"
#import "MKSocketBridge.h"
#import "MKLogger.h"
#import "MKPerfMonitor.h"
#import "MKUtils.h"
#import "MKMethodInvoker.h"
#import "MKModuleMethod.h"
#import "MKMessageParserManager.h"
#import "MKModuleManager.h"
#import "MKBridgeModule.h"
#import "MKSocketPerfConstant.h"

@interface MKSocketExecutor ()

@property (nonatomic, weak) MKSocketBridge *socketBridge;

@end

@implementation MKSocketExecutor

- (instancetype)initWithBridge:(id<MKBridge>)bridge {
    self = [super initWithBridge:bridge];
    if (self) {
        _socketBridge = (MKSocketBridge *)bridge;
    }
    return self;
}

#pragma mark - MBExecutor
- (BOOL)invokeMethodOnCurrentQueue:(id)metaData {        
    [[MKPerfMonitor defaultMonitor] startPerf:PERF_KEY_SOCKET_MATCH_MESSAGE_PARSER];
    id<MKMessageParserManager> manager = self.bridge.bridgeMessageParserManager;
    id<MKMessageParser> parser = [manager parserWithMetaData:metaData];
    [[MKPerfMonitor defaultMonitor] endPerf:PERF_KEY_SOCKET_MATCH_MESSAGE_PARSER];

    MKLogInfo(@"[Socket] parser to : %@", parser);
    if (!parser) { return NO; }
    
    id<MKMessageBody> body = parser.messageBody;
    NSString *moduleName = body.moduleName;
    NSString *methodName = body.methodName;
        
    MKModuleManager *moduleManager = [MKModuleManager defaultManager];
    MKModuleMethod *method = [moduleManager methodWithModuleName:moduleName methodName:methodName];
    id<MKBridgeModule> bridgeModule = [self.bridge.bridgeModuleCreator moduleWithClass:method.cls];
    
    if (!bridgeModule) {
        MKLogError(@"Can not find match module, moduleName = [%@], socket_func = [%@].",
                     moduleName, methodName);
        return NO;
    }
    
    NSArray *arguments = body.arguments;
    NSMutableArray *nativeArgs = [NSMutableArray array];
    
    for (id arg in arguments) {
        id nativeArg = arg;
        
        if ([arg isKindOfClass:[NSString class]]) {
            BOOL isCallbackID = [(NSString *)arg hasPrefix:@"_$_mk_callback_$_"];
            if (isCallbackID) {
                nativeArg = [self _makeCallbackWithCallbackID:(NSString *)arg];
            }
        }
        
        [nativeArgs addObject:nativeArg];
    }
    
    NSDictionary *extra = @{
        @"socket_module": moduleName ?: @"",
        @"socket_method": methodName ?: @"",
    };
    
    __block NSInvocation *invocation;
    [[MKPerfMonitor defaultMonitor] perfBlock:^{
        MKMethodInvoker *invoker = [moduleManager invokerWithModuleName:moduleName methodName:methodName];
        invocation = [invoker invokeWithModule:bridgeModule arguments:[nativeArgs copy]];
    } withKey:PERF_KEY_SOCKET_INVOKE_NATIVE_METHOD extra:extra];

    if (!invocation) {
        MKLogFatal(@"[Native] invoke method failed, module = %@, method = %@, arguments = %@",
                   method.cls, method.name, nativeArgs);
    }

    return invocation;
}

#pragma mark - Internal Methods
- (MKResponseCallback)_makeCallbackWithCallbackID:(NSString *)callbackID {
    @weakify(self)
    // Marked as autoreleasing, because NSInvocation doesn't retain arguments
    __autoreleasing MKResponseCallback callback = ^(NSArray *arguments) {
        @strongify(self)
        if (!self) { return; }
                
        [self _invokeCallbackWithArguments:arguments forCallbackID:callbackID];
    };
    return callback;
}

- (void)_invokeCallbackWithArguments:(NSArray *)arguments forCallbackID:(NSString *)callbackID {
    MKDispatchAsyncMainQueue(^{
        if (!callbackID.length) { return; }
        
        [[MKPerfMonitor defaultMonitor] perfBlock:^{
            id<MKSocketBridgeDelegate> socketBridgeDelegate = self.socketBridge.bridgeDelegate;
            id<MKSocketEngine> socketEngine = socketBridgeDelegate.socketEngine;
            
            NSDictionary *response = @{
                @"callbackID": callbackID ?: @"",
                @"arguments": arguments ?: @[],
            };

            NSError *error;
            BOOL ret = [socketEngine sendData:response error:&error];

            if (!ret || error) {
                MKLogError(@"[Socket] Send callback data by socket failed, error = %@", error);
                NSAssert(NO, @"[Socket] Send callback data by socket failed, error = %@", error);
            }
        } withKey:PERF_KEY_SOCKET_INVOKE_CALLBACK_FUNC];
    });
}

@end
