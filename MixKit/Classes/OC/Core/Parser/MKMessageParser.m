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
@synthesize callbackID = _callbackID;
@synthesize params = _params;

@end

@implementation MKMessageParser

MK_EXPORT_MESSAGE_PARSER()

@synthesize messageBody = _messageBody;

+ (BOOL)canParse:(id)metaData {
    if (![metaData isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    NSDictionary *dict = (NSDictionary *)metaData;
    return (dict[@"moduleName"] && dict[@"methodName"]);
}

- (instancetype)initWithMetaData:(id)metaData {
    self = [super init];
    if (self) {
        id<MKMessageBody> messageBody = [[MKMessageBody alloc] init];
        
        NSDictionary *dict = (NSDictionary *)metaData;
        messageBody.moduleName = [dict[@"moduleName"] copy];
        messageBody.methodName = [dict[@"methodName"] copy];
        
        messageBody.callbackID = ({
            NSString *callbackID = dict[@"callbackID"];
            if ([callbackID isKindOfClass:[NSNull class]]) {
                callbackID = nil;
            }
            callbackID;
        });
        
        messageBody.params = ({
            NSDictionary *params = dict[@"params"];
            if ([params isKindOfClass:[NSNull class]]) {
                params = nil;
            }
            if (params && ![params isKindOfClass:[NSDictionary class]]) {
                MKLogFatal(@"The argument `params` type error, params = %@!", params);
                params = nil;
            }
            params;
        });
        
        _messageBody = messageBody;
    }
    return self;
}

@end
