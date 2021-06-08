//
//  MKModuleMethod.m
//  MixKit
//
//  Created by liang on 2020/8/21.
//  Copyright © 2020 liang. All rights reserved.
//

#import "MKModuleMethod.h"

/**
 arglist: [
    0. self
    1. _cmd
    2. params
    3. callback
 ]
 */
#define MK_EXPORT_METHOD_ARGS_NUM_2 2 // self, _cmd
#define MK_EXPORT_METHOD_ARGS_NUM_3 3 // self, _cmd, (params || callback)
#define MK_EXPORT_METHOD_ARGS_NUM_4 4 // self, _cmd, params, callback

@implementation MKModuleMethod

- (instancetype)initWithClass:(Class)aClass method:(Method)method {
    if (!aClass) { return nil; }
    if (!method) { return nil; }
    self = [super init];
    _cls = aClass;
    _metaClass = object_getClass(_cls);
    _method = method;
    _sel = method_getName(method);
    _imp = method_getImplementation(method);
    const char *name = sel_getName(_sel);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    const char *typeEncoding = method_getTypeEncoding(method);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
    }
    char *returnType = method_copyReturnType(method);
    if (returnType) {
        _returnTypeEncoding = [NSString stringWithUTF8String:returnType];
        free(returnType);
    }
    unsigned int argumentCount = method_getNumberOfArguments(method);
    if (argumentCount != MK_EXPORT_METHOD_ARGS_NUM_2 &&
        argumentCount != MK_EXPORT_METHOD_ARGS_NUM_3 &&
        argumentCount != MK_EXPORT_METHOD_ARGS_NUM_4) {
        MKLogFatal(@"Invalid number of method arguments!");
    }
    if (argumentCount > 0) {
        NSMutableArray *argumentTypes = [NSMutableArray new];
        for (unsigned int i = 0; i < argumentCount; i++) {
            char *argumentType = method_copyArgumentType(method, i);
            NSString *type = argumentType ? [NSString stringWithUTF8String:argumentType] : nil;
            [argumentTypes addObject:type ? type : @""];
            if (argumentType) free(argumentType);
        }
        _argumentTypeEncodings = argumentTypes;
    }
    if (class_getClassMethod(_cls, _sel)) {
        _methodType = MKClassMethod;
    } else if (class_getInstanceMethod(_cls, _sel)) {
        _methodType = MKInstanceMethod;
    } else {
        _methodType = MKUnknownMethod;
        MKLogFatal(@"Unknown selector [%@]!", _name);
    }
    return self;
}

@end
