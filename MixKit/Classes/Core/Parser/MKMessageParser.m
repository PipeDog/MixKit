//
//  MKMessageParser.m
//  MixKit
//
//  Created by liang on 2020/8/21.
//  Copyright © 2020 liang. All rights reserved.
//

#import "MKMessageParser.h"
#import "MKMessageParserManager.h"
#import "MKDefines.h"

@implementation MKMessageBody

@synthesize moduleName = _moduleName;
@synthesize methodName = _methodName;
@synthesize arguments = _arguments;

- (NSString *)description {
    NSMutableString *fmt = [NSMutableString string];
    [fmt appendFormat:@"{"];
    [fmt appendFormat:@"\n\tmoduleName: %@,", self.moduleName];
    [fmt appendFormat:@"\n\tmethodName: %@", self.methodName];
    [fmt appendFormat:@"\n\targuments: %@", self.arguments];
    [fmt appendFormat:@"\n}"];
    return fmt;
}

@end

@implementation MKMessageParser

MK_EXPORT_MESSAGE_PARSER()

@synthesize messageBody = _messageBody;

+ (BOOL)canParse:(id)metaData {
    if (![metaData isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    NSDictionary *dict = (NSDictionary *)metaData;
    return (dict[@"moduleName"] && dict[@"methodName"] && dict[@"arguments"]);
}

- (instancetype)initWithMetaData:(id)metaData {
    self = [super init];
    if (self) {
        NSDictionary *dict = (NSDictionary *)metaData;
        id<MKMessageBody> messageBody = [[MKMessageBody alloc] init];
        messageBody.moduleName = [dict[@"moduleName"] copy];
        messageBody.methodName = [dict[@"methodName"] copy];
        messageBody.arguments = [dict[@"arguments"] copy];
        _messageBody = messageBody;
    }
    return self;
}

- (NSString *)description {
    return self.messageBody.description;
}

@end
