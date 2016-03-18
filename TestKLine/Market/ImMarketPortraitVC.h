//
//  ImMarketPortraitVC.h
//  BitVCProject
//
//  Created by FuYou on 15/1/29.
//  Copyright (c) 2015年 Huobi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImKLineViewDelegate.h"
#import "TradeCodeData.h"
@interface ImMarketPortraitVC : UIViewController<ImKLineViewDelegate>
- (void) initKLineData:(BOOL)fromConnected;

@property (nonatomic,assign, readonly) BOOL bFinishLaunch;

@property (nonatomic,strong) TradeCodeData* tradeCodeData;

- (NSString*) getNameOfMarket;

@end
