//
//  MKBridge.h
//  MixKit
//
//  Created by liang on 2020/12/26.
//  Copyright © 2020 liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKExecutor.h"
#import "MKBridgeModuleCreator.h"
#import "MKMessageParserManager.h"

NS_ASSUME_NONNULL_BEGIN

/// @protocol MKBridge
/// @brief 桥接协议
@protocol MKBridge <NSObject>

/// @brief 桥接执行器
- (id<MKExecutor>)bridgeExecutor;

/// @brief 模块构造器
- (id<MKBridgeModuleCreator>)bridgeModuleCreator;

/// @brief 消息解析管理器
- (id<MKMessageParserManager>)bridgeMessageParserManager;

@end

NS_ASSUME_NONNULL_END
