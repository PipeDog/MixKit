//
//  MKMessageParserManager.h
//  MixKit
//
//  Created by liang on 2020/8/21.
//  Copyright © 2020 liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKMessageParser.h"
#import "MKDefines.h"

NS_ASSUME_NONNULL_BEGIN

/// @brief 将给定的类注册为消息解析器，所有导出的消息解析器最终
///        都被存储在静态数组 `MKMessageParserClasses` 中
MK_EXTERN void MKRegisterMessageParser(Class);

/// @brief 将给定的类注册为消息解析器，将此宏放在类实现中，
///        以便在执行 `+ load` 方法时自动向桥注册模块
#define MK_EXPORT_MESSAGE_PARSER()              \
MK_EXTERN void MKRegisterMessageParser(Class);  \
+ (void)load { MKRegisterMessageParser([self class]); }

/// @protocol MKMessageParserManager
/// @brief 消息解析管理器
@protocol MKMessageParserManager <NSObject>

/// @brief 根据传入的元数据来获取相应的解析器
/// @param metaData 原始待解析数据
/// @return 能够解析此类数据的解析器
- (id<MKMessageParser> _Nullable)parserWithMetaData:(id)metaData;

@end

/// @class MKMessageParserManager
/// @brief 消息解析器管理者，通过这个类来获取能够正确解析某一类数据的解析器
@interface MKMessageParserManager : NSObject <MKMessageParserManager>

/// @brief MKMessageParserManager 单例对象
@property (class, strong, readonly) MKMessageParserManager *defaultManager;

@end

NS_ASSUME_NONNULL_END
