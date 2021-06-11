//
//  MKModuleMethod+Invoke.h
//  MixKit
//
//  Created by liang on 2021/6/10.
//

#import "MKModuleMethod.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKModuleMethod (Invoke)

/// @brief 向 module 实例发送当前方法对应的消息
/// @param module 遵守了 `MKBridgeModule` 协议的 module 实例
/// @param arguments 参数列表
- (void)mk_invokeWithModule:(id)module arguments:(NSArray *)arguments;

@end

NS_ASSUME_NONNULL_END
