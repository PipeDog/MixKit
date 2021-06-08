//
//  MKDefines.h
//  MixKit
//
//  Created by liang on 2020/8/21.
//  Copyright © 2020 liang. All rights reserved.
//

#ifndef MKDefines_h
#define MKDefines_h

#import <Foundation/Foundation.h>

#if defined(__cplusplus)
    #define MK_EXTERN extern "C" __attribute__((visibility("default")))
#else
    #define MK_EXTERN extern __attribute__((visibility("default")))
#endif

#endif /* MKDefines_h */
