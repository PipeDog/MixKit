//
//  MKBridgeModuleCreator.h
//  MixKit
//
//  Created by liang on 2020/12/26.
//  Copyright © 2020 liang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKBridge, MKBridgeModule;

/// @protocol MKBridgeModuleCreator
/// @brief 模块构造管理器
@protocol MKBridgeModuleCreator <NSObject>

/// @brief 初始化方法，绑定所属 bridge
/// @param bridge 绑定桥接实例
/// @return 模块构造器实例
- (instancetype)initWithBridge:(id<MKBridge>)bridge;

/// @brief 根据 module 的类型生成不同 module 实例
/// @param moduleClass module 类型
/// @return module 实例
- (id<MKBridgeModule> _Nullable)moduleWithClass:(Class)moduleClass;

@end

/// @class MKBridgeModuleCreator
/// @brief 模块构造器模版类，一般情况下不需要重新自定义
@interface MKBridgeModuleCreator : NSObject <MKBridgeModuleCreator>

/// @brief 禁用初始化方法，使用 `MKBridgeModuleCreator` 协议提供方法代替
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
