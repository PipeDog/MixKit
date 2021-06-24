//
//  MKExecutor.m
//  MixKit
//
//  Created by liang on 2020/12/29.
//  Copyright © 2020 liang. All rights reserved.
//

#import "MKExecutor.h"
#import "MKUtils.h"

@implementation MKExecutor

@synthesize bridge = _bridge;

- (instancetype)initWithBridge:(id<MKBridge>)bridge {
    self = [super init];
    if (self) {
        _bridge = bridge;
    }
    return self;
}

#pragma mark - MKExecutor
- (BOOL)invokeMethodOnMainQueue:(id)metaData {
    if (MKIsOnMainQueue()) {
        return [self invokeMethodOnCurrentQueue:metaData];
    }
    
    __block BOOL ret = NO;
    dispatch_semaphore_t lock = dispatch_semaphore_create(0);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ret = [self invokeMethodOnCurrentQueue:metaData];
        dispatch_semaphore_signal(lock);
    });
    
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    return ret;
}

- (BOOL)invokeMethodOnCurrentQueue:(id)metaData {
    NSAssert(NO, @"Override this method [%s] in class [%@]!", __FUNCTION__, [self class]);
    return NO;
}

@end
