//
//  MKModuleManager.h
//  MixKit
//
//  Created by liang on 2020/8/22.
//  Copyright © 2020 liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MKModuleData;
@class MKModuleMethod;
@class MKMethodInvoker;

NS_ASSUME_NONNULL_BEGIN

/// @class MKModuleManager
/// @brief 模块数据管理器
@interface MKModuleManager : NSObject

/// @brief MKModuleManager 单例对象
@property (class, strong, readonly) MKModuleManager *defaultManager;

/// @brief 模块数据列表
@property (nonatomic, copy, readonly) NSArray<MKModuleData *> *moduleDatas;

/// @brief 模块数据映射表，{ 'js_method_name': module }
@property (nonatomic, copy, readonly) NSDictionary<NSString *, MKModuleData *> *moduleDataMap;

/// @brief 导出信息表，包括模块名和函数名称列表（目前仅用于向 JS 侧注入）
@property (nonatomic, copy, readonly) NSDictionary *exportDispatchTable;

/// @brief 通过 moduleName 和 JSMethodName 获取对应的 MKModuleMethod 实例
/// @param moduleName 模块名
/// @param JSMethodName JS 函数名
/// @return 期望的 MKModuleMethod 实例
- (MKModuleMethod * _Nullable)methodWithModuleName:(NSString *)moduleName
                                      JSMethodName:(NSString *)JSMethodName;

/// @brief 获取 invoker 实例
/// @param moduleName 导出模块名
/// @param methodName js 函数名
/// @return 对应 invoker 实例
- (MKMethodInvoker *)invokerWithModuleName:(NSString *)moduleName
                                methodName:(NSString *)methodName;

@end

NS_ASSUME_NONNULL_END
