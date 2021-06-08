//
//  MKMessageProtocol.h
//  MixKit
//
//  Created by liang on 2020/8/23.
//  Copyright © 2020 liang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// @protocol MKMessageBody
/// @brief 桥接消息体协议
@protocol MKMessageBody <NSObject>

@property (nonatomic, copy) NSString *moduleName; ///< 模块名
@property (nonatomic, copy) NSString *methodName; ///< JS 侧方法名

@optional
@property (nonatomic, copy) NSString *callbackID; ///< 回调 ID
@property (nonatomic, copy) NSDictionary *params; ///< 参数体

@end


/// @protocol MKMessageParser
/// @brief 消息解析器协议，如果需要支持一种新的数据交互格式，需要遵守这个协议，并实现此协议下的方法
@protocol MKMessageParser <NSObject>

/// @brief 解析后的消息实体
@property (nonatomic, strong, readonly) id<MKMessageBody> messageBody;

/// @brief 确认当前解析器是否能够解析传入的数据
/// @param metaData 原始待解析数据
/// @return 是否能够解析
+ (BOOL)canParse:(id)metaData;

/// @brief 初始化方法
/// @param metaData 原始待解析数据
/// @return 解析器实例，可以通过此协议的只读属性获取解析结果
- (instancetype)initWithMetaData:(id)metaData;

@end

NS_ASSUME_NONNULL_END
