//
//  MKUtil.m
//  MixKit_Example
//
//  Created by liang on 2021/6/8.
//  Copyright © 2021 liang. All rights reserved.
//

#import "MKUtil.h"
#import <MKWebView.h>

UIViewController *MKGetPageByBridge(id<MKBridge> bridge) {
    if (![bridge isKindOfClass:[MKWebViewBridge class]]) {
        return nil;
    }
    
    MKWebViewBridge *webBridge = (MKWebViewBridge *)bridge;
    MKWebView *webView = (MKWebView *)webBridge.bridgeDelegate;
    
    UIResponder *nextResponder = webView.nextResponder;
    
    while (![nextResponder isKindOfClass:[UIViewController class]]) {
        nextResponder = nextResponder.nextResponder;
    }
    
    return (UIViewController *)nextResponder;
}
