//
//  MKModuleManager.m
//  MixKit
//
//  Created by liang on 2020/8/22.
//  Copyright © 2020 liang. All rights reserved.
//

#import "MKModuleManager.h"
#import "MKBridgeModule.h"
#import "MKModuleMethod.h"
#import "MKModuleData.h"
#import "MKDefines.h"
#import <dlfcn.h>
#import <mach-o/getsect.h>
#import <mach-o/dyld.h>

@implementation MKModuleManager {
    NSMutableArray<MKModuleData *> *_moduleDatas;
    NSMutableDictionary<NSString *, MKModuleData *> *_moduleDataMap;
    NSMutableDictionary *_injectJSConfig;
}

static MKModuleManager *__defaultManager;

+ (MKModuleManager *)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (__defaultManager == nil) {
            __defaultManager = [[self alloc] init];
        }
    });
    return __defaultManager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    @synchronized (self) {
        if (__defaultManager == nil) {
            __defaultManager = [super allocWithZone:zone];
        }
    }
    return __defaultManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _moduleDatas = [NSMutableArray array];
        _moduleDataMap = [NSMutableDictionary dictionary];
        _injectJSConfig = [NSMutableDictionary dictionary];
        
        [[MKPerfMonitor defaultMonitor] startPerf:PERF_KEY_REGISTER_MODULE_DATA];
        [self registerModules];
        [[MKPerfMonitor defaultMonitor] endPerf:PERF_KEY_REGISTER_MODULE_DATA];
    }
    return self;
}

#pragma mark - Public Methods
- (void)registerModules {
    for (uint32_t index = 0; index < _dyld_image_count(); index++) {
#ifdef __LP64__
        uint64_t addr = 0;
        const struct mach_header_64 *header = (const struct mach_header_64 *)_dyld_get_image_header(index);
        const struct section_64 *section = getsectbynamefromheader_64(header, "__DATA", "_MK_modulelist");
#else
        uint32_t addr = 0;
        const struct mach_header *header = (const struct mach_header *)_dyld_get_image_header(index);
        const struct section *section = getsectbynamefromheader(header, "__DATA", "_MK_modulelist");
#endif
        
        if (section == NULL) { continue; }
        
        if (header->filetype != MH_OBJECT && header->filetype != MH_EXECUTE && header->filetype != MH_DYLIB) {
            continue;
        }
        
        for (addr = section->offset; addr < section->offset + section->size; addr += sizeof(MKBridgeModuleName)) {
#ifdef __LP64__
            MKBridgeModuleName *module = (MKBridgeModuleName *)((uint64_t)header + addr);
#else
            MKBridgeModuleName *module = (MKBridgeModuleName *)((uint32_t)header + addr);
#endif
            if (!module) { continue; }
            
            NSString *classname = [NSString stringWithUTF8String:module->classname];
            NSString *modulename = [NSString stringWithUTF8String:module->modulename];
            if (_moduleDataMap[modulename]) { continue; }
            
            MKModuleData *moduleData = [[MKModuleData alloc] initWithModuleName:modulename moduleClass:NSClassFromString(classname)];
            [_moduleDatas addObject:moduleData];
            _moduleDataMap[modulename] = moduleData;
            _injectJSConfig[modulename] = moduleData.injectJSConfig;
        }
    }
}

- (MKModuleMethod *)methodWithModuleName:(NSString *)moduleName JSMethodName:(NSString *)JSMethodName {
    MKModuleData *moduleData = _moduleDataMap[moduleName];
    if (!moduleData) { return nil; }
    
    MKModuleMethod *method = moduleData.methodMap[JSMethodName];
    NSAssert(method, @"Get method failed, moduleName = [%@], js_name = [%@]", moduleName, JSMethodName);
    return method;
}

#pragma mark - Getter Methods
- (NSArray<MKModuleData *> *)moduleDatas {
    return _moduleDatas;
}

- (NSDictionary<NSString *,MKModuleData *> *)moduleDataMap {
    return _moduleDataMap;
}

- (NSDictionary *)injectJSConfig {
    return _injectJSConfig;
}

@end
