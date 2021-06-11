//
//  MKLogManager.m
//  MixKit_Example
//
//  Created by liang on 2021/6/8.
//  Copyright © 2021 liang. All rights reserved.
//

#import "MKLogManager.h"
#import "MKResponseWrapper.h"

struct MKTestStruct {
    const char *name;
    int age;
};
typedef struct MKTestStruct MKTestStruct;

@implementation MKLogManager

MK_EXPORT_METHOD(log, logWithParams:)
MK_EXPORT_METHOD(logMessage, logWithParams:callback:)
MK_EXPORT_METHOD(logDefault, logDefault)


- (void)logWithParams:(NSDictionary *)params {
    NSLog(@"[log] %@", params[@"msg"]);
}

- (void)logWithParams:(NSDictionary *)params callback:(MKResponseCallback)callback {
    NSLog(@"[logMessage] %@", params[@"msg"]);
    
    NSDictionary *resp = MKResponseMake(MKCallbackCodeSuccess, @"Log Success", nil);
    !callback ?: callback(@[resp]);
}

- (void)logDefault {
    NSLog(@"logDefault");
}

@end
