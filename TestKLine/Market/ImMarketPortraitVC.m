//
//  ImMarketPortraitVC.m
//  BitVCProject
//
//  Created by FuYou on 15/1/29.
//  Copyright (c) 2015年 Huobi. All rights reserved.
//

#import "ImMarketPortraitVC.h"
#import "DLMainManager.h"
#import "DLNetWorkManager.h"
#import "DLDataBaseManager.h"
#import "DLTextAttributeData.h"

#import "ImKLineLandScapeView.h"
#import "KlineConstant.h"
#import "ImFullScreenKLineView.h"
#import "ImSegmentVIew.h"
#import "ImRealTimeView.h"
//#import "ImInfoAlertView.h"

#import "ImScreenTouchesAction.h"
#import "ImHBLog.h"
//#import "MobClick.h"
#import "UIColor+helper.h"
#import "HBViewHelper.h"
//#import "HBThemeManager.h"

#define STANDARD_WIDTH  320

#define STANDARD_HEIGHT 504


#define SCREEN_BUTTON_RIGHT_ENDGE 15


@interface ImMarketPortraitVC ()
{
    ImKLineLandScapeView* _klineView;
    ImFullScreenKLineView* _fullscreenKLineView;
    
    ImSegmentView* _periodSegmentView;
    UIActivityIndicatorView* _activityView;
    NSArray* _periodArray;
    NSString* _keyPeriod;
    NSDictionary* _backData;
    
    float _askAmountMax;
    float _bidAmountMax;
    NSMutableArray* _tableIndexArray;
    UIColor* _cellBgColor;
    CGRect _askAmountRect;
    CGRect _askPriceRect;
    CGRect _bidPriceRect;
    CGRect _bidAmountRect;

    
    BOOL _bInitedFrame;
    
    UIView* _indexView;
    
    UIButton* _menuButton;
    
    BOOL _bHideStatusBar;
}

@property (nonatomic,weak) IBOutlet UIView* topbarView;
@property (nonatomic,weak) IBOutlet UIView* marketBorderView;
@property (nonatomic,weak) IBOutlet UIView* periodSegView;
@property (nonatomic,weak) IBOutlet UIView* kLineViewBorderView;
@property (nonatomic,weak) IBOutlet ImRealTimeView* realtimeView;
@property (nonatomic,weak) IBOutlet UILabel* titleLabel;
@property (nonatomic,weak) IBOutlet UILabel* backLabel;
@property (nonatomic,weak) IBOutlet UIButton* fullScreenButton;
- (void) onLastKLineUpdated:(NSNotification*)aNotification;
- (IBAction)onBackClicked:(id)sender;

@end

@implementation ImMarketPortraitVC

- (NSString*) getNameOfMarket
{
    NSString* result = @"";
    if (self.tradeCodeData)
    {
//        result = self.tradeCodeData.strName;
    }
    //else cont.
    
    return result;
}
- (void) myReframeSubviews
{
    if (!_bInitedFrame)
    {
        CGSize selfSize = self.view.frame.size;
        
        CGRect topbarFrame = self.topbarView.frame;
        topbarFrame.size.width = selfSize.width;
        [self.topbarView setFrame:topbarFrame];
        
        CGRect marketFrame = self.marketBorderView.frame;
        marketFrame.size.width = selfSize.width;
        marketFrame.size.height = selfSize.height - (topbarFrame.origin.y + topbarFrame.size.height) ;
        [self.marketBorderView setFrame:marketFrame];
        
        
        CGFloat theWidthRate = self.marketBorderView.frame.size.width / STANDARD_WIDTH;
        CGFloat theHeightRate = self.marketBorderView.frame.size.height / STANDARD_HEIGHT;
        [HBViewHelper reframeView:self.topbarView widthRate:theWidthRate hightRate:1.0f];
        [HBViewHelper reframeView:self.marketBorderView widthRate:theWidthRate hightRate:theHeightRate];
        [HBViewHelper reframeLayer:self.realtimeView.layer widthRate:theWidthRate hightRate:theHeightRate];
        
        CGRect frame = self.fullScreenButton.frame;
        frame.origin.x = selfSize.width - frame.size.width - SCREEN_BUTTON_RIGHT_ENDGE;
        [self.fullScreenButton setFrame:frame];
        
        _bInitedFrame = YES;
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [MobClick beginLogPageView:@"MarketPortraitTVC"];
    
    ImScreenTouchesAction *screenTouchesAction = [ImScreenTouchesAction getInstance];
    [screenTouchesAction setScreenLight];
    
    self.titleLabel.text = [self getNameOfMarket];
    
//    [[HBThemeManager sharedInstance]setSubviewsTextColorWithTopView:self.topbarView];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self myReframeSubviews];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0
        && [[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    //else cont.
    
    /****************************************
     这两个有先后顺序，别乱动
     ****************************************/
    [self initNotification];
    [self initKLineView];
    [self initKLineData:YES];
    
    NSString* strSymbolId = [self getMyCurrentSymbolId];
    if (strSymbolId)
    {
        //MARK:开始请求或连接
//        self.realtimeView.bSpotGoods = [self isSpotGoodsOfSymbolId:strSymbolId];
//        [[DLMainManager sharedNetWorkManager] localRequestMarketDetailWithSymbolID:strSymbolId];
    }
    //else cont.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [MobClick endLogPageView:@"MarketPortraitTVC"];
    
    ImScreenTouchesAction *screenTouchesAction = [ImScreenTouchesAction getInstance];
    [screenTouchesAction setScreenCanDarken];
    
    NSString* strSymbolId = [self getMyCurrentSymbolId];
    NSString* strPeriod = [self getCurrentPeriod];
    if (strSymbolId && strPeriod)
    {
        //MARK: 取消请求或连接
//        [[DLMainManager sharedNetWorkManager] unSubscribeLastKLine:strPeriod widthSymbolId:strSymbolId];
    }
    //else cont.
}

- (void)viewDidLoad
{
    _bHideStatusBar = NO;
    [super viewDidLoad];
    _cellBgColor = [UIColor colorWithHexString:@"0x292c34" withAlpha:1.0f];
    self.marketBorderView.backgroundColor = _cellBgColor;
    
    self.backLabel.text = NSLocalizedString(@"SR_ScanReturn", @"");
}

#pragma mark - init uiview

- (void) initKLineView
{
    /************************************************************************
     初始化tableview的section 1
     ************************************************************************/
    [self initSegmentView];
    
    [self initRealView];
    
    if (self.kLineViewBorderView)
    {
        //初始化klineview
        _klineView = [[ImKLineLandScapeView alloc] initWithFrame:[self.kLineViewBorderView bounds]];
        _klineView.MACDType = MACD_TYPE_MACD;
        [_klineView initLandScapeSet];
        _klineView.delegate = self;
        _klineView.bTimeLine = YES;
        [self.kLineViewBorderView addSubview:_klineView];
        [_klineView start];
    }
    else
        HB_LOG(@"error!");
    
    CGRect mainRect = [[UIScreen mainScreen] bounds];
    CGRect landRect = CGRectMake((mainRect.size.width - mainRect.size.height) / 2,
                                 (mainRect.size.height - mainRect.size.width) / 2,
                                 mainRect.size.height,
                                 mainRect.size.width);
    
    _fullscreenKLineView = [[ImFullScreenKLineView alloc] initWithFrame:landRect];
    _fullscreenKLineView.center = CGPointMake(landRect.origin.x + ceil(landRect.size.width/2), landRect.origin.y + ceil(landRect.size.height/2));
    _fullscreenKLineView.delegate = self;
    [_fullscreenKLineView setKLineDelegate:self];
    _fullscreenKLineView.hidden = YES;
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_activityView sizeToFit];
}

- (void) initSegmentView
{
    /************************************************************************
     初始化竖直屏幕上的两个Segment View
     ************************************************************************/
    _periodArray = @[@"timeLine_type",@"5min",@"30min",@"60min",@"1day"];
    _cellBgColor = [UIColor colorWithHexString:@"0x292c34" withAlpha:1.0f];
    
    NSArray* imageSegArray = @[[UIImage imageNamed:@"market_control_normal"],
                               [UIImage imageNamed:@"market_control_selected"],
                               [UIImage imageNamed:@"market_nav_normal"],
                               [UIImage imageNamed:@"market_nav_selected"],
                               [UIImage imageNamed:@"market_nav_normal"],
                               [UIImage imageNamed:@"market_nav_selected"],
                               [UIImage imageNamed:@"market_nav_normal"],
                               [UIImage imageNamed:@"market_nav_selected"],
                               [UIImage imageNamed:@"market_nav_normal"],
                               [UIImage imageNamed:@"market_nav_selected"],
                               [UIImage imageNamed:@"market_nav_normal"],
                               [UIImage imageNamed:@"market_nav_selected"]];
    
    NSArray* textSegArray = @[NSLocalizedString(@"SR_INDEX", @""),
                              NSLocalizedString(@"SR_KlineTimeline", @""),
                              NSLocalizedString(@"SR_Kline5min", @""),
                              NSLocalizedString(@"SR_Kline30min", @""),
                              NSLocalizedString(@"SR_Kline60min", @""),
                              NSLocalizedString(@"SR_Kline1day", @"")];
    
    if (self.periodSegView)
    {
        _periodSegmentView = [[ImSegmentView alloc] initSegmentWithFrame:[self.periodSegView bounds]
                                                        withButtonCount:[textSegArray count]
                                                                 target:self
                                                               selector:@selector(onPeriodClicked:)];
        
        _periodSegmentView.controlIndex = 0;
        _periodSegmentView.selectedTextColor = [UIColor colorWithHexString:@"0x1686cc" withAlpha:1.0f];
        _periodSegmentView.normalTextColor = [UIColor colorWithHexString:@"0x434b56" withAlpha:1.0f];
        _periodSegmentView.normalControlColor = [UIColor colorWithHexString:@"0x434b56" withAlpha:1.0f];
        [_periodSegmentView setText:textSegArray forState:UIControlStateNormal];
        [_periodSegmentView setBackgroundImage:imageSegArray forState:UIControlStateNormal];
        [_periodSegmentView setDataItemIndex:1];
        
        
        [self.periodSegView addSubview:_periodSegmentView];
    }
    else
        HB_LOG(@"error!");
}

- (void) initRealView
{
    _backData = nil;
    
    _realtimeView.priceChangeType = 0;
    _realtimeView.priceNew = @"       ";
    _realtimeView.amount = @"     ";
    _realtimeView.priceLow = @"     ";
    _realtimeView.priceHigh = @"      ";
    _realtimeView.margin = @"      ";
}

- (NSString*) getMyCurrentSymbolId
{
    NSString* strResult = nil;
    if (self.tradeCodeData)
    {
        strResult = self.tradeCodeData.strCode;
    }
    //else cont.
    return strResult;
}

#pragma mark - init data
- (void) initNotification
{
    /************************************************************************
     初始化notification
     ************************************************************************/
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(onKLineUpdated:) name:NOTIFICATON_KLINE_UPDATE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(onLastKLineUpdated:) name:NOTIFICATON_LSAT_KLINE_UPDATE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(onKLineUpdatedLocal:) name:NOTIFICATON_KLINE_UPDATE_LOCAL object:nil];
    
    /**由后台转回到前台的时候使用**/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKLineDataReset:) name:NOTIFICATON_REACHABLE_DIDCONNECTED object:nil];
    
    /**切换交易类型的时候使用**/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKLineDataReset:) name:NOTIFICATON_REQUEST_SYMBOLID object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(onUpdateMarketDetail:) name:NOTIFICATON_MARKET_DETAIL_UPDATE object:nil];
}

- (void) initKLineData:(BOOL)fromConnected
{
    /************************************************************************
     1、launch的时候会进入；
     launch进入：请求对应交易类型和周期的数据：；
     不需要有菊花；
     2、did connected的时候会进入；
     菊花；
     3、从交易切换回来的时候会进入；
     菊花
     4、本页面切换交易类型：
     菊花
     5、周期类型
     菊花
     ************************************************************************/
    if (_klineView)
    {
        _backData = nil;
        _realtimeView.priceChangeType = 0;
        _realtimeView.priceNew = @"       ";
        _realtimeView.amount = @"     ";
        _realtimeView.priceLow = @"     ";
        _realtimeView.priceHigh = @"      ";
        _realtimeView.margin = @"      ";
        
        [_realtimeView setNeedsDisplay];
        
        NSString* strPeriod = [self getCurrentPeriod];
        if (fromConnected)
            [_klineView resetKLineViewWithPeriod:strPeriod];
        else
        {
            [_klineView reloadKLineViewWithPeriod:strPeriod];
        }//endi
    }
    //else cont.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATON_MARKET_OVERVIEW_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATON_MARKETDEPTHTOPSHORT_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATON_KLINE_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATON_KLINE_UPDATE_LOCAL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_LAUNCH_FINISH object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATON_LSAT_KLINE_UPDATE object:nil];
}

- (IBAction)onFullScreenClicked:(id)sender {
    [self showDetailKLineView:_klineView];
}



#pragma mark - period segment

- (void) onPeriodClicked:(id)sender
{
    [_klineView hiddeCrossLine];
    NSString* strPeriod = nil;
    NSInteger segmentIndex = [_periodSegmentView getButtonIndex];
    strPeriod = [self getPeriodOfIndex:segmentIndex];
    if([strPeriod isEqualToString:@"item_control"])
    {
        [self popUpMenu:nil];
    }
    else
    {
        if ([strPeriod isEqualToString:@"timeLine_type"])
        {
            _klineView.bTimeLine = YES;
            strPeriod = KLINE1MIN;
        }
        else
            _klineView.bTimeLine = NO;
        
        [_klineView resetKLineViewWithPeriod:strPeriod];
    }//endi
    

}

- (NSString*) getCurrentPeriod
{
    NSString* strResult = nil;
    if (_fullscreenKLineView.hidden)
    {
        NSInteger segmentIndex = [_periodSegmentView getDataItemIndex];
        strResult = [self getPeriodOfIndex:segmentIndex];
        if ([strResult isEqualToString:@"item_control"])
            strResult = @"";
        else if ([strResult isEqualToString:@"timeLine_type"])
            strResult = KLINE1MIN;
        //else cont.
    }
    else
    {
        strResult = _keyPeriod;
    }//endi
    
    return strResult;
}

- (NSString*) getPeriodOfIndex:(NSInteger)index
{
    NSString* strResult = nil;
    if(index == 0)
    {
        strResult = @"item_control";
    }
    else
    {
        strResult = [_periodArray objectAtIndex:index - 1];
    }//endi
    
    return strResult;
}

- (void) setSegmentWithPeriod:(NSString*)strPeriodKey
{
    NSInteger theIndex = [_periodArray indexOfObject:strPeriodKey] + 1;
    [_periodSegmentView setDataItemIndex:theIndex];
}


#pragma mark - popup menu

#define VIEW_TAG_INDEX 1

/*
 "SR_MainChart"                                    = "主图";
 "SR_EXTRAChart"                                   = "副图";
 "SR_CloseChart"                                   = "关闭";
 */

- (UIView*) getIndexView
{
    if (!_indexView)
    {
        CGRect segBounds = self.periodSegView.bounds;
        CGRect segFrame = [self.view convertRect:segBounds fromView:self.periodSegView];
        CGFloat width = self.view.frame.size.width;
        CGFloat height = 154.0f;//self.view.frame.size.width;
        CGFloat originX = segFrame.origin.x;
        CGFloat originY = segFrame.origin.y - height;
        
        _indexView = [[UIView alloc] initWithFrame:CGRectMake(originX, originY, width, height)];
        _indexView.backgroundColor = [UIColor colorWithHexString:@"0x101416" withAlpha:0.93];;
        _indexView.tag = VIEW_TAG_INDEX;
        
        CGFloat leftSpan = 11.0f;
        
        {
            CGRect mainChartFrame = CGRectMake(leftSpan, 10, 150, 25);
            UILabel* mainChartName = [[UILabel alloc] initWithFrame:mainChartFrame];
            mainChartName.tag = 10;
            mainChartName.textAlignment = NSTextAlignmentLeft;
            mainChartName.text = NSLocalizedString(@"SR_MainChart",@"");
            mainChartName.font = [UIFont systemFontOfSize:12];
            mainChartName.textColor = [UIColor colorWithHexString:@"0x5e6c7f" withAlpha:1.0f];
            //[mainChartName sizeToFit];
            [_indexView addSubview:mainChartName];
            
            mainChartFrame = mainChartName.frame;
            
            CGFloat buttonY = mainChartFrame.origin.y + mainChartFrame.size.height + 15.0f;
            [self addButtonWithFrame:CGRectMake(leftSpan, buttonY, 50, 30)
                             withTag:11
                           withTitle:@"MA"];
            
            [self addButtonWithFrame:CGRectMake(72, buttonY, 50, 30)
                             withTag:12
                           withTitle:@"BOLL"];
            
            UIButton* defaultButton = [self addButtonWithFrame:CGRectMake(137, buttonY, 50, 30)
                                                       withTag:13
                                                     withTitle:NSLocalizedString(@"SR_CloseChart", @"")];
            
            [defaultButton setTitleColor:[UIColor colorWithHexString:@"0x1686cc" withAlpha:1.0] forState:UIControlStateNormal];
        }
        
        UIImageView* spitLine = [[UIImageView alloc] initWithImage:[UIImage
                                                                    imageNamed:@"market_menu_splitline"]];
        
        CGRect spitLineFrame = spitLine.frame;
        spitLineFrame.origin.x = (STANDARD_WIDTH - spitLineFrame.size.width) / 2;
        spitLineFrame.origin.y = 78;
        [spitLine setFrame:spitLineFrame];
        
        [_indexView addSubview:spitLine];
        
        {
            CGRect extraChartFrame = CGRectMake(leftSpan, 87, 50, 25);
            UILabel* extraChartName = [[UILabel alloc] initWithFrame:extraChartFrame];
            extraChartName.tag = 20;
            extraChartName.text = NSLocalizedString(@"SR_EXTRAChart",@"");
            extraChartName.font = [UIFont systemFontOfSize:12];
            extraChartName.textColor = [UIColor colorWithHexString:@"0x5e6c7f" withAlpha:1.0f];
            [extraChartName sizeToFit];
            [_indexView addSubview:extraChartName];
            
            
            extraChartFrame = extraChartName.frame;
            
            CGFloat buttonY = extraChartFrame.origin.y + extraChartFrame.size.height + 10;
            [self addButtonWithFrame:CGRectMake(leftSpan, buttonY, 50, 30)
                             withTag:21
                           withTitle:@"MACD"];
            
            [self addButtonWithFrame:CGRectMake(72, buttonY, 50, 30)
                             withTag:22
                           withTitle:@"KDJ"];
            
            [self addButtonWithFrame:CGRectMake(123, buttonY, 50, 30)
                             withTag:23
                           withTitle:@"RSI"];
            
            [self addButtonWithFrame:CGRectMake(168, buttonY, 50, 30)
                             withTag:24
                           withTitle:@"WR"];
            
            UIButton* defaultButton = [self addButtonWithFrame:CGRectMake(216, buttonY, 50, 30)
                                                       withTag:25
                                                     withTitle:NSLocalizedString(@"SR_CloseChart", @"")];
            
            [defaultButton setTitleColor:[UIColor colorWithHexString:@"0x1686cc" withAlpha:1.0] forState:UIControlStateNormal];
        }
        
        CGFloat theWidthRate = self.marketBorderView.frame.size.width / STANDARD_WIDTH;
        CGFloat theHeightRate = self.marketBorderView.frame.size.height / STANDARD_HEIGHT;
        CGRect frame =  _indexView.frame;
        frame.size.width *= theWidthRate;
        frame.size.height *= theHeightRate;
        frame.origin.x = segFrame.origin.x;
        frame.origin.y = segFrame.origin.y - frame.size.height;
        [_indexView setFrame:frame];
        [HBViewHelper reframeView:_indexView widthRate:theWidthRate hightRate:theHeightRate];
    }
    //else cont.
    
    return _indexView;
}
- (void) popUpMenu:(id)sender
{
    ImScreenTouchesAction *screenTouchesAction = [ImScreenTouchesAction getInstance];
    [screenTouchesAction setScreenLight];
    
    UIView* indexView = [self getIndexView];
    if (![indexView superview])
    {
        [self.view addSubview:indexView];
        
        if (_menuButton)
            [_menuButton setImage:[UIImage imageNamed:@"caidan()"] forState:UIControlStateNormal];
        //else cont.
        
    }
    else
    {
        if (_menuButton)
            [_menuButton setImage:[UIImage imageNamed:@"caidan"] forState:UIControlStateNormal];
        //else cont.
        
        [indexView removeFromSuperview];
        
    }//endi
    
    [self setMainChatWithMainChatType:_klineView.mainchatType];
    [self setExtraChatWithMACDType:_klineView.MACDType];
}

- (UIButton*) addButtonWithFrame:(CGRect)frame withTag:(NSInteger)tag withTitle:(NSString*)title
{
    UIView* indexView = [self getIndexView];
    
    UIButton* resultButton = [[UIButton alloc] initWithFrame:frame ];
    resultButton.tag = tag;
    resultButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [resultButton setTitleColor:[UIColor colorWithHexString:@"0xffffff" withAlpha:1.0] forState:UIControlStateNormal];
    [resultButton setTitle:title forState:UIControlStateNormal];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:14.0f],
                           NSFontAttributeName,
                           nil];
    CGSize theSize = [title sizeWithAttributes:attrs];
    
    [resultButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, frame.size.width - theSize.width)];
    [indexView addSubview:resultButton];
    
    [resultButton addTarget:self action:@selector(onItemSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    return resultButton;
}

- (void) setMainChatWithMainChatType:(NSInteger)mainchatType
{
    UIView* indexView = [self getIndexView];
    
    UIButton* button = nil;
    switch (mainchatType) {
        case KLINE_TYPE_MA:
            button = (UIButton*)[indexView viewWithTag:11];
            break;
            
        case KLINE_TYPE_BOLL:
            button = (UIButton*)[indexView viewWithTag:12];
            break;
            
        case KLINE_TYPE_NONE:
            button = (UIButton*)[indexView viewWithTag:13];
            break;
        default:
            break;
    }
    
    // 主图菜单按钮
    if (10 < button.tag && button.tag < 20)
    {
        for (NSInteger tag = 11; tag <= 13 ; tag++)
        {
            UIButton* aButton = (UIButton*)[indexView viewWithTag:tag];
            if ([aButton isKindOfClass:[UIButton class]] && tag != button.tag)
            {
                [aButton setTitleColor:[UIColor colorWithHexString:@"0xffffff" withAlpha:1.0] forState:UIControlStateNormal];
            }
            //else cont.
        }//endf
    }
    //else cont.
    
    [button setTitleColor:[UIColor colorWithHexString:@"0x1686cc" withAlpha:1.0] forState:UIControlStateNormal];
}

- (void) setExtraChatWithMACDType:(NSInteger)macdType
{
    UIView* indexView = [self getIndexView];
    
    UIButton* button = nil;
    switch (macdType) {
        case MACD_TYPE_MACD:
            button = (UIButton*)[indexView viewWithTag:21];
            break;
            
        case MACD_TYPE_KDJ:
            button = (UIButton*)[indexView viewWithTag:22];
            break;
            
        case MACD_TYPE_RSI:
            button = (UIButton*)[indexView viewWithTag:23];
            break;
        case MACD_TYPE_WR:
            button = (UIButton*)[indexView viewWithTag:24];
            break;
        case MACD_TYPE_NONE:
            button = (UIButton*)[indexView viewWithTag:25];
            break;
        default:
            break;
    }
    
    // 副图菜单按钮
    if (20 < button.tag && button.tag < 30)
    {
        for (NSInteger tag = 21; tag <= 25 ; tag++)
        {
            UIButton* aButton = (UIButton*)[indexView viewWithTag:tag];
            if ([aButton isKindOfClass:[UIButton class]] && tag != button.tag)
            {
                [aButton setTitleColor:[UIColor colorWithHexString:@"0xffffff" withAlpha:1.0] forState:UIControlStateNormal];
            }
            //else cont.
        }//endf
    }
    //else cont.
    
    [button setTitleColor:[UIColor colorWithHexString:@"0x1686cc" withAlpha:1.0] forState:UIControlStateNormal];
}

- (IBAction) onItemSelected:(id)sender
{
    UIButton* button = sender;
    UIView* indexView = [self getIndexView];
    switch (button.tag) {
        case 11:
        {
            _klineView.mainchatType = KLINE_TYPE_MA;
            break;
        }
        case 12:
        {
            _klineView.mainchatType = KLINE_TYPE_BOLL;
            break;
        }
        case 13:
        {
            _klineView.mainchatType = KLINE_TYPE_NONE;
            break;
        }
        case 21:
        {
            _klineView.MACDType = MACD_TYPE_MACD;
            break;
        }
        case 22:
        {
            _klineView.MACDType = MACD_TYPE_KDJ;
            break;
        }
        case 23:
        {
            _klineView.MACDType = MACD_TYPE_RSI;
            break;
        }
        case 24:
        {
            _klineView.MACDType = MACD_TYPE_WR;
            break;
        }
        case 25:
        {
            _klineView.MACDType = MACD_TYPE_NONE;
            break;
        }
        default:
            break;
    }//ends
    
    // 主图菜单按钮
    if (10 < button.tag && button.tag < 20)
    {
        for (NSInteger tag = 11; tag <= 13 ; tag++)
        {
            UIButton* aButton = (UIButton*)[indexView viewWithTag:tag];
            if ([aButton isKindOfClass:[UIButton class]] && tag != button.tag)
            {
                [aButton setTitleColor:[UIColor colorWithHexString:@"0xffffff" withAlpha:1.0] forState:UIControlStateNormal];
            }
            //else cont.
        }//endf
    }
    //else cont.
    
    // 副图菜单按钮
    if (20 < button.tag && button.tag < 30)
    {
        for (NSInteger tag = 21; tag <= 25 ; tag++)
        {
            UIButton* aButton = (UIButton*)[indexView viewWithTag:tag];
            if ([aButton isKindOfClass:[UIButton class]] && tag != button.tag)
            {
                [aButton setTitleColor:[UIColor colorWithHexString:@"0xffffff" withAlpha:1.0] forState:UIControlStateNormal];
            }
            //else cont.
        }//endf
    }
    //else cont.
    
    [button setTitleColor:[UIColor colorWithHexString:@"0x1686cc" withAlpha:1.0] forState:UIControlStateNormal];
    
    NSString* strPeriod = [self getCurrentPeriod];
    [_klineView initLandScapeSet];
    [_klineView reloadKLineViewWithPeriod:strPeriod];
    
    [[self getIndexView] removeFromSuperview];
    
//    [self showDetailKLineView:_klineView];
}


#pragma mark - notification

- (void) onKLineUpdated:(NSNotification*)aNotification
{
    /************************************************************************
     如果在请求的时候数据尚未从服务器返回，那么就需要设置观察，等待服务器返回。
     ************************************************************************/
    NSDictionary* pldDict = aNotification.object;
    if (pldDict)
    {
        NSString* keySymbolid = [pldDict objectForKey:SYMBOLID];
        NSString* strSymbolId = [self getMyCurrentSymbolId];
        if (strSymbolId)
        {
            BOOL bSymbolidResult = keySymbolid && strSymbolId && [keySymbolid isEqualToString:strSymbolId];
            
            NSString* keyPeriod = [pldDict objectForKey:PERIOD];
            NSString* strPeriod = [self getCurrentPeriod];
            BOOL bPeriodResult = keyPeriod && strPeriod && [keyPeriod isEqualToString:strPeriod];
            if (bSymbolidResult && bPeriodResult)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATON_KLINE_VIEW_UPDATE object:pldDict];
                [self removeActivityView];
            }
            //else 快速切换倒是发生这种情况的更新
        }
        //else cont.
    }
    else
        HB_LOG(@"error!");
}

- (void) onLastKLineUpdated:(NSNotification*)aNotification
{
    /************************************************************************
     如果在请求的时候数据尚未从服务器返回，那么就需要设置观察，等待服务器返回。
     ************************************************************************/
    NSDictionary* pldDict = aNotification.object;
    if (pldDict)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATON_LSAT_KLINE_VIEW_UPDATE object:pldDict];
    }
    else
        HB_LOG(@"error!");
}

- (void) onKLineUpdatedLocal:(NSNotification*)aNotification
{
    /************************************************************************
     如果在请求的时候数据尚未从服务器返回，那么就需要设置观察，等待服务器返回。
     ************************************************************************/
    NSDictionary* pldDict = aNotification.object;
    if (pldDict)
    {
        NSString* keySymbolid = [pldDict objectForKey:SYMBOLID];
        NSString* strSymbolId = [self getMyCurrentSymbolId];
        if (strSymbolId)
        {
            BOOL bSymbolidResult = keySymbolid && strSymbolId && [keySymbolid isEqualToString:strSymbolId];
            
            NSString* keyPeriod = [pldDict objectForKey:PERIOD];
            NSString* strPeriod = [self getCurrentPeriod];
            BOOL bPeriodResult = keyPeriod && strPeriod && [keyPeriod isEqualToString:strPeriod];
            if (bSymbolidResult && bPeriodResult)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATON_KLINE_VIEW_UPDATE object:pldDict];
            }
            //else cont.
        }
        //else cont.
    }
    else
        HB_LOG(@"error!");
}

- (void) onKLineDataReset:(NSNotification*)aNotification
{
    [self initKLineData:YES];
}

- (void) onUpdateMarketDetail:(NSNotification*)aNotification
{
    NSDictionary* pldDictionary = aNotification.object;
    if (pldDictionary && self.realtimeView)
    {
        NSString* strNetWorkSymbolId = [pldDictionary objectForKey:SYMBOLID];
        NSString* strSymbolId = [self getMyCurrentSymbolId];
        if (strSymbolId && strNetWorkSymbolId && [strNetWorkSymbolId isEqualToString:strSymbolId])
        {
            NSNumber* valuePh = [pldDictionary objectForKey:PRICEHIGH];
            NSNumber* valuePl = [pldDictionary objectForKey:PRICELOW];
            NSNumber* valuePn = [pldDictionary objectForKey:PRICENEW];
            NSNumber* valuePo = [pldDictionary objectForKey:PRICEOPEN];
            
            NSNumber* valueAmount = nil;
            if ( [self isSpotGoodsOfSymbolId:strNetWorkSymbolId])
            {
                valueAmount = [pldDictionary objectForKey:TOTALAMOUNT];
            }
            else
            {
                valueAmount = [pldDictionary objectForKey:TOTALVOLUME];
            }
            
            
            if (valuePn)
            {
                float oldPrice = [_realtimeView.priceNew floatValue];
                if (oldPrice != [valuePn floatValue])
                {
                    if ([valuePn floatValue] < oldPrice)
                        _realtimeView.priceChangeType = -1;
                    else if ([valuePn floatValue] > oldPrice)
                        _realtimeView.priceChangeType = 1;
                    else
                        _realtimeView.priceChangeType = 0;
                    
                    NSString* strPn = [DLTextAttributeData stringFromPrice:[valuePn stringValue]];
                    _realtimeView.priceNew = strPn;
                    
                    double zRate = (valuePn.floatValue - valuePo.floatValue) * 100 /valuePo.floatValue;
                    NSString* strRate = [DLTextAttributeData stringNotRounding:zRate afterPoint:2];
                    _realtimeView.margin = [strRate stringByAppendingString:@"%"];
                }
                //else cont.
                
            }
            //else cont.
            
            if (valueAmount)
                _realtimeView.amount = [NSString stringWithFormat:@"%d",[valueAmount intValue]];
            //else cont.
            
            if (valuePl)
                _realtimeView.priceLow = [DLTextAttributeData stringFromPrice:[valuePl stringValue]];
            //else cont.
            
            if (valuePh)
                _realtimeView.priceHigh = [DLTextAttributeData stringFromPrice:[valuePh stringValue]];
            //else cont.
            
            [_realtimeView setNeedsDisplay];
        }
        //else 交易类型切换空隙时，会产生交易类型不一致的通知。
    }
    //else
    //HB_LOG(@"error!");
}

#pragma mark - kline view delegate
- (void) showDetailKLineView:(UIView*)currentKLineView
{
    NSString* strSymbolId = [self getMyCurrentSymbolId];
//    if (strSymbolId)
//    {
        if (_fullscreenKLineView)
        {
            _bHideStatusBar = YES;
            [self setNeedsStatusBarAppearanceUpdate];
            
            _fullscreenKLineView.hidden = NO;
            
            [self.view.window addSubview:_fullscreenKLineView];
            NSString* strPeriod = [self getCurrentPeriod];
            NSInteger segmentIndex = [_periodSegmentView getDataItemIndex];
            
            if (segmentIndex == 1)
                strPeriod = @"timeLine_type";
            //else cont.
            
            [[self getIndexView] removeFromSuperview];

            _klineView.bFullScreenMode = YES;
            
            [_fullscreenKLineView beginDrawKLine:_klineView
                                   strPeriod:strPeriod
                                    symbolId:strSymbolId];
            
            [_klineView hiddeCrossLine];
            

        }
        else
            HB_LOG(@"error!");
//    }
    //else cont.
}

- (void) closeDetailKLineView:(UIView*)currentKLineView periodKey:(NSString*)strPeriodKey;
{
    [_fullscreenKLineView removeFromSuperview];
    _fullscreenKLineView.hidden = YES;
    
    [_klineView removeFromSuperview];
    
    _bHideStatusBar = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    if (self.kLineViewBorderView)
    {
        _klineView.bFullScreenMode = NO;
        
        CGRect kLineRect = [self.kLineViewBorderView bounds];
        [_klineView setFrame:kLineRect];
        [_klineView initLandScapeSet];
        _klineView.hidden = NO;

        
        [self.kLineViewBorderView addSubview:_klineView];
        
    }
    else
        HB_LOG(@"error!");
    
    if ([strPeriodKey isEqualToString:@"timeLine_type"])
    {
        _klineView.bTimeLine = YES;

        [self setSegmentWithPeriod:strPeriodKey];
        [_klineView reloadKLineViewWithPeriod:KLINE1MIN];
    }
    else
    {
        if ( NSNotFound !=  [_periodArray indexOfObject:strPeriodKey] )
        {
            [self setSegmentWithPeriod:strPeriodKey];
            [_klineView reloadKLineViewWithPeriod:strPeriodKey];
        }
        else
        {
            [self removeActivityView];
            
             _klineView.bTimeLine = YES;
            [self setSegmentWithPeriod:@"timeLine_type"];
            [_klineView resetKLineViewWithPeriod:KLINE1MIN];
        }//endi
    }
}

- (void) addActivityToSuperView:(UIView*)superView
{
    NSString* strSymbolId = [self getMyCurrentSymbolId];
    if (strSymbolId)
    {
        if (superView && _activityView)
        {
            [superView addSubview:_activityView];
            [_activityView startAnimating];
            
            NSDictionary* args = @{@"period":[self getCurrentPeriod],@"symbolID":strSymbolId};
            [self performSelector:@selector(showNetworkAlert:) withObject:args afterDelay:1.0f];
        }
        //else cont.
    }

}

- (void) removeActivityView
{
    if([_activityView superview])
    {
        [_activityView stopAnimating];
        [_activityView removeFromSuperview];
        [_klineView setUserInteractionEnabled:YES];
    }
    //else cont.
}

- (NSString*) getTimeFromatByPeriod:(NSString*)strPeriod
{
    NSString* strResult = strResult = @"HH:mm";;
    //_periodArray = @[@"timeLine_type",@"1min",@"5min",@"15min",@"30min",@"60min",@"1day"];
    if ([strPeriod isEqualToString:@"1day"] || [strPeriod isEqualToString:KLINE1WEEK])
    {
        strResult = @"MM/dd";
    }
    //else time line
    
    return strResult;
}

- (void) showActivityView
{
    if (![_activityView superview])
    {
        CGSize activetySize = _activityView.frame.size;
        CGRect rectActivity = [_klineView getActivityIndicatorFrame];
        if (_fullscreenKLineView.hidden)
        {
            [_activityView setFrame:CGRectMake((self.view.frame.size.width - activetySize.width)/2 ,
                                               rectActivity.origin.y + (rectActivity.size.height - activetySize.height)/2,
                                               activetySize.width,
                                               activetySize.height)];
            
            [self addActivityToSuperView:self.kLineViewBorderView];
        }
        else
        {
            [_activityView setFrame:CGRectMake((_fullscreenKLineView.frame.size.height - activetySize.height)/2,
                                               (_fullscreenKLineView.frame.size.width - activetySize.width)/2 ,
                                               activetySize.width,
                                               activetySize.height)];
            [self addActivityToSuperView:_fullscreenKLineView];
        }
        
        [_klineView setUserInteractionEnabled:NO];
    }
    //else cont.
}

- (void) requestKLineWithPeriod:(NSString*)strPeriod
{
    if (![[DLMainManager sharedNetWorkManager] bEnterBack])
    {
        [[DLMainManager sharedMainManager] savePeriodType:strPeriod];
        
        if ([[DLMainManager sharedNetWorkManager] isNetWorkConnect])
        {
            [self showActivityView];
        }
        else
        {
            [self showNetworkAlert:nil];
        }
        
        //获得交易类型
        NSString* strSymbolId = [self getMyCurrentSymbolId];
        _keyPeriod = strPeriod;
        if (strSymbolId)
            [[DLMainManager sharedNetWorkManager] localRequestKLineWithPeriod:strPeriod widthSymbolId:strSymbolId];
        //else cont.
    }
    //else cont.
}

- (void) reloadKLineWithPeriod:(NSString*)strPeriod
{
    if ([_activityView superview])
    {
        [self removeActivityView];
        [self showActivityView];
    }
    //else cont.
    
    _keyPeriod = strPeriod;
    
    //活得交易类型
    NSString* strSymbolId = [self getMyCurrentSymbolId];
    if (strSymbolId)
    {
        NSDictionary* diction= @{
                                 @"version":@1,
                                 @"msgType":@"reqKLine",
                                 SYMBOLID:strSymbolId,
                                 PERIOD:strPeriod,
                                 @"from":@0,
                                 @"to":@-1
                                 };
        [[DLMainManager sharedDBManager] updateKLine:diction localUpdate:YES];
    }
    //else cont.
}

- (void) showNetworkAlert:(NSDictionary*)argsDict
{
    if (self.bFinishLaunch)
    {
        if( 0 == self.tabBarController.selectedIndex)
        {
            if (argsDict)
            {
                NSString* strPeriod = [argsDict objectForKey:@"period"];
                NSString* strNetSymbolID = [argsDict objectForKey:@"symbolID"];
                NSString* strSymbolID = [self getMyCurrentSymbolId];
                if (strSymbolID)
                {
                    if ([strPeriod isEqualToString:[self getCurrentPeriod]]
                        && [strNetSymbolID isEqualToString:strSymbolID]
                        && _activityView.isAnimating)
                    {
                        [_activityView removeFromSuperview];
                        [_activityView stopAnimating];
                        _klineView.userInteractionEnabled = YES;
                        
                        [[DLMainManager sharedNetWorkManager] showNetWorkAlert];
                    }
                    //else cont.
                }
                //else cont.
            }
            else
            {
                //no network
                [[DLMainManager sharedNetWorkManager] showNetWorkAlert];
            }//endi
        }
        //other tab
    }
    //else cont.
}

#pragma mark - application

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return _bHideStatusBar; //返回NO表示要显示，返回YES将hiden
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL) isSpotGoodsOfSymbolId:(NSString*)symbolId
{
    NSArray* spotArray = [DLMainManager symbolsArrayOfHuobi];
    BOOL bResult = (NSNotFound != [spotArray indexOfObject:symbolId]);
    return bResult;
}


#pragma mark - back button

- (IBAction)onBackClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^()
     {
         self.titleLabel.text = @"";
         //MARK: 返回上一个页面
//         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TABBAR_SHOW object:nil];
         
     }];
}

- (IBAction)onBackTouchDown:(id)sender
{
    [self.backLabel setHighlighted:YES];
}
- (IBAction)onTradeTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        //MARK: 返回上一个页面
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHANGE_TO_SPOTGOODS object:nil];
    }];
}
@end
