//
//  MKMessageParserManager.m
//  MixKit
//
//  Created by liang on 2020/8/21.
//  Copyright © 2020 liang. All rights reserved.
//

#import "MKMessageParserManager.h"

static NSMutableArray *MKMessageParserClasses;
static inline NSArray *MKGetParserClasses(void) {
    return MKMessageParserClasses;
}

void MKRegisterMessageParser(Class parserClass) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MKMessageParserClasses = [NSMutableArray array];
    });
        
    if (![parserClass conformsToProtocol:@protocol(MKMessageParser)]) {
        NSCAssert(NO, @"%@ does not conform to the `MKMessageParser` protocol",
                  NSStringFromClass(parserClass));
        return;
    }
    
    // Register parser
    [MKMessageParserClasses addObject:parserClass];
}

@implementation MKMessageParserManager {
    NSArray<id<MKMessageParser>> *_parserClasses;
}

+ (MKMessageParserManager *)defaultManager {
    static MKMessageParserManager *__defaultManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __defaultManager = [[self alloc] init];
    });
    return __defaultManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _parserClasses = MKGetParserClasses();
    }
    return self;
}

#pragma mark - Public Methods
- (id<MKMessageParser>)parserWithMetaData:(id)metaData {
    for (Class aClass in _parserClasses) {
        if (![aClass canParse:metaData]) {
            continue;
        }
        
        id<MKMessageParser> parser = [[aClass alloc] initWithMetaData:metaData];
        return parser;
    }
    
    MKLogError(@"Match parser failed, metaData = %@!", metaData);
    return nil;
}

@end
