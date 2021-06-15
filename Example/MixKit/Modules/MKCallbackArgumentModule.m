//
//  MKCallbackArgumentModule.m
//  MixKit_Example
//
//  Created by liang on 2021/6/15.
//  Copyright © 2021 liang. All rights reserved.
//

#import "MKCallbackArgumentModule.h"

@implementation MKCallbackArgumentModule

MK_EXPORT_METHOD(callbackArguments, callbackArgumentsWithCallback:)

- (void)callbackArgumentsWithCallback:(MKResponseCallback)callback {
    !callback ?: callback(@[@"first element!", @"second element!"]);
}

@end
