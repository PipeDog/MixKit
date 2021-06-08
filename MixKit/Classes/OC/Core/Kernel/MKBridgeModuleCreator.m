//
//  MKBridgeModuleCreator.m
//  MixKit
//
//  Created by liang on 2020/12/26.
//  Copyright © 2020 liang. All rights reserved.
//

#import "MKBridgeModuleCreator.h"
#import "MKBridge.h"
#import "MKBridgeModule.h"

@implementation MKBridgeModuleCreator {
    __weak id<MKBridge> _bridge;
    NSMutableDictionary<NSString *, id<MKBridgeModule>> *_modules;
}

- (void)dealloc {
    NSArray *modules = _modules.allValues;
    for (id<MKBridgeModule> module in modules) {
        if ([module respondsToSelector:@selector(unload)]) {
            [module unload];
        }
    }
}

- (instancetype)initWithBridge:(id<MKBridge>)bridge {
    self = [super init];
    if (self) {
        _bridge = bridge;
        _modules = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id<MKBridgeModule>)moduleWithClass:(Class)moduleClass {
    if (!moduleClass) {
        return nil;
    }
    
    NSString *name = NSStringFromClass(moduleClass);
    id<MKBridgeModule> module = _modules[name];
    if (!module) {
        module = [[moduleClass alloc] init];
        
        if ([module respondsToSelector:@selector(setBridge:)]) {
            module.bridge = _bridge;
        }
        if ([module respondsToSelector:@selector(load)]) {
            [module load];
        }

        _modules[name] = module;
    }
    return module;
}


@end
