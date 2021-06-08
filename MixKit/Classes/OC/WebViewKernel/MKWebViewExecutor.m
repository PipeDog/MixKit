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
#import <objc/runtime.h>

@interface MKWebViewExecutor ()

@property (nonatomic, weak) MKWebViewBridge *webViewBridge;

@end

@implementation MKWebViewExecutor

+ (void)registerBridge:(NSString *)bridgeName callbackFunction:(NSString *)funcName {
    if (!bridgeName.length || !funcName.length) {
        MKLogFatal(@"Invalid argument `bridgeName` or `funcName`, bridgeName = %@, funcName = %@!",
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

#pragma mark - Override Methods
- (MKResponseCallback)makeCallbackWithCallbackID:(NSString *)callbackID {
    if (!callbackID.length) { return nil; }
    
    __weak typeof(self) weakSelf = self;
    MKResponseCallback callback = ^(MKResponse response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        
        [strongSelf invokeCallbackWithResponse:response forCallbackID:callbackID];
    };
    return callback;
}

- (void)executeCallbackWithResponse:(MKResponse)response forCallbackID:(NSString *)callbackID {
    if (!callbackID.length) { return; }
    
    NSString *format = [self formattedCallbackScript];
    NSString *JSONText = MKValueToJSONText(response);
    NSString *script = [NSString stringWithFormat:format, callbackID, JSONText];
    
    id<MKScriptEngine> scriptEngine = self.webViewBridge.bridgeDelegate.scriptEngine;
    [[MKPerfMonitor defaultMonitor] startPerf:PERF_KEY_INVOKE_CALLBACK_FUNC];
    
    [scriptEngine executeScript:script
                    doneHandler:^(id  _Nullable result, NSError * _Nullable error) {
        [[MKPerfMonitor defaultMonitor] endPerf:PERF_KEY_INVOKE_CALLBACK_FUNC];
        if (error) {
            MKLogError(@"Invoke callback failed, result = [%@], error = [%@]!", result, error);
        }
    }];
}

@end
