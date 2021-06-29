//
//  MKSocketBridge.h
//  MoonBridge
//
//  Created by liang on 2021/6/23.
//

#import <Foundation/Foundation.h>
#import "MKBridge.h"
#import "MKSocketEngine.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MKSocketBridgeDelegate <NSObject>

- (id<MKSocketEngine>)socketEngine;

@end

@interface MKSocketBridge : NSObject <MKBridge>

@property (nonatomic, weak, readonly) id<MKSocketBridgeDelegate> bridgeDelegate;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithBridgeDelegate:(id<MKSocketBridgeDelegate>)bridgeDelegate NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
