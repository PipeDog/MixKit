//
//  MKBridgeModule.h
//  MixKit
//
//  Created by liang on 2020/8/21.
//  Copyright © 2020 liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKDefines.h"
#import "MKBridge.h"

NS_ASSUME_NONNULL_BEGIN

/// @brief 桥接回调类型规范
typedef void (^MKResponseCallback)(NSArray *arguments);

/// @brief 桥接模块信息存储结构
typedef struct {
    const char *modulename;
    const char *classname;
} MKBridgeModuleName;

#define __MK_EXPORT_MODULE_EX(modulename, classname)          \
__attribute__((used, section("__DATA , _MK_modulelist")))     \
static const MKBridgeModuleName __MK_exp_module_##modulename##__ = {#modulename, #classname};

/// @brief 导出桥接模块名称及类型，需要在使用 bridge 功能前调用
///        `- [MKModuleExporter registerModules]` 方法注册导出的模块
/// @param modulename 桥接模块名
/// @param classname 桥接模块类名
#define MK_EXPORT_MODULE(modulename, classname) __MK_EXPORT_MODULE_EX(modulename, classname)

/// @brief 导出 bridge 函数
/// @param js_name JS 侧调用函数名
/// @param native_sel OC 侧方法选择器
#define MK_EXPORT_METHOD(js_name, native_sel)                           \
+ (NSArray *)__MK_export_method_##js_name##__ {                         \
    return @[@#js_name, NSStringFromSelector(@selector(native_sel))];   \
}


/// @protocol MKBridgeModule
/// @brief 桥接模块协议，如果想将某一个类作为桥接模块，需要遵守这个协议
@protocol MKBridgeModule <NSObject>

@optional

/// @brief 对 MKBridge 的一个引用，对于需要访问侨界特性的模块可以访问这个变量，但不
///        要在模块中改动这个变量，此变量将在桥接模块初始化时自动设置，如果需要在模块中使
///        用这个变量，需要在模块中添加代码 `@synthesize bridge = _bridge; `
@property (nonatomic, weak) id<MKBridge> bridge;

/// @brief 载入桥接模块，在这个方法里做一些初始化设置相关的操作，而不是在 `- init` 方法中
- (void)load;

/// @brief 桥接模块将要被卸载销毁，在这个方法里做一些回收相关的操作
- (void)unload;

@end


@interface MKBridgeModule : NSObject <MKBridgeModule>

@end

NS_ASSUME_NONNULL_END
