//
//  MKWebViewExecutor.m
//  MixKit
//
//  Created by liang on 2020/12/26.
//  Copyright © 2020 liang. All rights reserved.
//

#import "MKWebViewExecutor.h"
#import "MKModuleManager.h"
#import "MKModuleMethod.h"
#import "MKBridgeModule.h"
#import "MKWebViewBridge.h"
#import "MKUtils.h"
#import "MKDataUtils.h"
#import "MKModuleMethod.h"
#import "MKBridgeModule.h"
#import "MKUtils.h"
#import "MKDataUtils.h"
#import "MKMethodInvoker.h"
#import "MKDefines.h"
#import "MKWebViewPerfConstant.h"

@interface MKWebViewExecutor ()

@property (nonatomic, weak) MKWebViewBridge *webViewBridge;

@end

@implementation MKWebViewExecutor

+ (void)registerBridge:(NSString *)bridgeName callbackFunction:(NSString *)funcName {
    if (!bridgeName.length || !funcName.length) {
        NSAssert(NO, @"Invalid argument `bridgeName` or `funcName`, bridgeName = %@, funcName = %@!",
                 bridgeName, funcName);
        return;
    }
    
    objc_setAssociatedObject([self class], @selector(jsCallbackModuleName), bridgeName, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject([self class], @selector(jsCallbackMethodName), funcName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self registerBridge:@"NativeModules" callbackFunction:@"invokeCallback"];
    });
}

- (instancetype)initWithBridge:(id<MKBridge>)bridge {
    self = [super initWithBridge:bridge];
    if (self) {
        _webViewBridge = (MKWebViewBridge *)bridge;
    }
    return self;
}

- (NSString *)jsCallbackModuleName {
    return objc_getAssociatedObject([self class], _cmd);
}

- (NSString *)jsCallbackMethodName {
    return objc_getAssociatedObject([self class], _cmd);
}

#pragma mark - MKExecutor
- (BOOL)invokeMethodOnCurrentQueue:(id)metaData {
    [[MKPerfMonitor defaultMonitor] startPerf:PERF_KEY_MATCH_MESSAGE_PARSER];
    id<MKMessageParserManager> manager = self.bridge.bridgeMessageParserManager;
    id<MKMessageParser> parser = [manager parserWithMetaData:metaData];
    [[MKPerfMonitor defaultMonitor] endPerf:PERF_KEY_MATCH_MESSAGE_PARSER];

    MKLogInfo(@"[JS] parser to : %@", parser);
    if (!parser) { return NO; }
    
    id<MKMessageBody> body = parser.messageBody;
    NSString *moduleName = body.moduleName;
    NSString *methodName = body.methodName;
        
    MKModuleManager *moduleManager = [MKModuleManager defaultManager];
    MKModuleMethod *method = [moduleManager methodWithModuleName:moduleName methodName:methodName];
    id<MKBridgeModule> bridgeModule = [self.bridge.bridgeModuleCreator moduleWithClass:method.cls];
    
    if (!bridgeModule) {
        MKLogError(@"Can not find match module, moduleName = [%@], js_name = [%@].",
                     moduleName, methodName);
        return NO;
    }
    
    NSArray *arguments = body.arguments;
    NSMutableArray *nativeArgs = [NSMutableArray array];
    
    [[MKPerfMonitor defaultMonitor] perfBlock:^{
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
    } withKey:PERF_KEY_CONVERT_NATIVE_ARGUMENTS];
    
    NSDictionary *extra = @{
        @"js_module": moduleName ?: @"",
        @"js_method": methodName ?: @"",
    };
    
    __block NSInvocation *invocation;
    [[MKPerfMonitor defaultMonitor] perfBlock:^{
        MKMethodInvoker *invoker = [moduleManager invokerWithModuleName:moduleName methodName:methodName];
        invocation = [invoker invokeWithModule:bridgeModule arguments:nativeArgs];
    } withKey:PERF_KEY_INVOKE_NATIVE_METHOD extra:extra];
    
    if (!invocation) {
        MKLogFatal(@"[Native] invoke method failed, module = %@, method = %@, arguments = %@",
                   method.cls, method.name, nativeArgs);
        return NO;
    }

    return YES;
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
        
        id<MKScriptEngine> scriptEngine = self.webViewBridge.bridgeDelegate.scriptEngine;
        NSString *module = [self jsCallbackModuleName];
        NSString *method = [self jsCallbackMethodName];
        NSArray *jsArgs = @[callbackID ?: @"", arguments ?: @[]];
        [[MKPerfMonitor defaultMonitor] startPerf:PERF_KEY_INVOKE_CALLBACK_FUNC];

        [scriptEngine invokeModule:module
                            method:method
                     withArguments:jsArgs
                       doneHandler:^(id  _Nullable result, NSError * _Nullable error) {
            [[MKPerfMonitor defaultMonitor] endPerf:PERF_KEY_INVOKE_CALLBACK_FUNC];
            if (error) {
                MKLogError(@"Invoke callback failed, result = [%@], error = [%@]!", result, error);
            }
        }];
    });
}

@end
