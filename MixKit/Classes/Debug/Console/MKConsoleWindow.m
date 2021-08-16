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
        [self consoleView];
    }
    return self;
}

- (void)show {
    if (@available(iOS 13.0, *)) {
        UIWindowScene *matchScene = nil;
        
        for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                matchScene = windowScene;
                break;
            }
        }
        
        if (!matchScene) {
            matchScene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.anyObject;
        }
        
        self.windowScene = matchScene;
    }
        
    UIViewController *controller = [[UIViewController alloc] init];
    controller.view.backgroundColor = [UIColor clearColor];
    self.rootViewController = controller;
    self.windowLevel = UIWindowLevelAlert + 1000;
    self.hidden = NO;
    
    [self.consoleSwitch installTo:self];
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
