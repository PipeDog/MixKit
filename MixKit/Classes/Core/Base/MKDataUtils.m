//
//  MKDataUtils.m
//  MixKit
//
//  Created by liang on 2020/10/14.
//  Copyright © 2020 liang. All rights reserved.
//

#import "MKDataUtils.h"

id MKValueToJSONObject(id value) {
    if (!value || [value isKindOfClass:[NSNull class]]) {
        return nil;
    }

    // NSString, NSNumber, NSArray, NSDictionary, or NSNull
    if ([NSJSONSerialization isValidJSONObject:value]) {
        return value;
    }
    
    if ([value isKindOfClass:[NSData class]]) {
        NSJSONReadingOptions options = (NSJSONReadingMutableContainers |
                                        NSJSONReadingMutableLeaves |
                                        NSJSONReadingAllowFragments);
        id JSONObject = [NSJSONSerialization JSONObjectWithData:value options:options  error:nil];
        return JSONObject;
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
        NSJSONReadingOptions options = (NSJSONReadingMutableContainers |
                                        NSJSONReadingMutableLeaves |
                                        NSJSONReadingAllowFragments);
        id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:options error:nil];
        return JSONObject;
    }
        
    MKLogError(@"Convert data to json object error, data class is [%@], data = %@!", [value class], value);
    return nil;
}

NSData *MKValueToData(id value) {
    if (!value || [value isKindOfClass:[NSNull class]]) {
        return nil;
    }

    if ([value isKindOfClass:[NSData class]]) {
        NSData *data = value;
        return data;
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
        return data;
    }
        
    // NSString, NSNumber, NSArray, NSDictionary, or NSNull
    if ([NSJSONSerialization isValidJSONObject:value]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:nil];
        return data;
    }
        
    MKLogError(@"Convert object to `NSData` error, data class is [%@], data = %@!", [value class], value);
    return nil;
}

NSString *MKValueToJSONText(id value) {
    NSData *JSONData = MKValueToData(value);
    NSString *JSONText = JSONData ? [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding] : nil;
    return JSONText;
}
