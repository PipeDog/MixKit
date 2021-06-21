//
//  MKScriptEngine.h
//  MixKit
//
//  Created by liang on 2020/12/26.
//  Copyright © 2020 liang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// @protocol MKScriptEngine
/// @brief 脚本引擎
@protocol MKScriptEngine <NSObject>

/// @brief 调用函数
/// @param method 函数名
/// @param arguments 参数列表
/// @param doneHandler 调用异步回调
- (void)invokeMethod:(NSString *)method
       withArguments:(NSArray *)arguments
         doneHandler:(void (^ _Nullable)(id _Nullable result, NSError * _Nullable error))doneHandler;

/// @brief 调用函数
/// @param module 模块名
/// @param method 函数名
/// @param arguments 参数列表
/// @param doneHandler 调用异步回调
- (void)invokeModule:(NSString * _Nullable)module
              method:(NSString *)method
       withArguments:(NSArray *)arguments
         doneHandler:(void (^ _Nullable)(id _Nullable result, NSError * _Nullable error))doneHandler;

/// @brief 执行脚本
/// @param script 脚本语句
/// @param doneHandler 脚本执行完成回调
- (void)executeScript:(NSString *)script
          doneHandler:(void (^ _Nullable)(id _Nullable result, NSError * _Nullable error))doneHandler;

@end

NS_ASSUME_NONNULL_END
