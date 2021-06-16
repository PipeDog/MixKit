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
#import "MKModuleMethod+Invoke.h"
#import "MKDefines.h"
#import "MKWebViewPerfConstant.h"
#import <objc/runtime.h>

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
    
    NSMutableString *format = [NSMutableString string];
    [format appendFormat:@"%@.%@", bridgeName, funcName];
    [format appendString:@"('%@', %@);"];
    objc_setAssociatedObject([self class], @selector(formattedCallbackScript), format, OBJC_ASSOCIATION_COPY_NONATOMIC);
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

- (NSString *)formattedCallbackScript {
    return objc_getAssociatedObject([self class], _cmd);
}

#pragma mark - MKExecutor
- (BOOL)callNativeMethod:(id)metaData {
    if (MKIsOnMainQueue()) {
        return [self _callNativeMethod:metaData];
    }
    
    __block BOOL ret = NO;
    dispatch_semaphore_t lock = dispatch_semaphore_create(0);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ret = [self _callNativeMethod:metaData];
        dispatch_semaphore_signal(lock);
    });
    
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    return ret;
}

#pragma mark - Tool Methods
- (BOOL)_callNativeMethod:(id)metaData {
    id<MKMessageParserManager> manager = self.bridge.bridgeMessageParserManager;
    
    [[MKPerfMonitor defaultMonitor] startPerf:PERF_KEY_MATCH_MESSAGE_PARSER];
    id<MKMessageParser> parser = [manager parserWithMetaData:metaData];
    [[MKPerfMonitor defaultMonitor] endPerf:PERF_KEY_MATCH_MESSAGE_PARSER];
    
    if (!parser) { return NO; }
    
    id<MKMessageBody> body = parser.messageBody;
    NSString *moduleName = body.moduleName;
    NSString *methodName = body.methodName;
        
    MKModuleManager *moduleManager = [MKModuleManager defaultManager];
    MKModuleMethod *method = [moduleManager methodWithModuleName:moduleName JSMethodName:methodName];
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
    } forKey:PERF_KEY_CONVERT_NATIVE_ARGUMENTS];
    
    @try {
        [[MKPerfMonitor defaultMonitor] startPerf:PERF_KEY_INVOKE_NATIVE_METHOD];
        [method mk_invokeWithModule:bridgeModule arguments:nativeArgs];
        [[MKPerfMonitor defaultMonitor] endPerf:PERF_KEY_INVOKE_NATIVE_METHOD];
    } @catch (NSException *exception) {
        NSAssert(NO, @"Call objc_msgSend fatal!");
    }
        
    return YES;
}

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
        
        [[MKPerfMonitor defaultMonitor] startPerf:PERF_KEY_FORMAT_CALLBACK_SCRIPT];
        NSString *format = [self formattedCallbackScript];
        NSString *JSONText = MKValueToJSONText(arguments);
        NSString *script = [NSString stringWithFormat:format, callbackID, JSONText];
        [[MKPerfMonitor defaultMonitor] endPerf:PERF_KEY_FORMAT_CALLBACK_SCRIPT];
                
        id<MKScriptEngine> scriptEngine = self.webViewBridge.bridgeDelegate.scriptEngine;
        [[MKPerfMonitor defaultMonitor] startPerf:PERF_KEY_INVOKE_CALLBACK_FUNC];
        
        [scriptEngine executeScript:script
                        doneHandler:^(id  _Nullable result, NSError * _Nullable error) {
            [[MKPerfMonitor defaultMonitor] endPerf:PERF_KEY_INVOKE_CALLBACK_FUNC];
            if (error) {
                MKLogError(@"Invoke callback failed, result = [%@], error = [%@]!", result, error);
            }
        }];
    });
}

@end
