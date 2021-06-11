//
//  MKModuleMethod+Invoke.m
//  MixKit
//
//  Created by liang on 2021/6/10.
//

#import "MKModuleMethod+Invoke.h"
#import "MKConvert.h"
#import "MKUtils.h"
#import <objc/runtime.h>
#import "MKDefines.h"

@interface MKModuleMethod ()

@property (nonatomic, copy) NSArray *argumentBlocks;

@end

@implementation MKModuleMethod (Invoke)

- (void)mk_invokeWithModule:(id)module arguments:(NSArray *)arguments {
    [self _mk_buildArgumentBlocksIfNeeded];

    if (arguments.count != self.argumentBlocks.count) {
        MKLogError(@"Wrong number of arguments, check it!");
        return;
    }
        
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:self.methodSignature];
    invocation.selector = self.sel;
    [invocation retainArguments];
    
    // Set arguments
    NSUInteger count = arguments.count;
    for (NSUInteger index = 0; index < count; index++) {
        id argument = arguments[index];
        id arg = MKNilIfNull(argument);

        void (^block)(NSInvocation *, NSUInteger, id) = self.argumentBlocks[index];
        block(invocation, index + 2, arg);
    }
    
    // Invoke method
    [invocation invokeWithTarget:module];
}

#pragma mark - Internal Methods
- (void)_mk_buildArgumentBlocksIfNeeded {
    if (self.argumentBlocks.count > 0) {
        return;
    }
    
    NSUInteger numberOfArguments = self.argumentTypeEncodings.count;
    NSMutableArray *argumentBlocks = [[NSMutableArray alloc] initWithCapacity:numberOfArguments - 2];
    
    for (NSUInteger index = 2; index < numberOfArguments; index++) {
        const char *argumentType = self.argumentTypeEncodings[index].UTF8String;
        
        __weak typeof(self) weakSelf = self;
        [argumentBlocks addObject:^(NSInvocation *invocation, NSUInteger index, id argument) {
            [weakSelf _mk_setArgument:argument argumentType:argumentType toInvocation:invocation atIndex:index];
        }];
    }
    
    self.argumentBlocks = [argumentBlocks copy];
}

- (void)_mk_setArgument:(id)argument
           argumentType:(const char *)argumentType
           toInvocation:(NSInvocation *)invocation
                atIndex:(NSUInteger)index {
#define MK_NUMBER_CONVERT(match, type, func) \
case match: { \
    type _arg = [MKConvert func:argument]; \
    [invocation setArgument:&_arg atIndex:index]; \
} return
    
    switch (argumentType[0]) {
        case '@': {
            // @encode(block) == "@?", also hits current case '@'
            [invocation setArgument:&argument atIndex:index];
        } return;
            
        MK_NUMBER_CONVERT('B', BOOL, BOOL);
        MK_NUMBER_CONVERT('d', double, double);            
        MK_NUMBER_CONVERT('f', float, float);
        MK_NUMBER_CONVERT('c', int8_t, int8_t);
        MK_NUMBER_CONVERT('s', int16_t, int16_t);
        MK_NUMBER_CONVERT('i', int32_t, int32_t);
        MK_NUMBER_CONVERT('q', int64_t, int64_t);
        MK_NUMBER_CONVERT('C', uint8_t, uint8_t);
        MK_NUMBER_CONVERT('S', uint16_t, uint16_t);
        MK_NUMBER_CONVERT('I', uint32_t, uint32_t);
        MK_NUMBER_CONVERT('Q', uint64_t, uint64_t);
        MK_NUMBER_CONVERT('D', long double, double);
        
        case '{': {
            if (strcmp("{CGPoint=dd}", argumentType) == 0 || strcmp("{CGPoint=ff}", argumentType) == 0) {
                CGPoint point = [MKConvert CGPoint:argument];
                [invocation setArgument:&point atIndex:index];
            } else if (strcmp("{CGSize=dd}", argumentType) == 0 || strcmp("{CGSize=ff}", argumentType) == 0) {
                CGSize size = [MKConvert CGSize:argument];
                [invocation setArgument:&size atIndex:index];
            } else if (strcmp("{CGRect={CGPoint=dd}{CGSize=dd}}", argumentType) == 0 ||
                       strcmp("{CGRect={CGPoint=ff}{CGSize=ff}}", argumentType) == 0) {
                CGRect rect = [MKConvert CGRect:argument];
                [invocation setArgument:&rect atIndex:index];
            } else if (strcmp("{UIEdgeInsets=dddd}", argumentType) == 0 ||
                       strcmp("{UIEdgeInsets=ffff}", argumentType) == 0) {
                UIEdgeInsets insets = [MKConvert UIEdgeInsets:argument];
                [invocation setArgument:&insets atIndex:index];
            } else {
                NSAssert(NO, @"Unsupport argument type, argument = %@!", argument);
            }
        } return;
        
        default: {
            NSAssert(NO, @"Unsupport argument type, argument = %@!", argument);
        } return;
    }
}

#pragma mark - Setter Methods
- (void)setArgumentBlocks:(NSArray *)argumentBlocks {
    objc_setAssociatedObject(self, @selector(argumentBlocks), argumentBlocks, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - Getter Methods
- (NSArray *)argumentBlocks {
    return objc_getAssociatedObject(self, _cmd);
}

@end
