//
//  MKWebViewBridge.m
//  MixKit
//
//  Created by liang on 2020/12/26.
//  Copyright © 2020 liang. All rights reserved.
//

#import "MKWebViewBridge.h"
#import "MKWebViewExecutor.h"
#import "MKBridgeModuleCreator.h"

@interface MKWebViewBridge ()

@property (nonatomic, strong) MKWebViewExecutor *webViewExecutor;
@property (nonatomic, strong) MKBridgeModuleCreator *webViewBridgeModuleCreator;

@end

@implementation MKWebViewBridge

- (instancetype)initWithBridgeDelegate:(id<MKWebViewBridgeDelegate>)bridgeDelegate {
    self = [super init];
    if (self) {
        _bridgeDelegate = bridgeDelegate;
        _webViewExecutor = [[MKWebViewExecutor alloc] initWithBridge:self];
        _webViewBridgeModuleCreator = [[MKBridgeModuleCreator alloc] initWithBridge:self];
    }
    return self;
}

- (id<MKExecutor>)bridgeExecutor {
    return self.webViewExecutor;
}

- (id<MKBridgeModuleCreator>)bridgeModuleCreator {
    return self.webViewBridgeModuleCreator;
}

- (id<MKMessageParserManager>)bridgeMessageParserManager {
    return [MKMessageParserManager defaultManager];
}

@end
