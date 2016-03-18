//
//  AppDelegate.h
//  Demo
//
//  Created by CoLcY on 11-12-29.
//  Copyright (c) 2011年 Gexin Interactive (Beijing) Network Technology Co.,LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeTuiSdk.h"

// production - hangzhou
#define kAppId           @"WXTPKKPKxk7tuNGRRCA9O"
#define kAppKey          @"eio2H9anHh8VFWe8BEycF3"
#define kAppSecret       @"pXCqRkF7ShAWnw1Sdc8MZ3"

@class DemoViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, GeTuiSdkDelegate> {
@private
    UINavigationController *_naviController;
    NSString *_deviceToken;
}


@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DemoViewController *viewController;

@property (retain, nonatomic) NSString *appKey;
@property (retain, nonatomic) NSString *appSecret;
@property (retain, nonatomic) NSString *appID;
@property (retain, nonatomic) NSString *clientId;
@property (assign, nonatomic) SdkStatus sdkStatus;

@property (assign, nonatomic) int lastPayloadIndex;
@property (retain, nonatomic) NSString *payloadId;

- (void)startSdkWith:(NSString *)appID appKey:(NSString *)appKey appSecret:(NSString *)appSecret;
- (void)stopSdk;

- (void)setDeviceToken:(NSString *)aToken;
- (BOOL)setTags:(NSArray *)aTag error:(NSError **)error;
- (NSString *)sendMessage:(NSData *)body error:(NSError **)error;

- (void)bindAlias:(NSString *)aAlias;
- (void)unbindAlias:(NSString *)aAlias;

- (void)testSdkFunction;
//- (void)testSendMessage;
- (void)testGetClientId;

@end
