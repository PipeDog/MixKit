//
//  MKConsoleSwitch.m
//  MixKit
//
//  Created by liang on 2021/6/15.
//

#import "MKConsoleSwitch.h"
#import "UIView+MKAdd.h"

@interface MKConsoleSwitch ()

@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation MKConsoleSwitch

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    CGRect rect = CGRectMake(100.f, 100.f, 60.f, 60.f);
    self = [super initWithFrame:rect];
    if (self) {
        [self setupInitializeConfiguration];
        [self createViewHierarchy];
        [self layoutContentViews];
    }
    return self;
}

- (void)setupInitializeConfiguration {
    self.backgroundColor = [UIColor clearColor];
    self.textLabel.text = @"Mix";
    
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureAction:)];
    [self addGestureRecognizer:_pan];
}

- (void)createViewHierarchy {
    [self addSubview:self.shadowView];
    [self addSubview:self.textLabel];
}

- (void)layoutContentViews {
    [NSLayoutConstraint activateConstraints:@[
        [self.shadowView.widthAnchor constraintEqualToConstant:self.diameter],
        [self.shadowView.heightAnchor constraintEqualToConstant:self.diameter],
        [self.shadowView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.shadowView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
    ]];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.textLabel.widthAnchor constraintEqualToConstant:self.diameter],
        [self.textLabel.heightAnchor constraintEqualToConstant:self.diameter],
        [self.textLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.textLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
    ]];
}

#pragma mark - Event Methods
- (void)handlePanGestureAction:(UIPanGestureRecognizer *)pan {
    CGFloat const kConsoleSwitchMargin = 5.f;
    UIView *superview = self.superview;
    CGPoint point = [pan translationInView:superview];
    
    self.center = CGPointMake(self.center.x + point.x, self.center.y + point.y);
    [pan setTranslation:CGPointZero inView:superview];
    
    void (^fixRectHandler)(void) = ^{
        if (self.top < kConsoleSwitchMargin) {
            self.top = kConsoleSwitchMargin;
        }
        if (self.left < kConsoleSwitchMargin) {
            self.left = kConsoleSwitchMargin;
        }
        if (self.bottom > self.superview.height - kConsoleSwitchMargin) {
            self.bottom = self.superview.height - kConsoleSwitchMargin;
        }
        if (self.right > self.superview.width - kConsoleSwitchMargin) {
            self.right = self.superview.width - kConsoleSwitchMargin;
        }
    };
    
    if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateChanged) {
        [UIView animateWithDuration:0.3f animations:^{
            fixRectHandler();
        }];
    }
}

#pragma mark - Public Methods
- (void)installTo:(UIView *)superview {
    if (superview) {
        CGRect rect = CGRectMake(CGRectGetWidth(superview.bounds) - 60.f - 5.f,
                                 CGRectGetHeight(superview.bounds) - 60.f - 100.f,
                                 60.f,
                                 60.f);
        self.frame = rect;
        [superview addSubview:self];
    } else {
        [self uninstall];
    }
}

- (void)uninstall {
    [self removeFromSuperview];
}

#pragma mark - Getter Methods
- (UIView *)shadowView {
    if (!_shadowView) {
        _shadowView = [[UIView alloc] init];
        _shadowView.backgroundColor = [UIColor clearColor];
        _shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        _shadowView.layer.shadowOffset = CGSizeMake(1.f, 1.f);
        _shadowView.layer.shadowOpacity = 0.8f;
        _shadowView.layer.shadowRadius = 3.f;
        _shadowView.layer.cornerRadius = self.diameter / 2.f;
        _shadowView.translatesAutoresizingMaskIntoConstraints = NO;
        _shadowView.userInteractionEnabled = NO;
        
        CGRect rect = CGRectMake(0.f, 0.f, self.diameter, self.diameter);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.diameter / 2.f];
        _shadowView.layer.shadowPath = path.CGPath;
    }
    return _shadowView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = [UIColor colorWithRed:6.f / 255.f green:58.f / 255.f blue:109.f / 255.f alpha:1.f];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = [UIFont boldSystemFontOfSize:20];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel.layer.cornerRadius = self.diameter / 2.f;
        _textLabel.clipsToBounds = YES;
        _textLabel.userInteractionEnabled = NO;
    }
    return _textLabel;
}

- (CGFloat)diameter {
    return 50.f;
}

@end
