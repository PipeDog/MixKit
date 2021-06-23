//
//  MKConsoleWindow.h
//  MixKit
//
//  Created by liang on 2021/6/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKConsoleWindow : UIWindow

@property (class, strong, readonly) MKConsoleWindow *sharedInstance;

- (void)show;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
