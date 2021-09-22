//
//  MKMethodInvoker.h
//  MixKit
//
//  Created by liang on 2021/7/26.
//

#import <Foundation/Foundation.h>

@class MKModuleMethod;

NS_ASSUME_NONNULL_BEGIN

@interface MKMethodInvoker : NSObject

@property (nonatomic, strong, readonly) MKModuleMethod *method;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithMethod:(MKModuleMethod *)method NS_DESIGNATED_INITIALIZER;

/// @brief 向 module 实例发送当前方法对应的消息
/// @param module 遵守了 `MKBridgeModule` 协议的 module 实例
/// @param arguments 参数列表
/// @return 如果调用方法成功，则返回 NSInvocation 实例，否则返回 nil，可以使用 - [NSInvocation getReturnValue:] 获取执行结果
- (NSInvocation * _Nullable)invokeWithModule:(id)module arguments:(NSArray *)arguments;

@end

NS_ASSUME_NONNULL_END
