//
//  MKWebView+Console.m
//  MixKit
//
//  Created by liang on 2021/6/15.
//

#import "MKWebView+Console.h"
#import <objc/runtime.h>
#import "MKConsoleSwitch.h"
#import "MKConsoleView.h"

@interface MKWebView ()

@property (nonatomic, strong, readonly) MKConsoleSwitch *consoleSwitch;
@property (nonatomic, strong, readonly) MKConsoleView *consoleView;

@end

@implementation MKWebView (Console)

- (void)_mk_didUpdateConsoleState:(BOOL)open {
    if (open) {
        [self.consoleSwitch installTo:self];
    } else {
        [self.consoleSwitch uninstall];
        [self.consoleView uninstall];
    }
}

#pragma mark - Event Methods
- (void)_mk_didClickConsoleSwitch:(id)sender {
    [self.consoleView installTo:self];
}

#pragma mark - Setter Methods
- (void)setOpenDebugConsole:(BOOL)openDebugConsole {
    [self _mk_didUpdateConsoleState:openDebugConsole];
    objc_setAssociatedObject(self, @selector(isOpenDebugConsole), @(openDebugConsole), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Getter Methods
- (BOOL)isOpenDebugConsole {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (MKConsoleSwitch *)consoleSwitch {
    MKConsoleSwitch *consoleSwitch = objc_getAssociatedObject(self, _cmd);
    if (!consoleSwitch) {
        consoleSwitch = [[MKConsoleSwitch alloc] init];
        [consoleSwitch addTarget:self action:@selector(_mk_didClickConsoleSwitch:) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject(self, _cmd, consoleSwitch, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return consoleSwitch;
}

- (MKConsoleView *)consoleView {
    MKConsoleView *consoleView = objc_getAssociatedObject(self, _cmd);
    if (!consoleView) {
        consoleView = [[MKConsoleView alloc] init];
        objc_setAssociatedObject(self, _cmd, consoleView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return consoleView;
}

@end
