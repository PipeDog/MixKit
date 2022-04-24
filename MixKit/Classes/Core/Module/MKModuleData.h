//
//  MKModuleData.h
//  MixKit
//
//  Created by liang on 2020/8/21.
//  Copyright © 2020 liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MKModuleMethod;

NS_ASSUME_NONNULL_BEGIN

/// @class MKModuleData
/// @brief 桥接模块数据包装
@interface MKModuleData : NSObject

/// @brief 模块导出名称
@property (nonatomic, strong, readonly) NSString *moduleName;
/// @brief 模块类型
@property (nonatomic, strong, readonly) Class moduleClass;
/// @brief 方法信息列表
@property (nonatomic, strong, readonly) NSArray<MKModuleMethod *> *methods;
/// @brief 方法导出集合，Key - js_name，Value - MKModuleMethod 实例
@property (nonatomic, strong, readonly) NSDictionary<NSString *, MKModuleMethod *> *methodMap;
/// @brief 常量表，Key - 常量名，Value - 常量值
@property (nonatomic, strong, readonly) NSDictionary<NSString *, id> *constantsTable;
/// @brief 导出信息表（目前仅用于向 JS 侧注入）
@property (nonatomic, strong, readonly) NSDictionary *exportDispatchTable;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/// @brief 指定初始化方法
/// @param moduleName 模块名称
/// @param moduleClass 模块类型
/// @return MKModuleData 实例
- (instancetype)initWithModuleName:(NSString *)moduleName
                       moduleClass:(Class)moduleClass NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
