//
//  MKUtils.h
//  MixKit
//
//  Created by liang on 2020/8/22.
//  Copyright © 2020 liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKDefines.h"

/// @brief 在主队列执行任务
/// @param block 需要执行的任务代码
MK_EXTERN void MKDispatchAsyncMainQueue(void (^block)(void));

/// @brief 当前是否处于主队列
/// @return BOOL 如果 YES
MK_EXTERN BOOL MKIsOnMainQueue(void);

// Convert nil values to NSNull, and vice-versa
MK_EXTERN id MKNilIfNull(id value);
MK_EXTERN id MKNullIfNil(id value);
