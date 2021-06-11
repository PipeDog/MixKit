//
//  MKExecutor.m
//  MixKit
//
//  Created by liang on 2020/12/29.
//  Copyright © 2020 liang. All rights reserved.
//

#import "MKExecutor.h"

@implementation MKExecutor

@synthesize bridge = _bridge;

- (instancetype)initWithBridge:(id<MKBridge>)bridge {
    self = [super init];
    if (self) {
        _bridge = bridge;
    }
    return self;
}

- (BOOL)callNativeMethod:(id)metaData {
    MKLogError(@"You should override method [%s] in class [%@]!", __FUNCTION__, [self class]);
    return NO;
}

@end
