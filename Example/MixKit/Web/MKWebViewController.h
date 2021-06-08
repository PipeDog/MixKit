//
//  MKWebViewController.h
//  MixKit_Example
//
//  Created by liang on 2021/6/8.
//  Copyright © 2021 liang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MixKit.h>
#import <MKWebView.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKWebViewController : UIViewController

@property (nonatomic, strong, readonly) MKWebView *webView;

- (void)loadURL:(NSURL *)URL;

- (void)goBack;
- (void)forceGoBack;

- (void)reload;
- (void)reloadFromOrigin;

@end

NS_ASSUME_NONNULL_END
