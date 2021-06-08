//
//  MKMessageParser.h
//  MixKit
//
//  Created by liang on 2020/8/21.
//  Copyright © 2020 liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKMessageProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/// @class MKMessageBody
/// @brief 默认交互消息实体类型
@interface MKMessageBody : NSObject <MKMessageBody>

@end

/// @class MKMessageParser
/// @brief 默认消息解析器类型
@interface MKMessageParser : NSObject <MKMessageParser>

@end

NS_ASSUME_NONNULL_END
