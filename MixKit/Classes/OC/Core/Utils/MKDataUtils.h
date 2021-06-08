//
//  MKDataUtils.h
//  MixKit
//
//  Created by liang on 2020/10/14.
//  Copyright © 2020 liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKDefines.h"

/// @brief 数据（如 NSData、NSString）转 JSON 类型，如 NSArray、NSDictionary 等
/// @param value 原始数据
/// @return JSON 格式数据
MK_EXTERN id MKValueToJSONObject(id value);

/// @brief 数据（如 NSArray、NSDictionary）转 NSData 类型
/// @param value 原始数据
/// @return NSData 实例
MK_EXTERN NSData *MKValueToData(id value);

/// @brief 数据转字符串
/// @param value 原始数据
/// @return NSString 实例
MK_EXTERN NSString *MKValueToJSONText(id value);
