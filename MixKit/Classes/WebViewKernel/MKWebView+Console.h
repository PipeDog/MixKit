//
//  MKWebView+Console.h
//  MixKit
//
//  Created by liang on 2021/6/15.
//

#import "MKWebView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKWebView (Console)

/// @brief 是否打开调试控制台
@property (nonatomic, assign, getter=isOpenDebugConsole) BOOL openDebugConsole;

@end

NS_ASSUME_NONNULL_END
