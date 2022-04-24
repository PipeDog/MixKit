//
//  MKAlertManager.m
//  MixKit_Example
//
//  Created by liang on 2021/6/8.
//  Copyright © 2021 liang. All rights reserved.
//

#import "MKAlertManager.h"
#import <MKWebView.h>
#import "MKUtil.h"
#import "MKResponseWrapper.h"

@implementation MKAlertManager

@synthesize bridge = _bridge;

MK_EXPORT_METHOD(showAlert, showAlertWithParams:callback:)

- (void)showAlertWithParams:(NSDictionary *)params callback:(MKResponseCallback)callback {
    NSString *title = params[@"title"] ?: @"";
    NSString *message = params[@"message"] ?: @"";
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // Do something here
    }]];
    
    UIViewController *controller = MKGetPageByBridge(self.bridge);
    [controller presentViewController:alertController animated:YES completion:nil];

    NSDictionary *resp = MKResponseMake(MKCallbackCodeSuccess, @"Success", nil);
    !callback ?: callback(@[resp]);
}

+ (NSDictionary<NSString *,id> *)constantsToExport {
    return @{
        @"version": @"v1.0.0"
    };
}

@end
