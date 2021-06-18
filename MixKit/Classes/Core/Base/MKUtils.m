//
//  MKUtils.m
//  MixKit
//
//  Created by liang on 2020/8/22.
//  Copyright © 2020 liang. All rights reserved.
//

#import "MKUtils.h"

void MKDispatchAsyncMainQueue(void (^block)(void)) {
    if (MKIsOnMainQueue()) {
        !block ?: block();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            !block ?: block();
        });
    }
}

BOOL MKIsOnMainQueue(void) {
    return (0 == strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL),
                        dispatch_queue_get_label(dispatch_get_main_queue())));
}

id MKNullIfNil(id value) {
    return value ?: (id)kCFNull;
}

id MKNilIfNull(id value) {
    return value == (id)kCFNull ? nil : value;
}
