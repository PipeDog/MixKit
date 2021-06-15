//
//  MKViewController.m
//  MixKit
//
//  Created by liang on 06/08/2021.
//  Copyright (c) 2021 liang. All rights reserved.
//

#import "MKViewController.h"
#import "MKWebViewController.h"
#import <MixKit.h>
#import <MKWebViewKernel.h>

@interface MKViewController ()

@end

@implementation MKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [MKWebViewExecutor registerBridge:@"NativeModules" callbackFunction:@"invokeCallback"];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2f];
    button.frame = CGRectMake(20, 100, 60, 40);
    [button setTitle:@"Push" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didClickButton:(id)sender {
    MKWebViewController *webViewController = [[MKWebViewController alloc] init];
    [self.navigationController pushViewController:webViewController animated:YES];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"html"];
    NSURL *URL = [NSURL fileURLWithPath:path];
    [webViewController loadURL:URL];
}

@end
