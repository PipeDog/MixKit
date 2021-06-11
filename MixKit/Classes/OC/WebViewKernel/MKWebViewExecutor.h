//
//  MKWebViewExecutor.h
//  MixKit
//
//  Created by liang on 2020/12/26.
//  Copyright © 2020 liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKExecutor.h"

NS_ASSUME_NONNULL_BEGIN

/// @class MKWebViewExecutor
/// @brief webView 执行器
@interface MKWebViewExecutor : MKExecutor

/// @brief 禁用初始化方法，使用 `MKExecutor` 协议提供初始化方法
- (instancetype)init NS_UNAVAILABLE;

/// @brief 注入自定义 js 回调函数脚本
/// @param bridgeName bridge 实例名称
/// @param funcName 回调函数名称
+ (void)registerBridge:(NSString *)bridgeName callbackFunction:(NSString *)funcName;

@end

NS_ASSUME_NONNULL_END
