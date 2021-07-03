//
//  MKConsoleView.m
//  MixKit
//
//  Created by liang on 2021/6/15.
//

#import "MKConsoleView.h"
#import "NSString+MKAdd.h"
#import "MKModuleManager.h"
#import "MKDataUtils.h"
#import "UIView+MKAdd.h"

typedef NS_ENUM(NSUInteger, MKConsoleType) {
    MKConsoleTypeDebugLog = 0,
    MKConsoleTypeExpInfos = 1,
    MKConsoleTypePerfLogs = 2,
};

static inline NSString *MKGetConsoleTypeName(MKConsoleType type) {
    switch (type) {
        case MKConsoleTypeDebugLog: return @"调试日志";
        case MKConsoleTypeExpInfos: return @"导出信息";
        case MKConsoleTypePerfLogs: return @"性能日志";
        default: return @"";
    }
}

static inline NSString *MKLogGetFlag(MKLogLevel level) {
    switch (level) {
        case MKLogLevelDebug: return @"Debug";
        case MKLogLevelInfo: return @"Info";
        case MKLogLevelWarn: return @"Warn";
        case MKLogLevelError: return @"Error";
        case MKLogLevelFatal: return @"Fatal";
        default: return @"Unknown";
    }
}

static inline UIColor *MKLogGetColor(MKLogLevel level) {
    switch (level) {
        case MKLogLevelDebug: return [UIColor lightGrayColor];
        case MKLogLevelInfo: return [UIColor whiteColor];
        case MKLogLevelWarn: return [UIColor yellowColor];
        case MKLogLevelError: return [UIColor orangeColor];
        case MKLogLevelFatal: return [UIColor redColor];
        default: return [UIColor whiteColor];
    }
}

static inline MKLogLevel MKLogGetLevel(NSString *log) {
    if ([log containsString:@"[Debug]"]) {
        return MKLogLevelDebug;
    } else if ([log containsString:@"[Info]"]) {
        return MKLogLevelInfo;
    } else if ([log containsString:@"[Warn]"]) {
        return MKLogLevelWarn;
    } else if ([log containsString:@"[Error]"]) {
        return MKLogLevelError;
    } else if ([log containsString:@"[Fatal]"]) {
        return MKLogLevelFatal;
    }
    return MKLogLevelInfo;
}

@interface MKLogRecordCell : UITableViewCell

@property (nonatomic, strong) UILabel *contentLabel;

- (void)setText:(NSString *)text level:(MKLogLevel)level;

+ (CGFloat)cellHeightByText:(NSString *)text;

@end

@implementation MKLogRecordCell

+ (CGFloat)cellHeightByText:(NSString *)text {
    if (!text.length) { return 0.f; }
    
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds) - 15.f * 2;
    return [text mk_heightForFont:[UIFont systemFontOfSize:12] width:width] + 5.f * 2;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupInitializeConfiguration];
        [self createViewHierarchy];
        [self layoutContentViews];
    }
    return self;
}

- (void)setupInitializeConfiguration {
    self.backgroundColor = [UIColor blackColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)createViewHierarchy {
    [self.contentView addSubview:self.contentLabel];
}

- (void)layoutContentViews {
    [NSLayoutConstraint activateConstraints:@[
        [self.contentLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:5.f],
        [self.contentLabel.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor constant:15.f],
        [self.contentLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-5.f],
        [self.contentLabel.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor constant:-15.f],
    ]];
}

#pragma mark - Public Methods
- (void)setText:(NSString *)text level:(MKLogLevel)level {
    self.contentLabel.text = text ?: @"";
    self.contentLabel.textColor = MKLogGetColor(level);
}

#pragma mark - Getter Methods
- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textColor = [UIColor whiteColor];
        _contentLabel.font = [UIFont systemFontOfSize:12];
        _contentLabel.numberOfLines = 0;
        _contentLabel.backgroundColor = [UIColor blackColor];
        _contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _contentLabel;
}

@end

@interface MKLogRecordView : UIView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSString *> *records;

- (void)addRecord:(NSString *)record;
- (void)addRecords:(NSArray<NSString *> *)records;

@end

@implementation MKLogRecordView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupInitializeConfiguration];
        [self createViewHierarchy];
        [self layoutContentViews];
    }
    return self;
}

- (void)setupInitializeConfiguration {
    self.backgroundColor = [UIColor blackColor];
}

- (void)createViewHierarchy {
    [self addSubview:self.tableView];
}

- (void)layoutContentViews {
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.widthAnchor constraintEqualToAnchor:self.widthAnchor],
        [self.tableView.heightAnchor constraintEqualToAnchor:self.heightAnchor],
        [self.tableView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.tableView.leftAnchor constraintEqualToAnchor:self.leftAnchor],
    ]];
}

#pragma mark - Public Methods
- (void)addRecord:(NSString *)record {
    [self.records addObject:record ?: @""];
    [self.tableView reloadData];
}

- (void)addRecords:(NSArray<NSString *> *)records {
    [self.records addObjectsFromArray:records ?: @[]];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.records.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = self.records[indexPath.row];
    return [MKLogRecordCell cellHeightByText:text];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKLogRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MKLogRecordCell class]) forIndexPath:indexPath];
    NSString *text = self.records[indexPath.row];
    [cell setText:text level:MKLogGetLevel(text)];
    return cell;
}

#pragma mark - Getter Methods
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor blackColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.showsVerticalScrollIndicator = YES;
        
        [_tableView registerClass:[MKLogRecordCell class] forCellReuseIdentifier:NSStringFromClass([MKLogRecordCell class])];
    }
    return _tableView;
}

- (NSMutableArray<NSString *> *)records {
    if (!_records) {
        _records = [NSMutableArray array];
    }
    return _records;
}

@end

@interface MKConsoleView () <MKLogListener, MKPerfMonitorDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, strong) NSMutableArray<MKLogRecordView *> *recordViews;
@property (nonatomic, strong) NSMutableArray<UIButton *> *consoleTypeButtons;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation MKConsoleView

- (void)dealloc {
    [[MKLogger defaultLogger] removeListener:self];
    [[MKPerfMonitor defaultMonitor] unbind:self];
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    CGRect rect = CGRectMake(0.f, 130.f, CGRectGetWidth([UIScreen mainScreen].bounds), 300.f);
    self = [super initWithFrame:rect];
    if (self) {
        [self setupInitializeConfiguration];
        [self createViewHierarchy];
        [self layoutContentViews];
        
        [self loadExportNativeModules];
        [self openConsoleViewWithType:MKConsoleTypeDebugLog];
    }
    return self;
}

- (void)setupInitializeConfiguration {
    self.backgroundColor = [UIColor blackColor];
    
    for (MKConsoleType type = MKConsoleTypeDebugLog; type <= MKConsoleTypePerfLogs; type++) {
        MKLogRecordView *recordView = [[MKLogRecordView alloc] initWithFrame:CGRectZero];
        recordView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.recordViews addObject:recordView];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.layer.borderWidth = 1.f;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        [button setTitle:MKGetConsoleTypeName(type) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(didClickConsoleTypeButton:) forControlEvents:UIControlEventTouchUpInside];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [self.consoleTypeButtons addObject:button];
    }
    
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureAction:)];
    [self addGestureRecognizer:_pan];

    [[MKLogger defaultLogger] addListener:self];
    [[MKPerfMonitor defaultMonitor] bind:self];
}

- (void)createViewHierarchy {
    for (MKConsoleType type = MKConsoleTypeDebugLog; type <= MKConsoleTypePerfLogs; type++) {
        MKLogRecordView *recordView = self.recordViews[type];
        [self addSubview:recordView];

        UIButton *button = self.consoleTypeButtons[type];
        [self addSubview:button];
    }
    
    [self addSubview:self.closeButton];
}

- (void)layoutContentViews {
    CGFloat const consoleTypeButtonWidth = 90.f;
    CGFloat const consoleTypeButtonHeight = 40.f;
    
    for (MKConsoleType type = MKConsoleTypeDebugLog; type <= MKConsoleTypePerfLogs; type++) {
        MKLogRecordView *recordView = self.recordViews[type];
        UIButton *button = self.consoleTypeButtons[type];
        
        [NSLayoutConstraint activateConstraints:@[
            [recordView.topAnchor constraintEqualToAnchor:self.topAnchor constant:5.f],
            [recordView.leftAnchor constraintEqualToAnchor:self.leftAnchor],
            [recordView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-(consoleTypeButtonHeight + 5.f)],
            [recordView.rightAnchor constraintEqualToAnchor:self.rightAnchor],
        ]];
        
        [NSLayoutConstraint activateConstraints:@[
            [button.widthAnchor constraintEqualToConstant:consoleTypeButtonWidth],
            [button.heightAnchor constraintEqualToConstant:consoleTypeButtonHeight],
            [button.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:type * consoleTypeButtonWidth],
            [button.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        ]];
    }
    
    [NSLayoutConstraint activateConstraints:@[
        [self.closeButton.widthAnchor constraintEqualToConstant:40.f],
        [self.closeButton.heightAnchor constraintEqualToConstant:40.f],
        [self.closeButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:5.f],
        [self.closeButton.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-5.f],
    ]];
}

- (void)loadExportNativeModules {
    NSDictionary *config = [MKModuleManager defaultManager].injectJSConfig;
    
    [config enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSDictionary *dict = @{key: obj};
        NSString *json = MKValueToJSONText(dict);
        MKLogRecordView *recordView = self.recordViews[MKConsoleTypeExpInfos];
        [recordView addRecord:json];
    }];
}

- (void)openConsoleViewWithType:(MKConsoleType)type {
    MKLogRecordView *recordView = self.recordViews[type];
    [self bringSubviewToFront:recordView];
    [self bringSubviewToFront:self.closeButton];
}

#pragma mark - Event Methods
- (void)didClickConsoleTypeButton:(UIButton *)sender {
    MKConsoleType consoleType = [self.consoleTypeButtons indexOfObject:sender];
    MKLogRecordView *recordView = self.recordViews[consoleType];
    [self bringSubviewToFront:recordView];
    [self bringSubviewToFront:self.closeButton];
}

- (void)didClickCloseButton:(id)sender {
    [self uninstall];
}

- (void)handlePanGestureAction:(UIPanGestureRecognizer *)pan {
    CGFloat const kConsoleMargin = 5.f;
    UIView *superview = self.superview;
    CGPoint point = [pan translationInView:superview];
    
    self.centerY = self.center.y + point.y;
    [pan setTranslation:CGPointZero inView:superview];
    
    void (^fixRectHandler)(void) = ^{
        if (self.top < kConsoleMargin) {
            self.top = kConsoleMargin;
        }
        if (self.bottom > self.superview.height - kConsoleMargin) {
            self.bottom = self.superview.height - kConsoleMargin;
        }
    };
    
    if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateChanged) {
        [UIView animateWithDuration:0.3f animations:^{
            fixRectHandler();
        }];
    }
}

#pragma mark - MKLogListener
- (void)logMessage:(NSString *)message
             level:(MKLogLevel)level
              file:(const char *)file
              func:(const char *)func
              line:(NSUInteger)line {
    NSString *formattedLog = [NSString stringWithFormat:@"%@ [%@][%@] %@",
                              [self.dateFormatter stringFromDate:[NSDate date]],
                              MKLogGetFlag(level),
                              [NSString stringWithUTF8String:func],
                              message];
    
    MKLogRecordView *recordView = self.recordViews[MKConsoleTypeDebugLog];
    [recordView addRecord:formattedLog];
}

#pragma mark - MKPerfMonitorDelegate
- (void)perfMonitor:(MKPerfMonitor *)perfMonitor flushAllPerfRecords:(NSArray<NSDictionary *> *)perfRecords {
    MKLogRecordView *recordView = self.recordViews[MKConsoleTypePerfLogs];
    
    for (NSDictionary *perfRecord in perfRecords) {
        NSString *text = MKValueToJSONText(perfRecord);
        [recordView addRecord:text];
    }
}

#pragma mark - Public Methods
- (void)installTo:(UIView *)superview {
    if (superview) {
        [superview addSubview:self];
    } else {
        [self uninstall];
    }
}

- (void)uninstall {
    [self removeFromSuperview];
}

#pragma mark - Getter Methods
- (NSMutableArray<MKLogRecordView *> *)recordViews {
    if (!_recordViews) {
        _recordViews = [NSMutableArray array];
    }
    return _recordViews;
}

- (NSMutableArray<UIButton *> *)consoleTypeButtons {
    if (!_consoleTypeButtons) {
        _consoleTypeButtons = [NSMutableArray array];
    }
    return _consoleTypeButtons;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setTitle:@"+" forState:UIControlStateNormal];
        _closeButton.transform = CGAffineTransformMakeRotation(M_PI_4);
        _closeButton.titleLabel.font = [UIFont systemFontOfSize:36];
        [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(didClickCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _closeButton;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeZone = [NSTimeZone systemTimeZone];
        _dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm:ss.SSSZ";
    }
    return _dateFormatter;
}

@end
