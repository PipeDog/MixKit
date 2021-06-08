//
//  MKLogManager.m
//  MixKit_Example
//
//  Created by liang on 2021/6/8.
//  Copyright © 2021 liang. All rights reserved.
//

#import "MKLogManager.h"
#import "MKResponseWrapper.h"

@implementation MKLogManager

MK_EXPORT_METHOD(log, logWithParams:)
MK_EXPORT_METHOD(logMessage, logWithParams:callback:)

- (void)logWithParams:(NSDictionary *)params {
    NSLog(@"[log] %@", params[@"msg"]);
}

- (void)logWithParams:(NSDictionary *)params callback:(MKResponseCallback)callback {
    NSLog(@"[logMessage] %@", params[@"msg"]);
    
    NSDictionary *resp = MKResponseMake(MKCallbackCodeSuccess, @"Log Success", nil);
    !callback ?: callback(@[resp]);
}

@end
