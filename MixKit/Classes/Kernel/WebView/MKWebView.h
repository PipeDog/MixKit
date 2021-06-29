//
//  MKWebView.h
//  MixKit
//
//  Created by liang on 2020/12/26.
//  Copyright © 2020 liang. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "MKScriptEngine.h"
#import "MKWebViewBridge.h"

NS_ASSUME_NONNULL_BEGIN

/// @brief 内部默认注册的 JS 脚本消息名称
FOUNDATION_EXPORT NSString *const MKWebViewMessageName;

@class MKWebView;

/// @protocol MKWebViewBridgeHandler
/// @brief bridge 通信处理回调
@protocol MKWebViewBridgeHandler <NSObject>

/// @brief 接收到 JS 侧脚本消息
/// @param webView web 容器
/// @param message 接收到的消息对象
/// @return 如果返回 YES 则表示外部处理该消息，如果返回 NO 则执行内部默认逻辑
- (BOOL)webView:(MKWebView *)webView didReceiveScriptMessage:(WKScriptMessage *)message;

/// @brief 内部解析脚本消息异常
/// @param webView web 容器
/// @param message 接收到的消息对象
- (void)webView:(MKWebView *)webView didFailParseMessage:(WKScriptMessage *)message;

@end

/// @class MKWebView
/// @brief 提供 bridge 能力的 webView 容器，以此为入口使用 bridge 功能
@interface MKWebView : WKWebView <MKScriptEngine>

/// @brief webView 桥接实例
@property (nonatomic, strong, readonly) MKWebViewBridge *webViewBridge;
/// @brief bridge 通信处理回调
@property (nonatomic, weak) id<MKWebViewBridgeHandler> bridgeHandler;

/// @brief 禁用初始化方法，使用 `- initWithFrame: configuration:` 代替
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
