//
//  MKConvert.h
//  MixKit
//
//  Created by liang on 2021/6/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKConvert : NSObject

+ (id)id:(id)meta; // '@'

+ (BOOL)BOOL:(id)meta; // 'B'
+ (_Bool)_Bool:(id)meta; // 'B'

+ (double)double:(id)meta; // 'd', @encode(long double) == 'D'
+ (float)float:(id)meta; // 'f'

+ (int)int:(id)meta; // 'i'
+ (int8_t)int8_t:(id)meta; // 'c'
+ (int16_t)int16_t:(id)meta; // 's'
+ (int32_t)int32_t:(id)meta; // 'i'
+ (int64_t)int64_t:(id)meta; // 'q'

+ (uint8_t)uint8_t:(id)meta; // 'C'
+ (uint16_t)uint16_t:(id)meta; // 'S'
+ (uint32_t)uint32_t:(id)meta; // 'I'
+ (uint64_t)uint64_t:(id)meta; // 'Q'

+ (CGPoint)CGPoint:(id)meta; // 32bit {CGPoint=ff}, 64bit {CGPoint=dd}
+ (CGSize)CGSize:(id)meta; // 32bit {CGSize=ff}, 64bit {CGSize=dd}
+ (CGRect)CGRect:(id)meta; // 32bit {CGRect={CGPoint=ff}{CGSize=ff}}, 64bit {CGRect={CGPoint=dd}{CGSize=dd}}
+ (UIEdgeInsets)UIEdgeInsets:(id)meta; // 32bit {UIEdgeInsets=ffff}, 64bit {UIEdgeInsets=dddd}

@end

NS_ASSUME_NONNULL_END
