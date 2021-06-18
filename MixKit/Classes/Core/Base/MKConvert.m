//
//  MKConvert.m
//  MixKit
//
//  Created by liang on 2021/6/10.
//

#import "MKConvert.h"

static inline NSNumber *MKNSNumberCreateFromID(__unsafe_unretained id value);
static void MKConvertCGStructValue(const char *type, NSArray *fields, NSDictionary *aliases, CGFloat *result, id json);

@implementation MKConvert

+ (id)id:(id)meta {
    return meta;
}

+ (BOOL)BOOL:(id)meta {
    NSNumber *number = MKNSNumberCreateFromID(meta);
    return number.boolValue;
}

+ (_Bool)_Bool:(id)meta {
    NSNumber *number = MKNSNumberCreateFromID(meta);
    return number.boolValue;
}

+ (double)double:(id)meta {
    NSNumber *number = MKNSNumberCreateFromID(meta);
    return number.doubleValue;
}

+ (float)float:(id)meta {
    NSNumber *number = MKNSNumberCreateFromID(meta);
    return number.floatValue;
}

+ (int)int:(id)meta {
    NSNumber *number = MKNSNumberCreateFromID(meta);
    return number.intValue;
}

+ (int8_t)int8_t:(id)meta {
    NSNumber *number = MKNSNumberCreateFromID(meta);
    return (int8_t)number.charValue;
}

+ (int16_t)int16_t:(id)meta {
    NSNumber *number = MKNSNumberCreateFromID(meta);
    return number.shortValue;
}

+ (int32_t)int32_t:(id)meta {
    NSNumber *number = MKNSNumberCreateFromID(meta);
    return number.intValue;
}

+ (int64_t)int64_t:(id)meta {
    NSNumber *number = MKNSNumberCreateFromID(meta);
    if ([number isKindOfClass:[NSDecimalNumber class]]) {
        return (int64_t)number.stringValue.longLongValue;
    } else {
        return (uint64_t)number.longLongValue;
    }
}

+ (uint8_t)uint8_t:(id)meta {
    NSNumber *number = MKNSNumberCreateFromID(meta);
    return number.unsignedCharValue;
}

+ (uint16_t)uint16_t:(id)meta {
    NSNumber *number = MKNSNumberCreateFromID(meta);
    return number.unsignedShortValue;
}

+ (uint32_t)uint32_t:(id)meta {
    NSNumber *number = MKNSNumberCreateFromID(meta);
    return number.unsignedIntValue;
}

+ (uint64_t)uint64_t:(id)meta {
    NSNumber *number = MKNSNumberCreateFromID(meta);
    if ([number isKindOfClass:[NSDecimalNumber class]]) {
        return (uint64_t)number.stringValue.longLongValue;
    } else {
        return (uint64_t)number.unsignedLongLongValue;
    }
}

#define MK_CGSTRUCT_CONVERTER(type, values, aliases)    \
+ (type)type:(id)json                                   \
{                                                       \
    static NSArray *fields;                             \
    static dispatch_once_t onceToken;                   \
    dispatch_once(&onceToken, ^{                        \
        fields = values;                                \
    });                                                 \
    type result;                                        \
    MKConvertCGStructValue(#type, fields, aliases, (CGFloat *)&result, json); \
    return result;                                      \
}

MK_CGSTRUCT_CONVERTER(CGPoint, (@[@"x", @"y"]), (@{@"l": @"x", @"t": @"y"}))
MK_CGSTRUCT_CONVERTER(CGSize, (@[@"width", @"height"]), (@{@"w": @"width", @"h": @"height"}))
MK_CGSTRUCT_CONVERTER(CGRect, (@[@"x", @"y", @"width", @"height"]), (@{@"l": @"x", @"t": @"y", @"w": @"width", @"h": @"height"}))
MK_CGSTRUCT_CONVERTER(UIEdgeInsets, (@[@"top", @"left", @"bottom", @"right"]), nil)

@end

/// Parse a number value from 'id'.
static inline NSNumber *MKNSNumberCreateFromID(__unsafe_unretained id value) {
    static NSCharacterSet *dot;
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
        dic = @{@"TRUE" :   @(YES),
                @"True" :   @(YES),
                @"true" :   @(YES),
                @"FALSE" :  @(NO),
                @"False" :  @(NO),
                @"false" :  @(NO),
                @"YES" :    @(YES),
                @"Yes" :    @(YES),
                @"yes" :    @(YES),
                @"NO" :     @(NO),
                @"No" :     @(NO),
                @"no" :     @(NO),
                @"NIL" :    (id)kCFNull,
                @"Nil" :    (id)kCFNull,
                @"nil" :    (id)kCFNull,
                @"NULL" :   (id)kCFNull,
                @"Null" :   (id)kCFNull,
                @"null" :   (id)kCFNull,
                @"(NULL)" : (id)kCFNull,
                @"(Null)" : (id)kCFNull,
                @"(null)" : (id)kCFNull,
                @"<NULL>" : (id)kCFNull,
                @"<Null>" : (id)kCFNull,
                @"<null>" : (id)kCFNull};
    });
    
    if (!value || value == (id)kCFNull) return nil;
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) {
        NSNumber *num = dic[value];
        if (num) {
            if (num == (id)kCFNull) return nil;
            return num;
        }
        if ([(NSString *)value rangeOfCharacterFromSet:dot].location != NSNotFound) {
            const char *cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            double num = atof(cstring);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        } else {
            const char *cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            return @(atoll(cstring));
        }
    }
    return nil;
}

// TODO: normalise the use of w/width so we can do away with the alias values (#6566645)
static void MKConvertCGStructValue(const char *type, NSArray *fields, NSDictionary *aliases, CGFloat *result, id json) {
    NSUInteger count = fields.count;
    if ([json isKindOfClass:[NSArray class]]) {
        if ([json count] != count) {
            MKLogError(@"Expected array with count %zd, but count is %zd: %@", count, [json count], json);
        } else {
            for (NSUInteger i = 0; i < count; i++) {
                result[i] = [MKConvert double:json[i]];
            }
        }
    } else if ([json isKindOfClass:[NSDictionary class]]) {
        if (aliases.count) {
            json = [json mutableCopy];
            for (NSString *alias in aliases) {
                NSString *key = aliases[alias];
                NSNumber *number = json[alias];
                if (number) {
                    MKLogWarn(@"Using deprecated '%@' property for '%s'. Use '%@' instead.", alias, type, key);
                    ((NSMutableDictionary *)json)[key] = number;
                }
            }
        }
        for (NSUInteger i = 0; i < count; i++) {
            result[i] = [MKConvert double:json[fields[i]]];
        }
    } else if (json && json != (id)kCFNull) {
        MKLogError(json, type);
    }
}
