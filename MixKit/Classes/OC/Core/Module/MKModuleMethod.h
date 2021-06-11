//
//  MKModuleMethod.h
//  MixKit
//
//  Created by liang on 2020/8/21.
//  Copyright © 2020 liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN

/// @brief 方法类型
typedef NS_ENUM(NSUInteger, MKMethodType) {
    MKUnknownMethod = 0,  ///< 未知方法类型
    MKInstanceMethod,     ///< 实例方法
    MKClassMethod,        ///< 类方法
};

/// @class MKModuleMethod
/// @brief 模块方法信息
@interface MKModuleMethod : NSObject

@property (nonatomic, assign, readonly) Class cls;                      ///< class object
@property (nonatomic, assign, readonly) Class metaClass;                ///< class's meta class object
@property (nonatomic, assign, readonly) Method method;                  ///< method opaque struct
@property (nonatomic, strong, readonly) NSString *name;                 ///< method name
@property (nonatomic, assign, readonly) SEL sel;                        ///< method's selector
@property (nonatomic, assign, readonly) IMP imp;                        ///< method's implementation
@property (nonatomic, strong, readonly) NSString *typeEncoding;         ///< method's parameter and return types
@property (nonatomic, strong, readonly) NSString *returnTypeEncoding;   ///< return value's type
@property (nonatomic, strong, readonly, nullable) NSArray<NSString *> *argumentTypeEncodings; ///< array of arguments' type
@property (nonatomic, assign, readonly) MKMethodType methodType;        ///< method type
@property (nonatomic, strong, readonly) NSMethodSignature *methodSignature; ///< method's signature

/// @brief 禁用初始化方法，使用 `- [MKModuleMethod initWithClass:method:]` 代替
- (instancetype)init NS_UNAVAILABLE;

/// @brief 指定初始化方法
/// @param aClass 模块类型
/// @param method 模块类型下指定方法
/// @return MKModuleMethod 模块方法实例
- (instancetype)initWithClass:(Class)aClass method:(Method)method NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
