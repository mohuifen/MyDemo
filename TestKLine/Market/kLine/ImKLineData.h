//
//  ImKLineData.h
//  Kline
//
//  Created by zhaomingxi on 14-2-10.
//  Copyright (c) 2014年 zhaomingxi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define MACD_MACD   @"MACD_macd"
#define MACD_DIF    @"MACD_dif"
#define MACD_DEA    @"MACD_dea"
#define KDJ_K       @"KDJ_K"
#define KDJ_D       @"KDJ_D"
#define KDJ_J       @"KDJ_J"
#define RSI_RSI1    @"RSI_RSI1"
#define RSI_RSI2    @"RSI_RSI2"
#define RSI_RSI3    @"RSI_RSI3"
#define WR_WR1      @"WR_WR1"
#define WR_WR2      @"WR_WR2"
#define MA_MA10     @"MA_MA10"
#define MA_MA30     @"MA_MA30"
#define MA_MA60     @"MA_MA60"
#define AMOUNT_MA5  @"AMOUNT_MA5"
#define AMOUNT_MA10  @"AMOUNT_MA10"

#define BOLL_SUMMARY @"BOLL_SUMMARY"
#define BOLL_UB @"BOLL_UB"
#define BOLL_LB @"BOLL_LB"

@class ImKLineLandScapeView;
@interface ImKLineData : NSObject

#pragma mark - in item
@property (nonatomic,assign) NSInteger kCount;
@property (nonatomic,assign) NSInteger mainchatType;
@property (nonatomic,assign) NSInteger MACDType;
@property (nonatomic,assign) NSInteger offsetCount;
#pragma mark - out item
@property (nonatomic,retain) NSMutableArray *backData;
@property (nonatomic,retain) NSMutableArray *category;

@property (nonatomic,assign) CGFloat maxValue;
@property (nonatomic,assign) CGFloat minValue;
@property (nonatomic,assign) CGFloat amountMaxValue;
@property (nonatomic,assign) CGFloat amountMinValue;
@property (nonatomic,assign) CGFloat bollMaxValue;
@property (nonatomic,assign) CGFloat bollMinValue;
@property (nonatomic,assign) CGFloat MACDMaxValue;
@property (nonatomic,assign) CGFloat MACDMinValue;


@property (nonatomic,assign) ImKLineLandScapeView *kLineView;

- (NSInteger) updateBackDataWithOffet:(NSInteger)nOffset ofMoveType:(NSInteger)nMoveType;

//由于缩放操作而产生新的backdata
- (BOOL) createBackDataWithOffet:(NSInteger)nOffsetCount;
@end
