//
//  MKExecutor.m
//  MixKit
//
//  Created by liang on 2020/12/29.
//  Copyright © 2020 liang. All rights reserved.
//

#import "MKExecutor.h"
#import "MKModuleManager.h"
#import "MKModuleMethod.h"
#import "MKBridgeModule.h"
#import "MKWebViewBridge.h"
#import "MKUtils.h"
#import "MKDataUtils.h"

@implementation MKExecutor

@synthesize bridge = _bridge;

- (instancetype)initWithBridge:(id<MKBridge>)bridge {
    self = [super init];
    if (self) {
        _bridge = bridge;
    }
    return self;
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

- (void)invokeCallbackWithResponse:(MKResponse)response forCallbackID:(NSString *)callbackID {
    MKDispatchAsyncMainQueue(^{
        [self executeCallbackWithResponse:response forCallbackID:callbackID];
    });
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
    NSString *callbackID = body.callbackID;
    NSDictionary *params = body.params;

    MKModuleManager *moduleManager = [MKModuleManager defaultManager];
    MKModuleMethod *method = [moduleManager methodWithModuleName:moduleName JSMethodName:methodName];
    
    id<MKBridgeModule> bridgeModule = [self.bridge.bridgeModuleCreator moduleWithClass:method.cls];
    if (!bridgeModule) {
        MKLogError(@"Can not find match module, moduleName = [%@], js_name = [%@].",
                     moduleName, methodName);
        return NO;
    }
    
    MKResponseCallback callback = [self makeCallbackWithCallbackID:callbackID];
    NSArray<NSString *> *argumentTypeEncodings = method.argumentTypeEncodings;
    NSInteger callbackIndex = [argumentTypeEncodings indexOfObject:@"@?"];
    
    @try {
        [[MKPerfMonitor defaultMonitor] startPerf:PERF_KEY_INVOKE_NATIVE_METHOD];
        
        if (argumentTypeEncodings.count == 3 && callbackIndex == 2) {
            // There is only one parameter and that parameter is of type "block"
            ((void (*) (id, SEL, MKResponseCallback)) objc_msgSend) (bridgeModule, method.sel, callback);
        } else {
            ((void (*) (id, SEL, NSDictionary *, MKResponseCallback)) objc_msgSend) (bridgeModule, method.sel, params, callback);
        }
        
        [[MKPerfMonitor defaultMonitor] endPerf:PERF_KEY_INVOKE_NATIVE_METHOD];
    } @catch (NSException *exception) {
        MKLogFatal(@"Call objc_msgSend fatal!");
    }
        
    return YES;
}

#pragma mark - Override Methods
- (MKResponseCallback)makeCallbackWithCallbackID:(NSString *)callbackID {
    MKLogError(@"You should override method [%s] in class [%@]!", __FUNCTION__, [self class]);
    return nil;
}

- (void)executeCallbackWithResponse:(MKResponse)response forCallbackID:(NSString *)callbackID {
    MKLogError(@"You should override method [%s] in class [%@]!", __FUNCTION__, [self class]);
}

@end
