//
//  MKMessageBuiltinParser.h
//  MixKit
//
//  Created by liang on 2020/8/21.
//  Copyright © 2020 liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKMessageParser.h"

NS_ASSUME_NONNULL_BEGIN

/// @class MKMessageBuiltinBody
/// @brief 内置交互消息实体类型
@interface MKMessageBuiltinBody : NSObject <MKMessageBody>

@end

/// @class MKMessageBuiltinParser
/// @brief 内置消息解析器类型
@interface MKMessageBuiltinParser : NSObject <MKMessageParser>

@end

NS_ASSUME_NONNULL_END
