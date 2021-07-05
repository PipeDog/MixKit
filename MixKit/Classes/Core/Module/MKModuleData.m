//
//  MKModuleData.m
//  MixKit
//
//  Created by liang on 2020/8/21.
//  Copyright © 2020 liang. All rights reserved.
//

#import "MKModuleData.h"
#import "MKModuleMethod.h"
#import "MKDefines.h"
#import <objc/message.h>

@implementation MKModuleData

- (instancetype)initWithModuleName:(NSString *)moduleName moduleClass:(Class)moduleClass {
    if (!moduleName.length || !moduleClass) {
        NSAssert(NO, @"The arguments `moduleName` and `moduleClass` should be valid!");
        return nil;
    }

    self = [super init];
    if (self) {
        _moduleName = [moduleName copy];
        _moduleClass = moduleClass;
        
        [self loadMethods];
        [self builtExportDispatchTable];
    }
    return self;
}

- (void)loadMethods {
    Class moduleClass = _moduleClass;
    Class metaClass = object_getClass(moduleClass);
    
    unsigned int outCount = 0;
    Method *methodList = class_copyMethodList(metaClass, &outCount);
    NSMutableDictionary<NSString *, MKModuleMethod *> *methods = [NSMutableDictionary dictionary];
    
    for (unsigned int i = 0; i < outCount; i++) {
        SEL exportSel = method_getName(methodList[i]);
        NSString *methodName = NSStringFromSelector(exportSel);
        if (![methodName hasPrefix:@"__MK_export_method_"]) {
            continue;
        }
        
        NSArray *infos = ((NSArray *(*)(id, SEL))objc_msgSend)(moduleClass, exportSel);
        if (infos.count != 2) {
            NSAssert(NO, @"Export method [%@] error",
                     [methodName substringFromIndex:@"__MK_export_method_".length]);
            continue;
        }
        
        NSString *js_name = infos[0];
        if (methods[js_name]) {
            MKLogWarn(@"Duplicate named, 'js_name' = [%@]!", js_name);
            continue;
        }
        
        SEL nativeSel = NSSelectorFromString(infos[1]);
        Method nativeMethod = class_getInstanceMethod(moduleClass, nativeSel);
        if (!nativeMethod) {
            NSAssert(NO, @"Can not find method named `%@`!", NSStringFromSelector(nativeSel));
            continue;
        }
        
        MKModuleMethod *method = [[MKModuleMethod alloc] initWithClass:moduleClass method:nativeMethod];
        if (!method) {
            continue;
        }

        methods[js_name] = method;
    }

    _methodMap = methods;
    _methods = _methodMap.allValues;
    
    if (methodList) {
        free(methodList);
    }
}

- (void)builtExportDispatchTable {
    _exportDispatchTable = @{
        @"methods": _methodMap.allKeys ?: @[],
    };
}

@end
