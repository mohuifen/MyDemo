//
//  ImKLineLandScapeView.h
//  Kline
//
//  Created by zhaomingxi on 14-2-9.
//  Copyright (c) 2014年 zhaomingxi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImKLineViewDelegate.h"
typedef void(^updateBlock)(id);


/**
 *  主副图K线图
 */
@interface ImKLineLandScapeView : UIView
{
    CGFloat _frontMaxValue;
    CGFloat _frontMinValue;
}
@property (nonatomic, weak) id<ImKLineViewDelegate> delegate;
@property (nonatomic, weak) id<ImFullScreenKLineViewDelegate> detailDelegate;
@property (nonatomic,retain) NSArray *data;
@property (nonatomic,retain) NSDate *startDate;
@property (nonatomic,assign) CGFloat mainWidth;            // x轴宽度
@property (nonatomic,assign) CGFloat mainHeight;           // y轴高度
@property (nonatomic,assign) CGFloat amountBoxHeight;   // y轴高度
@property (nonatomic,assign) CGFloat macdBoxHeight;   // y轴高度
@property (nonatomic,assign) CGFloat kLineWidth;        // k线的宽度 用来计算可存放K线实体的个数，也可以由此计算出起始日期和结束日期的时间段
@property (nonatomic,assign) CGFloat kLinePadding;
@property (nonatomic,assign) NSInteger kCount;                // k线中实体的总数 通过 xWidth / kLineWidth 计算而来
@property (nonatomic,retain) UIFont *font;
@property (nonatomic,copy) updateBlock finishUpdateBlock; // 定义一个block回调 更新界面
@property (nonatomic,assign) CGFloat frontMaxValue;
@property (nonatomic,assign) CGFloat frontMinValue;
@property (nonatomic,assign) BOOL bTimeLine;
@property (nonatomic,assign) BOOL bLatestLine;          //显示最新的数据
@property (nonatomic,assign) int MACDType;
@property (nonatomic,assign) CGFloat MACDMaxValue;
@property (nonatomic,assign) CGFloat MACDMinValue;

@property (nonatomic,assign) BOOL bShowExtraChat;
@property (nonatomic,assign) int mainchatType;

@property (nonatomic,assign) CGFloat kLineWidthTemp;        // k线的宽度 用来计算可存放K线实体的个数，也可以由此计算出起始日期和结束日期的时间段
@property (nonatomic,assign) CGFloat kLinePaddingTemp;

@property (nonatomic,assign) BOOL bFullScreenMode;

- (void)start;

- (void)appendBackDataToQueue:(NSInteger)nUpdateType;

- (void) resetKLineViewWithPeriod:(NSString*)strPeriod;

- (void) reloadKLineViewWithPeriod:(NSString*)strPeriod;

-(void) initLandScapeSet;

- (CGRect) getActivityIndicatorFrame;

- (void) hiddeCrossLine;

- (void) refreshLastPrice:(NSNumber*)lastPrice andLastAmount:(NSNumber*)lastAmount bOnlyMove:(BOOL)bOnlyMove;

@end
