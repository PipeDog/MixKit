//
//  MKConsoleWindow.m
//  MixKit
//
//  Created by liang on 2021/6/23.
//

#import "MKConsoleWindow.h"
#import "MKConsoleSwitch.h"
#import "MKConsoleView.h"

@interface MKConsoleWindow ()

@property (nonatomic, strong) MKConsoleSwitch *consoleSwitch;
@property (nonatomic, strong) MKConsoleView *consoleView;

@end

@implementation MKConsoleWindow

+ (MKConsoleWindow *)sharedInstance {
    static MKConsoleWindow *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    return __sharedInstance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Do nothing...
    }
    return self;
}

- (void)show {
    
#if defined(__IPHONE_13_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
    BOOL matchScene = NO;
    
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                self.windowScene = windowScene;
                matchScene = YES;
                break;
            }
        }
    }
    
    if (!matchScene) {
        NSAssert(NO, @"Match scene failed, delay show console window in launch task!");
        return;
    }
#endif
        
    UIViewController *controller = [[UIViewController alloc] init];
    controller.view.backgroundColor = [UIColor clearColor];
    self.rootViewController = controller;
    self.windowLevel = UIWindowLevelAlert + 1000;
    self.hidden = NO;
    
    [self.consoleSwitch installTo:self];
    [self consoleView]; // lazy load
}

- (void)hide {
    self.hidden = YES;
}

#pragma mark - Override Methods
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.userInteractionEnabled
        || self.isHidden
        || self.alpha <= 0.01f
        || ![self pointInside:point withEvent:event]) {
        return nil;
    }
    
    __block UIView *responder = nil;
    NSArray<UIView *> *subviews = [self.subviews copy];
    [subviews enumerateObjectsWithOptions:NSEnumerationReverse
                               usingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint convertPoint = [self convertPoint:point toView:obj];
        responder = [obj hitTest:convertPoint withEvent:event];
        if (responder) {
            *stop = YES;
        }
    }];

    BOOL shouldResponse = (responder != self.rootViewController.view);
    return shouldResponse ? responder : nil;
}

#pragma mark - Event Methods
- (void)didClickConsoleSwitch:(id)sender {
    if (self.consoleView.superview) {
        [self.consoleView uninstall];
    } else {
        [self.consoleView installTo:self];
    }
}

#pragma mark - Getter Methods
- (MKConsoleSwitch *)consoleSwitch {
    if (!_consoleSwitch) {
        _consoleSwitch = [[MKConsoleSwitch alloc] init];
        [_consoleSwitch addTarget:self action:@selector(didClickConsoleSwitch:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _consoleSwitch;
}

- (MKConsoleView *)consoleView {
    if (!_consoleView) {
        _consoleView = [[MKConsoleView alloc] init];
    }
    return _consoleView;
}

@end
