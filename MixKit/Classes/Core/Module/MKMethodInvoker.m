//
//  MKMethodInvoker.m
//  MixKit
//
//  Created by liang on 2021/7/26.
//

#import "MKMethodInvoker.h"
#import "MKModuleMethod.h"
#import "MKConvert.h"
#import "MKUtils.h"
#import "MKDefines.h"

@interface MKMethodInvoker ()

@property (nonatomic, strong) MKModuleMethod *method;
@property (nonatomic, copy) NSArray *argumentBlocks;

@end

@implementation MKMethodInvoker

- (instancetype)initWithMethod:(MKModuleMethod *)method {
    self = [super init];
    if (self) {
        _method = method;
        
        [self buildArgumentBlocks];
    }
    return self;
}

#pragma mark - Public Methods
- (NSInvocation *)invokeWithModule:(id)module arguments:(NSArray *)arguments {
    if (arguments.count != self.argumentBlocks.count) {
        MKLogError(@"Wrong number of arguments, module = `%@`, method = `%@`, arguments = %@!",
                           self.method.cls, self.method.name, arguments);
        NSAssert(NO, @"You should have the same number of JS side arguments as native side arguments!");
    }
        
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:self.method.methodSignature];
    invocation.selector = self.method.sel;
    [invocation retainArguments];
    
    // Set arguments
    NSUInteger count = MIN(arguments.count, self.argumentBlocks.count);
    for (NSUInteger index = 0; index < count; index++) {
        id argument = arguments[index];
        id arg = MKNilIfNull(argument);

        void (^block)(NSInvocation *, NSUInteger, id) = self.argumentBlocks[index];
        block(invocation, index + 2, arg);
    }

    @try {
        // Invoke method
        [invocation invokeWithTarget:module];
    } @catch (NSException *exception) {
        NSAssert(NO, @"Invoke module method failed!");
        return nil;
    }
    
    return invocation;
}

#pragma mark - Private Methods
- (void)buildArgumentBlocks {
    NSUInteger numberOfArguments = self.method.argumentTypeEncodings.count;
    NSMutableArray *argumentBlocks = [[NSMutableArray alloc] initWithCapacity:numberOfArguments - 2];
    
    for (NSUInteger index = 2; index < numberOfArguments; index++) {
        NSString *argumentType = self.method.argumentTypeEncodings[index];
        
        __weak typeof(self) weakSelf = self;
        [argumentBlocks addObject:^(NSInvocation *invocation, NSUInteger index, id argument) {
            [weakSelf setArgument:argument argumentType:argumentType toInvocation:invocation atIndex:index];
        }];
    }
    
    self.argumentBlocks = [argumentBlocks copy];
}

- (void)setArgument:(id)argument
       argumentType:(NSString *)argumentType
       toInvocation:(NSInvocation *)invocation
            atIndex:(NSUInteger)index {
#define MK_NUMBER_CONVERT(match, type, func)        \
case match: {                                       \
    type _arg = [MKConvert func:argument];          \
    [invocation setArgument:&_arg atIndex:index];   \
} return
    
    const char *cArgumentType = argumentType.UTF8String;

    switch (cArgumentType[0]) {
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
            if (strcmp("{CGPoint=dd}", cArgumentType) == 0 || strcmp("{CGPoint=ff}", cArgumentType) == 0) {
                CGPoint point = [MKConvert CGPoint:argument];
                [invocation setArgument:&point atIndex:index];
            } else if (strcmp("{CGSize=dd}", cArgumentType) == 0 || strcmp("{CGSize=ff}", cArgumentType) == 0) {
                CGSize size = [MKConvert CGSize:argument];
                [invocation setArgument:&size atIndex:index];
            } else if (strcmp("{CGRect={CGPoint=dd}{CGSize=dd}}", cArgumentType) == 0 ||
                       strcmp("{CGRect={CGPoint=ff}{CGSize=ff}}", cArgumentType) == 0) {
                CGRect rect = [MKConvert CGRect:argument];
                [invocation setArgument:&rect atIndex:index];
            } else if (strcmp("{UIEdgeInsets=dddd}", cArgumentType) == 0 ||
                       strcmp("{UIEdgeInsets=ffff}", cArgumentType) == 0) {
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

@end
