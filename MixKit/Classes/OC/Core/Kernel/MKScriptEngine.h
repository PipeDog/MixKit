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

/// @brief 执行脚本
/// @param script 脚本语句
- (void)executeScript:(NSString *)script;

/// @brief 执行脚本
/// @param script 脚本语句
/// @param doneHandler 脚本执行完成回调
- (void)executeScript:(NSString *)script doneHandler:(void (^ _Nullable)(id _Nullable result, NSError * _Nullable error))doneHandler;

@end

NS_ASSUME_NONNULL_END
