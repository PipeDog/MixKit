//
//  MKConsoleView.h
//  MixKit
//
//  Created by liang on 2021/6/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKConsoleView : UIView

- (void)installTo:(UIView *)superview;
- (void)uninstall;

@end

NS_ASSUME_NONNULL_END
