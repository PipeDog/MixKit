//
//  MKBridgeModule.m
//  MixKit
//
//  Created by liang on 2020/8/21.
//  Copyright © 2020 liang. All rights reserved.
//

#import "MKBridgeModule.h"

MKCallbackCode const MKCallbackCodeSuccess = 0;

MKResponse MKResponseMake(MKCallbackCode code,
                          NSString * _Nullable message,
                          NSDictionary * _Nullable data) {
    NSMutableDictionary *response = [NSMutableDictionary dictionary];
    response[@"code"] = @(code);
    response[@"message"] = message ?: @"";
    response[@"data"] = data ?: @{};
    return response;
}

@implementation MKBridgeModule

@end
