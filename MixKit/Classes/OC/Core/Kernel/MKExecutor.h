//
//  MKExecutor.h
//  MixKit
//
//  Created by liang on 2020/12/29.
//  Copyright © 2020 liang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSDictionary *MKResponse;
typedef void (^MKResponseCallback)(MKResponse response);

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

/// @brief 调用客户端方法
/// @param metaData 桥接消息体数据
/// @return 分发方法是否成功
- (BOOL)callNativeMethod:(id)metaData;

/// @brief 执行回调给 JS 侧
/// @param response 响应数据
/// @param callbackID 回调 ID
- (void)invokeCallbackWithResponse:(MKResponse)response forCallbackID:(NSString *)callbackID;

@end

/// @class MKExecutor
/// @brief 模版执行器，不同 kernal 实现只需要重载下列两个函数即可
@interface MKExecutor : NSObject <MKExecutor>

/// @brief 禁用初始化方法，使用 `MKExecutor` 协议中初始化方法代替
- (instancetype)init NS_UNAVAILABLE;

/// @brief 构建 callback 回调
/// @param callbackID 回调 ID
/// @return callback 实例
- (MKResponseCallback)makeCallbackWithCallbackID:(NSString *)callbackID;

/// @brief 执行 bridge 回调
/// @param response 回调参数
/// @param callbackID 回调 ID
- (void)executeCallbackWithResponse:(MKResponse)response forCallbackID:(NSString *)callbackID;

@end

NS_ASSUME_NONNULL_END
