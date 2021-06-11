//
//  MKConvertDataModule.h
//  MixKit_Example
//
//  Created by liang on 2021/6/11.
//  Copyright © 2021 liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MKBridgeModule.h>

NS_ASSUME_NONNULL_BEGIN

MK_EXPORT_MODULE(ConvertDataModule, MKConvertDataModule)

@interface MKConvertDataModule : NSObject <MKBridgeModule>

@end

NS_ASSUME_NONNULL_END