//
//  MKConvertDataModule.m
//  MixKit_Example
//
//  Created by liang on 2021/6/11.
//  Copyright © 2021 liang. All rights reserved.
//

#import "MKConvertDataModule.h"
#import "MKResponseWrapper.h"

@implementation MKConvertDataModule

MK_EXPORT_METHOD(testDictionary, testDictionary:)
MK_EXPORT_METHOD(testString, testString:)
MK_EXPORT_METHOD(testBOOL, testBOOL:)
MK_EXPORT_METHOD(test_Bool, test_Bool:)

#warning NSInvocation 会导致 `浮点型` 精度丢失，并且固定保留小数点后 6 位，建议使用 NSNumber 类型接收
MK_EXPORT_METHOD(testDouble, testDouble:)
MK_EXPORT_METHOD(testLongDouble, testLongDouble:)
MK_EXPORT_METHOD(testFloat, testFloat:)

MK_EXPORT_METHOD(testInt, testInt:)
MK_EXPORT_METHOD(testInt8, testInt8:)
MK_EXPORT_METHOD(testInt16, testInt16:)
MK_EXPORT_METHOD(testInt32, testInt32:)
MK_EXPORT_METHOD(testInt64, testInt64:)
MK_EXPORT_METHOD(testUint8, testUint8:)
MK_EXPORT_METHOD(testUint16, testUint16:)
MK_EXPORT_METHOD(testUint32, testUint32:)
MK_EXPORT_METHOD(testUint64, testUint64:)
MK_EXPORT_METHOD(testCGPoint, testCGPoint:)
MK_EXPORT_METHOD(testCGSize, testCGSize:)
MK_EXPORT_METHOD(testCGRect, testCGRect:)
MK_EXPORT_METHOD(testUIEdgetInsets, testUIEdgetInsets:)
MK_EXPORT_METHOD(testCallbacks, testCallback1:callback2:)

- (void)testDictionary:(NSDictionary *)dict {
    NSLog(@"func = %s, class = %@, value = %@", __func__, [dict class], dict);
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSLog(@"key = %@, value = %@, value class = %@", key, obj, [obj class]);
    }];
}

- (void)testString:(NSString *)string {
    NSLog(@"func = %s, value = %@", __func__, string);
}

- (void)testBOOL:(BOOL)b {
    NSLog(@"func = %s, value = %d", __func__, b);
}

- (void)test_Bool:(_Bool)b {
    NSLog(@"func = %s, value = %d", __func__, b);
}

- (void)testDouble:(double)d {
    // 19.12345678      19.123457
    // -1.987654321     -1.987654
    NSLog(@"func = %s, value = %lf", __func__, d);
}

- (void)testLongDouble:(long double)ld {
    NSLog(@"func = %s, value = %Lf", __func__, ld);
}

- (void)testFloat:(float)f {
    NSLog(@"func = %s, value = %f", __func__, f);
}

- (void)testInt:(int)i {
    NSLog(@"func = %s, value = %d", __func__, i);
}

- (void)testInt8:(int8_t)i8 {
    NSLog(@"func = %s, value = %d", __func__, i8);
}

- (void)testInt16:(int16_t)i16 {
    NSLog(@"func = %s, value = %d", __func__, i16);
}

- (void)testInt32:(int32_t)i32 {
    NSLog(@"func = %s, value = %d", __func__, i32);
}

- (void)testInt64:(int64_t)i64 {
    NSLog(@"func = %s, value = %lld", __func__, i64);
}

- (void)testUint8:(uint8_t)ui8 {
    NSLog(@"func = %s, value = %u", __func__, ui8);
}

- (void)testUint16:(uint16_t)ui16 {
    NSLog(@"func = %s, value = %u", __func__, ui16);
}

- (void)testUint32:(uint32_t)ui32 {
    NSLog(@"func = %s, value = %u", __func__, ui32);
}

- (void)testUint64:(uint64_t)ui64 {
    NSLog(@"func = %s, value = %llu", __func__, ui64);
}

- (void)testCGPoint:(CGPoint)point {
    NSLog(@"func = %s, value = %@, x = %f, y = %f", __func__, NSStringFromCGPoint(point), point.x, point.y);
}

- (void)testCGSize:(CGSize)size {
    NSLog(@"func = %s, value = %@, width = %f, height = %f", __func__, NSStringFromCGSize(size), size.width, size.height);
}

- (void)testCGRect:(CGRect)rect {
    NSLog(@"func = %s, value = %@, {x = %f, y = %f, width = %f, height = %f}", __func__,
          NSStringFromCGRect(rect), rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

- (void)testUIEdgetInsets:(UIEdgeInsets)insets {
    NSLog(@"func = %s, value = %@, {top = %f, left = %f, bottom = %f, right = %f}", __func__,
          NSStringFromUIEdgeInsets(insets), insets.top, insets.left, insets.bottom, insets.right);
}

- (void)testCallback1:(MKResponseCallback)cb1 callback2:(MKResponseCallback)cb2 {
    NSLog(@"func = %s, cb1 = %@, cb2 = %@, cb1 class = %@, cb2 class = %@", __func__, cb1, cb2, [cb1 class], [cb2 class]);
    
    NSDictionary *resp1 = MKResponseMake(MKCallbackCodeSuccess, @"resp1 callback", @{@"req1": @"resp1"});
    !cb1 ?: cb1(@[resp1]);
    
    NSDictionary *resp2 = MKResponseMake(MKCallbackCodeSuccess, @"resp2 callback", @{@"req2": @"resp2"});
    !cb2 ?: cb2(@[resp2]);
}

/*
MK_EXPORT_METHOD(testGroupCase2, testDictionary:array:string:_Bool:double:longdouble:float:int8:int16:int32:int64:uint8:uint16:uint32:uint64:CGPoint:callback2:)
MK_EXPORT_METHOD(testGroupCase3, testDictionary:array:string:CGPoint:CGSize:CGRect:UIEdgeInsets:callback3:i8:i16:string:)

- (void)testDictionary:(NSDictionary *)dict
                 array:(NSArray *)array
                string:(NSString *)string
                 _Bool:(_Bool)_b
                double:(double)d
            longdouble:(long double)longdouble
                 float:(float)f
                 int8:(int8_t)i8
                 int16:(int16_t)i16
                 int32:(int32_t)i32
                 int64:(int64_t)i64
                 uint8:(uint8_t)ui8
                uint16:(uint16_t)ui16
                uint32:(uint32_t)ui32
                uint64:(uint64_t)ui64
               CGPoint:(CGPoint)point
              callback2:(MKResponseCallback)callback {
    NSMutableString *format = [NSMutableString string];
    [format appendFormat:@"\ndictionary = %@,\n", dict];
    [format appendFormat:@"array = %@,\n", array];
    [format appendFormat:@"string = %@,\n", string];
    [format appendFormat:@"_Bool = %d,\n", _b];
    [format appendFormat:@"double = %lf,\n", d];
    [format appendFormat:@"long double = %Lf,\n", longdouble];
    [format appendFormat:@"float = %f,\n", f];
    [format appendFormat:@"int8 = %d,\n", i8];
    [format appendFormat:@"int16 = %d,\n", i16];
    [format appendFormat:@"int32 = %d,\n", i32];
    [format appendFormat:@"int64 = %lld,\n", i64];
    [format appendFormat:@"uint8 = %u,\n", ui8];
    [format appendFormat:@"uint16 = %u,\n", ui16];
    [format appendFormat:@"uint32 = %u,\n", ui32];
    [format appendFormat:@"uint64 = %llu,\n", ui64];
    [format appendFormat:@"CGPoint = %@,\n", NSStringFromCGPoint(point)];
    [format appendFormat:@"callback = %@,\n", callback];
    
    NSLog(@"%s, %@", __func__, format);
    
    NSDictionary *respMap = MKResponseMake(MKCallbackCodeSuccess, @"success", @{});
    !callback ?: callback(@[respMap]);
}

- (void)testDictionary:(NSDictionary *)dict
                 array:(NSArray *)array
                string:(NSString *)string
               CGPoint:(CGPoint)point
                CGSize:(CGSize)size
                CGRect:(CGRect)rect
          UIEdgeInsets:(UIEdgeInsets)insets
             callback3:(MKResponseCallback)callback
                    i8:(int8_t)i8
                   i16:(int16_t)i16
                string:(NSString *)str2 {
    NSMutableString *format = [NSMutableString string];
    [format appendFormat:@"\ndictionary = %@,\n", dict];
    [format appendFormat:@"array = %@,\n", array];
    [format appendFormat:@"string = %@,\n", string];
    [format appendFormat:@"CGPoint = %@,\n", NSStringFromCGPoint(point)];
    [format appendFormat:@"CGSize = %@,\n", NSStringFromCGSize(size)];
    [format appendFormat:@"CGRect = %@,\n", NSStringFromCGRect(rect)];
    [format appendFormat:@"UIEdgeInsets = %@,\n", NSStringFromUIEdgeInsets(insets)];
    [format appendFormat:@"callback = %@,\n", callback];
    [format appendFormat:@"int8 = %d,\n", i8];
    [format appendFormat:@"int16 = %d,\n", i16];
    [format appendFormat:@"str2 = %@,\n", str2];
    
    NSLog(@"%s, %@", __func__, format);
    
    NSDictionary *respMap = MKResponseMake(MKCallbackCodeSuccess, @"success", @{});
    !callback ?: callback(@[respMap]);
}
 */

@end
