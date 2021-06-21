//
//  MKWebView.m
//  MixKit
//
//  Created by liang on 2020/12/26.
//  Copyright © 2020 liang. All rights reserved.
//

#import "MKWebView.h"
#import "MKUtils.h"
#import "MKDataUtils.h"
#import "MKModuleManager.h"
#import "MKMessageParserManager.h"

NSString *const MKWebViewMessageName = @"MixKit";

static WKProcessPool *_MKGlobalProcessPool(void) {
    // Share cookies across multiple webviews.
    static WKProcessPool *_globalProcessPool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _globalProcessPool = [[WKProcessPool alloc] init];
    });
    return _globalProcessPool;
}

// https://stackoverflow.com/questions/26383031/wkwebview-causes-my-view-controller-to-leak/33365424
@interface _MKLeakAvoider : NSObject <WKScriptMessageHandler>

@property (nonatomic, weak) id<WKScriptMessageHandler> delegate;

@end

@implementation _MKLeakAvoider

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
}

@end

@interface MKWebView () <WKScriptMessageHandler, MKWebViewBridgeDelegate>

@end

@implementation MKWebView

@synthesize webViewBridge = _webViewBridge;

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [[NSException exceptionWithName:@"MKWebViewInitException"
                                 reason:@"Does not support init from nib."
                               userInfo:nil] raise];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    // 1. setup configuration
    if (!configuration) {
        configuration = [[WKWebViewConfiguration alloc] init];
    }
    configuration.processPool = _MKGlobalProcessPool();
    
    // 2. initialize userContentControlelr
    WKUserContentController *userContentController = configuration.userContentController;
    if (!userContentController) {
        userContentController = [[WKUserContentController alloc] init];
        configuration.userContentController = userContentController;
    }
    
    // 3. register message handler
    _MKLeakAvoider *leakAvoider = [[_MKLeakAvoider alloc] init];
    leakAvoider.delegate = self;
    [userContentController addScriptMessageHandler:leakAvoider name:MKWebViewMessageName];
    
    // 4. setup initialization
    self = [super initWithFrame:frame configuration:configuration];
    if (self) {
        _webViewBridge = [[MKWebViewBridge alloc] initWithBridgeDelegate:self];
        
        NSDictionary *config = [MKModuleManager defaultManager].injectJSConfig;
        NSString *injectScript = [NSString stringWithFormat:@
                                  "window.__mk_nativeConfig = %@;"
                                  "window.__mk_systemType = %zd;",
                                  MKValueToJSONText(config), 1L];

        WKUserScript *userScript = [[WKUserScript alloc] initWithSource:injectScript
                                                          injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                       forMainFrameOnly:NO];
        [userContentController addUserScript:userScript];
    }
    return self;
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([self.bridgeHandler webView:self didReceiveScriptMessage:message]) {
        return;
    }
    
    // Check default logic
    if (![message.name isEqualToString:MKWebViewMessageName]) {
        return;
    }
    if (![message.body isKindOfClass:[NSDictionary class]]) {
        NSAssert(NO, @"Invalid `message.body`, message.body's class is [%@], message.body = %@",
                 [message.body class], message.body);
        return;
    }

    if (![self.webViewBridge.bridgeExecutor callNativeMethod:message.body]) {
        [self.bridgeHandler webView:self didFailParseMessage:message];
    }
}

#pragma mark - MKScriptEngine
- (void)invokeMethod:(NSString *)method
       withArguments:(NSArray *)arguments
         doneHandler:(void (^)(id _Nullable, NSError * _Nullable))doneHandler {
    [self invokeModule:nil method:method withArguments:arguments doneHandler:doneHandler];
}

- (void)invokeModule:(NSString *)module
              method:(NSString *)method
       withArguments:(NSArray *)arguments
         doneHandler:(void (^)(id _Nullable, NSError * _Nullable))doneHandler {
    if (!method.length) {
        NSError *error = [NSError errorWithDomain:@"MixKitErrorDomain"
                                             code:-1000
                                         userInfo:@{NSLocalizedFailureReasonErrorKey: @"[Call JS] The argument `method` can not be nil!"}];
        !doneHandler ?: doneHandler(nil, error);
        return;
    }
    
    NSMutableString *jsScript = [NSMutableString string];
    if (module.length > 0) { [jsScript appendFormat:@"%@.", module]; }
    
    [jsScript appendString:method];
    [jsScript appendString:@"("];
    
    NSUInteger numberOfArguments = arguments.count;
    [arguments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]) {
            NSString *argument = MKValueToJSONText(obj);
            [jsScript appendString:argument];
        } else if ([obj isKindOfClass:[NSString class]]) {
            [jsScript appendFormat:@"'%@'", obj];
        } else if ([obj isKindOfClass:[NSNumber class]]) {
            [jsScript appendString:[obj description]];
        } else {
            NSAssert(NO, @"Unsupport data type, obj's class is `%@`, obj = %@", [obj class], obj);
            [jsScript appendString:@"null"];
        }
        
        if (idx != numberOfArguments - 1) {
            [jsScript appendString:@", "];
        }
    }];
    
    [jsScript appendString:@");"];
    [self executeScript:jsScript doneHandler:doneHandler];
}

- (void)executeScript:(NSString *)script
          doneHandler:(void (^)(id _Nullable, NSError * _Nullable))doneHandler {
    MKDispatchAsyncMainQueue(^{
        [self evaluateJavaScript:script completionHandler:doneHandler];
    });
}

#pragma mark - MKWebViewBridgeDelegate
- (id<MKScriptEngine>)scriptEngine {
    return self;
}

@end
