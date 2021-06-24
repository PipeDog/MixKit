//
//  MKExecutor.h
//  MixKit
//
//  Created by liang on 2020/12/29.
//  Copyright © 2020 liang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKBridge;

/// @protocol MKExecutor
/// @brief 桥接执行器
@protocol MKExecutor <NSObject>

/// @brief 绑定的 bridge 实例
@property (nonatomic, weak, readonly) id<MKBridge> bridge;

/// @brief 初始化方法
/// @param bridge 桥接实例
/// @return 执行器
- (instancetype)initWithBridge:(id<MKBridge>)bridge;

/// @brief 在主队列调用客户端方法（内部调用 `invokeMethodOnCurrentQueue:` 方法，这里只是进行队列切换操作）
/// @param metaData 桥接消息体数据
/// @return 分发方法是否成功
- (BOOL)invokeMethodOnMainQueue:(id)metaData;

/// @brief 在当前列调用客户端方法
/// @param metaData 桥接消息体数据
/// @return 分发方法是否成功
- (BOOL)invokeMethodOnCurrentQueue:(id)metaData;

@end

/// @class MKExecutor
/// @brief 模版执行器，不同 kernal 实现只需要重载下列两个函数即可
@interface MKExecutor : NSObject <MKExecutor>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
