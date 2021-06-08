//
//  MKResponseWrapper.m
//  MixKit_Example
//
//  Created by liang on 2021/6/8.
//  Copyright © 2021 liang. All rights reserved.
//

#import "MKResponseWrapper.h"

MKCallbackCode const MKCallbackCodeSuccess = 0;

NSDictionary *MKResponseMake(MKCallbackCode code,
                             NSString * _Nullable message,
                             NSDictionary * _Nullable data) {
    NSMutableDictionary *response = [NSMutableDictionary dictionary];
    response[@"code"] = @(code);
    response[@"message"] = message ?: @"";
    response[@"data"] = data ?: @{};
    return response;
}
