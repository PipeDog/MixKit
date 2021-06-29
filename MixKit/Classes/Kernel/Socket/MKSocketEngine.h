//
//  MKSocketEngine.h
//  MoonBridge
//
//  Created by liang on 2021/6/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKSocketEngine <NSObject>

- (BOOL)sendData:(id)data error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
