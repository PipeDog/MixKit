//
//  MKSocketBridge.m
//  MoonBridge
//
//  Created by liang on 2021/6/23.
//

#import "MKSocketBridge.h"
#import "MKBridgeModuleCreator.h"
#import "MKSocketExecutor.h"

@interface MKSocketBridge ()

@property (nonatomic, strong) MKSocketExecutor *socketExecutor;
@property (nonatomic, strong) MKBridgeModuleCreator *socketModuleCreator;

@end

@implementation MKSocketBridge

- (instancetype)initWithBridgeDelegate:(id<MKSocketBridgeDelegate>)bridgeDelegate {
    self = [super init];
    if (self) {
        _bridgeDelegate = bridgeDelegate;
        _socketExecutor = [[MKSocketExecutor alloc] initWithBridge:self];
        _socketModuleCreator = [[MKBridgeModuleCreator alloc] initWithBridge:self];
    }
    return self;
}

- (id<MKExecutor>)bridgeExecutor {
    return self.socketExecutor;
}

- (id<MKBridgeModuleCreator>)bridgeModuleCreator {
    return self.socketModuleCreator;
}

- (id<MKMessageParserManager>)bridgeMessageParserManager {
    return [MKMessageParserManager defaultManager];
}

@end
