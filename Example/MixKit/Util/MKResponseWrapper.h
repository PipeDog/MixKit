//
//  MKResponseWrapper.h
//  MixKit_Example
//
//  Created by liang on 2021/6/8.
//  Copyright © 2021 liang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSInteger MKCallbackCode NS_TYPED_ENUM;

extern MKCallbackCode const MKCallbackCodeSuccess;

extern NSDictionary *MKResponseMake(MKCallbackCode code,
                                    NSString * _Nullable message,
                                    NSDictionary * _Nullable data);

NS_ASSUME_NONNULL_END
