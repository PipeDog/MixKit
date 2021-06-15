//
//  MKWebViewController.m
//  MixKit_Example
//
//  Created by liang on 2021/6/8.
//  Copyright © 2021 liang. All rights reserved.
//

#import "MKWebViewController.h"
#import "MKWebView+Console.h"

@interface MKWebViewController () <WKNavigationDelegate, MKWebViewBridgeHandler>

@property (nonatomic, strong) MKWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation MKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self addUserCookieScript];
}

#pragma mark - Public Methods
- (void)loadURL:(NSURL *)URL {
    if (!URL.absoluteString.length) {
        return;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [self.webView loadRequest:request];
}

- (void)goBack {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)forceGoBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reload {
    [self.webView reload];
}

- (void)reloadFromOrigin {
    [self.webView reloadFromOrigin];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    self.activityIndicatorView.hidden = NO;
    [self.activityIndicatorView startAnimating];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden = YES;
    
    // Handle error...
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden = YES;
}

#pragma mark - MKWebViewBridgeHandler
- (BOOL)webView:(MKWebView *)webView didReceiveScriptMessage:(WKScriptMessage *)message {
    return NO;
}

- (void)webView:(MKWebView *)webView didFailParseMessage:(WKScriptMessage *)message {
    NSLog(@"parse message failed! message.name = %@, message.body = %@", message.name, message.body);
}

#pragma mark - Tool Methods
- (void)addUserCookieScript {
#warning Get cookie here...
    NSHTTPCookie *userCookie = nil;
    if (!userCookie.value) {
        return;
    }
    
    NSString *cookieScriptString = [NSString stringWithFormat:@"document.cookie='%@=%@';document.cookie='Domain=%@';document.cookie='Expires=%@';",
                                    userCookie.name,
                                    userCookie.value,
                                    userCookie.domain,
                                    userCookie.expiresDate];
    WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:cookieScriptString
                                                        injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                     forMainFrameOnly:NO];
    WKWebViewConfiguration *configuration = self.webView.configuration;
    [configuration.userContentController addUserScript:cookieScript];
}

#pragma mark - Getter Methods
- (MKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        
        _webView = [[MKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
        _webView.navigationDelegate = self;
        _webView.openDebugConsole = YES;
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.hidden = YES;
        [self.webView addSubview:_activityIndicatorView];
        
        CGSize size = CGSizeMake(100.f, 100.f);
        CGRect rect = CGRectMake((CGRectGetWidth(self.view.bounds) - size.width) / 2.f,
                                 (CGRectGetHeight(self.view.bounds) - size.height) / 2.f,
                                 size.width,
                                 size.height);
        _activityIndicatorView.frame = rect;
    }
    return _activityIndicatorView;
}

@end
