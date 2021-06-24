//
//  MKWebViewBridge.h
//  MixKit
//
//  Created by liang on 2020/12/26.
//  Copyright © 2020 liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKBridge.h"
#import "MKScriptEngine.h"

NS_ASSUME_NONNULL_BEGIN

/// @protocol MKWebViewBridgeDelegate
/// @brief webView 桥接代理
@protocol MKWebViewBridgeDelegate <NSObject>

/// @brief 脚本引擎
- (id<MKScriptEngine>)scriptEngine;

@end

/// @class MKWebViewBridge
/// @brief webView 桥接实例
@interface MKWebViewBridge : NSObject <MKBridge>

/// @brief 桥接代理
@property (nonatomic, weak, readonly) id<MKWebViewBridgeDelegate> bridgeDelegate;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/// @brief 指定初始化方法
/// @param bridgeDelegate 桥接代理
/// @return webView 桥接实例
- (instancetype)initWithBridgeDelegate:(id<MKWebViewBridgeDelegate>)bridgeDelegate NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
