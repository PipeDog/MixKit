//
//  MKPageManager.m
//  MixKit_Example
//
//  Created by liang on 2021/6/8.
//  Copyright © 2021 liang. All rights reserved.
//

#import "MKPageManager.h"
#import "MKUtil.h"
#import "MKResponseWrapper.h"

@implementation MKPageManager

@synthesize bridge = _bridge;

MK_EXPORT_METHOD(goback, goback)
MK_EXPORT_METHOD(setTitle, setTitleWithParams:callback:)
MK_EXPORT_METHOD(openPage, openPage)

- (void)goback {
    UIViewController *controller = MKGetPageByBridge(self.bridge);
    [controller.navigationController popViewControllerAnimated:YES];
}

- (void)setTitleWithParams:(NSDictionary *)params callback:(MKResponseCallback)callback {
    UIViewController *controller = MKGetPageByBridge(self.bridge);
    controller.title = params[@"title"];
    
    NSDictionary *resp = MKResponseMake(MKCallbackCodeSuccess, @"Set title success!", nil);
    !callback ?: callback(@[resp]);
}

- (void)openPage {
    UIViewController *controller = [[UIViewController alloc] init];
    controller.title = @"from web";
    controller.view.backgroundColor = [UIColor blueColor];
    
    UIViewController *webController = MKGetPageByBridge(self.bridge);
    [webController.navigationController pushViewController:controller animated:YES];
}

@end
