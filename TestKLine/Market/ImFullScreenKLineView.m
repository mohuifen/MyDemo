//
//  ImFullScreenKLineView.m
//  huobiSystem
//
//  Created by FuliangYang on 14-7-31.
//  Copyright (c) 2014年 FuliangYang. All rights reserved.
//

#import "ImFullScreenKLineView.h"
#import "DLMainManager.h"
#import "KlineConstant.h"
#import "DLTextAttributeData.h"
#import "ImScreenTouchesAction.h"
#import "UIColor+helper.h"
#import "ImSegmentView.h"
#import "ImHBLog.h"
#import "HBViewHelper.h"
#define CONTROL_CONTENT_WIDTH 0.0f
#define CONTROL_CONTENT_HIGHT 30.0f

#define STANDARD_WIDTH  568

#define STANDARD_HEIGHT 320

#define VIEW_TAG_CELA 1
@interface ImFullScreenKLineView()
{
    ImKLineLandScapeView* _klineView;
    ImSegmentView* _periodSegmentView;
    NSArray* _periodArray;
    CGFloat _closeHeight;
    NSArray* _arrayValue;
    NSUInteger _selectedItem;
    UIButton* _menuButton;
    
    UIView* _indexView;
}
@end

@implementation ImFullScreenKLineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _periodArray = @[@"timeLine_type",KLINE1MIN,@"5min",@"30min",@"60min",@"1day",KLINE1WEEK];
        _closeHeight = 12.0f;
        [self initContent];
    }
    return self;
}

- (void) setKLineDelegate:(id<ImKLineViewDelegate>)delegate
{
    _klineView.delegate = delegate;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) initContent
{
    self.backgroundColor = [UIColor colorWithHexString:@"0x292d34" withAlpha:1.0f];
    //[self initTopCotent];
    [self initControlCotent];
}

- (void) initTopCotent
{
    CGRect landRect = self.frame;

    //添加关闭按钮
    UIImage* closeImage = [UIImage imageNamed:@"market_closedetail"];
    CGRect closeFrame = CGRectMake(landRect.size.width - closeImage.size.width - 10.0f,
                                   9.0f,
                                   closeImage.size.width,
                                   closeImage.size.height);
    
    UIButton* closeButton = [[UIButton alloc] initWithFrame:closeFrame];
    [closeButton setImage:closeImage forState:UIControlStateNormal];
    [closeButton setImage:[UIImage imageNamed:@"market_closedetail"] forState:UIControlStateHighlighted];
    [closeButton addTarget:self action:@selector(onCloseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
}
#pragma mark - left content

- (void) initControlCotent
{
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
                               [UIImage imageNamed:@"market_nav_selected"],
                               
                               [UIImage imageNamed:@"market_nav_normal"],
                               [UIImage imageNamed:@"market_nav_selected"],
                               
                               [UIImage imageNamed:@"market_nav_normal"],
                               [UIImage imageNamed:@"market_nav_selected"]];
    
    NSArray* textSegArray = @[NSLocalizedString(@"SR_INDEX", @""),
                              NSLocalizedString(@"SR_KlineTimeline", @""),
                              NSLocalizedString(@"SR_Kline1min", @""),
                              NSLocalizedString(@"SR_Kline5min", @""),
                              NSLocalizedString(@"SR_Kline30min", @""),
                              NSLocalizedString(@"SR_Kline60min", @""),
                              NSLocalizedString(@"SR_Kline1day", @""),
                              NSLocalizedString(@"SR_Kline1week", @"")];
    
    CGRect rectSegView = CGRectMake(0, self.bounds.size.height - CONTROL_CONTENT_HIGHT, self.bounds.size.width, CONTROL_CONTENT_HIGHT);
    _periodSegmentView = [[ImSegmentView alloc] initSegmentWithFrame:rectSegView
                                                    withButtonCount:[textSegArray count]
                                                             target:self
                                                           selector:@selector(onFullScreenPeriodClicked:)];
    
    _periodSegmentView.controlIndex = 0;
    _periodSegmentView.selectedTextColor = [UIColor colorWithHexString:@"0x1686cc" withAlpha:1.0f];
    _periodSegmentView.normalTextColor = [UIColor colorWithHexString:@"0x434b56" withAlpha:1.0f];
    _periodSegmentView.normalControlColor = [UIColor colorWithHexString:@"0x434b56" withAlpha:1.0f];
    [_periodSegmentView setText:textSegArray forState:UIControlStateNormal];
    [_periodSegmentView setBackgroundImage:imageSegArray forState:UIControlStateNormal];
    [_periodSegmentView setDataItemIndex:1];
    
    
    [self addSubview:_periodSegmentView];
}

#pragma mark  - add or remove kline

#define KLINE_SUBVIEW_TAG_CLOSEBUTTON 10
- (void) addKLineView:(ImKLineLandScapeView*)kLineView
{
    CGRect landRect = self.frame;
    CGRect kLineRect = CGRectMake(CONTROL_CONTENT_WIDTH, _closeHeight, landRect.size.width - CONTROL_CONTENT_WIDTH, landRect.size.height - _closeHeight - 3.0f - CONTROL_CONTENT_HIGHT);
    _klineView = kLineView;
    [_klineView setFrame:kLineRect];
    [_klineView initLandScapeSet];
    [self addSubview:kLineView];
    
    if (![kLineView viewWithTag:KLINE_SUBVIEW_TAG_CLOSEBUTTON])
    {
        //添加关闭按钮
        UIImage* closeImage = [UIImage imageNamed:@"market_closedetail"];
        CGRect closeFrame = CGRectMake(landRect.size.width - closeImage.size.width - 10.0f,
                                       0.0f,
                                       closeImage.size.width,
                                       closeImage.size.height);
        
        UIButton* closeButton = [[UIButton alloc] initWithFrame:closeFrame];
        closeButton.tag = KLINE_SUBVIEW_TAG_CLOSEBUTTON;
        [closeButton setImage:closeImage forState:UIControlStateNormal];
        [closeButton setImage:[UIImage imageNamed:@"market_closedetail"] forState:UIControlStateHighlighted];
        [closeButton addTarget:self action:@selector(onCloseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [kLineView addSubview:closeButton];
    }
    else
        [[_klineView viewWithTag:KLINE_SUBVIEW_TAG_CLOSEBUTTON] setHidden:NO];
    
    //（获取当前电池条动画改变的时间
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    
    //在这里设置view.transform需要匹配的旋转角度的大小就可以了。
    self.transform = [self getTransformMakeRotationByOrientation:UIInterfaceOrientationLandscapeRight];
    [UIView commitAnimations];
}

- (void) beginDrawKLine:(ImKLineLandScapeView*)kLineView strPeriod:(NSString*)strPeriod symbolId:(NSString*)strSymbolID
{
    if (!_klineView)
    {
        //kLineView.MACDType = MACD_TYPE_MACD;
        kLineView.detailDelegate = self;
        [kLineView removeFromSuperview];
        
        _klineView = kLineView;
        [self addKLineView:kLineView];
        
        NSInteger theIndex = [_periodArray indexOfObject:strPeriod];
        if (NSNotFound != theIndex)
        {
            [_periodSegmentView setDataItemIndex:theIndex + 1];
            
            if (0 == theIndex)
            {
                strPeriod = [_periodArray objectAtIndex:1];
                kLineView.bTimeLine = YES;
            }
            else
                kLineView.bTimeLine = NO;
            
            [kLineView reloadKLineViewWithPeriod:strPeriod];

        }
        else
            HB_LOG(@"error!");
    }
    else
        HB_LOG(@"error!");
}


- (void) hiddeLabel
{
    [self setNeedsDisplay];
    [_klineView hiddeCrossLine];
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

- (void) onCloseButtonClicked:(id)sender
{
    ImScreenTouchesAction *screenTouchesAction = [ImScreenTouchesAction getInstance];
    [screenTouchesAction setScreenLight];
    
    //(NSString*)strPeriodKey
    if ([self.delegate respondsToSelector:@selector(closeDetailKLineView:periodKey:)])
    {
        //关闭侧拉菜单
        if (_menuButton)
            [_menuButton setImage:[UIImage imageNamed:@"caidan"] forState:UIControlStateNormal];
        //else cont.
        
        [[self getIndexView] removeFromSuperview];
        
        if (![_klineView viewWithTag:KLINE_SUBVIEW_TAG_CLOSEBUTTON])
            [[_klineView viewWithTag:KLINE_SUBVIEW_TAG_CLOSEBUTTON] setHidden:YES];
        //else cont.
        
        [self hiddeLabel];

        _klineView = nil;
        
        NSInteger currentIndex = [_periodSegmentView getDataItemIndex];
        NSString* strPeriodKey = [self getFullScreenPeriodOfIndex:currentIndex];
        
        [self.delegate closeDetailKLineView:self periodKey:strPeriodKey];
        
        //（获取当前电池条动画改变的时间
        CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:duration];
        
        //在这里设置view.transform需要匹配的旋转角度的大小就可以了。
        self.transform = [self getTransformMakeRotationByOrientation:UIInterfaceOrientationPortrait];
        [UIView commitAnimations];
    }
    else
        HB_LOG(@"error!");
}

- (CGAffineTransform)getTransformMakeRotationByOrientation:(UIInterfaceOrientation)orientation
{
    if (orientation == UIInterfaceOrientationLandscapeLeft)
    {
        return CGAffineTransformMakeRotation(M_PI/2);
    }
    else if (orientation == UIInterfaceOrientationLandscapeRight)
    {
        return CGAffineTransformMakeRotation(M_PI/2);
    }
    else if (orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        return CGAffineTransformMakeRotation(-M_PI);
    }
    else if (orientation == UIInterfaceOrientationPortrait)
    {
        return CGAffineTransformMakeRotation(0);
    }
    
    return CGAffineTransformIdentity;
}

#pragma mark - action

- (NSString*) getFullScreenPeriodOfIndex:(NSInteger)index
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

- (void) onFullScreenPeriodClicked:(id)sender
{
#if 1
    
    NSString* strPeriod = nil;
    NSInteger segmentIndex = [_periodSegmentView getButtonIndex];
    strPeriod = [self getFullScreenPeriodOfIndex:segmentIndex];
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
    
    [self hiddeLabel];
#else
    UIButton* button = sender;
    NSString* strPeriod = KLINE1MIN;
    
    if (button.tag == 0)
    {
        _klineView.bTimeLine = YES;
    }
    else
    {
        _klineView.bTimeLine = NO;
        strPeriod = [_periodArray objectAtIndex:button.tag];
    }

    [_klineView resetKLineViewWithPeriod:strPeriod];
    
    [self hiddeLabel];
#endif
}

#pragma mark - draw

- (NSInteger) drawPriceValue:(NSInteger)originX nOffsetY:(NSInteger)nOffsetY
{
    CGFloat zInterval = 10.0f;
    
    NSDictionary* textAttr = @{NSFontAttributeName:[UIFont systemFontOfSize:8.0f],
                               NSForegroundColorAttributeName:[UIColor colorWithHexString:@"0x616c78" withAlpha:1.0f]};
    
    NSString* SR_OpenColon = NSLocalizedString(@"SR_OpenColon", @"");
    NSString* SR_HighColon = NSLocalizedString(@"SR_HighColon", @"");
    NSString* SR_LowColon = NSLocalizedString(@"SR_LowColon", @"");
    NSString* SR_CloseColon = NSLocalizedString(@"SR_CloseColon", @"");
    
    
    //开 name
    CGSize openNameSize = [DLTextAttributeData sizeOfString:SR_OpenColon withDict:textAttr];
    [DLTextAttributeData drawString:SR_OpenColon atPoint:CGPointMake(originX, nOffsetY) withAttributes:textAttr];
    originX += openNameSize.width;
    
    //开
    NSString* strOpenPrice = [_arrayValue objectAtIndex:0];
    CGSize openSize = [DLTextAttributeData sizeOfString:strOpenPrice withDict:textAttr];
    if (strOpenPrice)
        [DLTextAttributeData drawString:strOpenPrice atPoint:CGPointMake(originX, nOffsetY) withAttributes:textAttr];
    //else cont.
    originX += openSize.width + zInterval;
    
    //高 name
    CGSize highNameSize = [DLTextAttributeData sizeOfString:SR_HighColon withDict:textAttr];
    [DLTextAttributeData drawString:SR_HighColon atPoint:CGPointMake(originX, nOffsetY) withAttributes:textAttr];
    originX += highNameSize.width;
    
    //高
    NSString* strHighPrice = [_arrayValue objectAtIndex:1];
    CGSize highSize = [DLTextAttributeData sizeOfString:strHighPrice withDict:textAttr];;
    if (strHighPrice)
        [DLTextAttributeData drawString:strHighPrice atPoint:CGPointMake(originX, nOffsetY) withAttributes:textAttr];
    //else cont.
    originX += highSize.width + zInterval;
    
    //低
    CGSize lowNameSize = [DLTextAttributeData sizeOfString:SR_LowColon withDict:textAttr];
    [DLTextAttributeData drawString:SR_LowColon atPoint:CGPointMake(originX, nOffsetY) withAttributes:textAttr];
    originX += lowNameSize.width;
    
    //低
    NSString* strLowPrice = [_arrayValue objectAtIndex:2];
    CGSize lowSize = [DLTextAttributeData sizeOfString:strLowPrice withDict:textAttr];
    if (strLowPrice)
        [DLTextAttributeData drawString:strLowPrice atPoint:CGPointMake(originX, nOffsetY) withAttributes:textAttr];
    //else cont.
    originX += lowSize.width + zInterval;
    
    //收 name
    CGSize lastNameSize = [DLTextAttributeData sizeOfString:SR_CloseColon withDict:textAttr];
    [DLTextAttributeData drawString:SR_CloseColon atPoint:CGPointMake(originX, nOffsetY) withAttributes:textAttr];
    originX += lastNameSize.width;
    
    //收
    NSString* strLastPrice = [_arrayValue objectAtIndex:3];
    CGSize lastSize = [DLTextAttributeData sizeOfString:strLastPrice withDict:textAttr];
    if (strLastPrice)
        [DLTextAttributeData drawString:strLastPrice atPoint:CGPointMake(originX, nOffsetY) withAttributes:textAttr];
    //else cont.
    originX += lastSize.width + zInterval;
    
    return originX;
}

- (NSInteger) drawAverageValue:(NSInteger)originX nOffsetY:(NSInteger)nOffsetY
{
    CGFloat zInterval = 10.0f;
    CGFloat nFontSize = 8.0f;
    if (_klineView.bTimeLine)
    {
        NSDictionary* textAttr = @{NSFontAttributeName:[UIFont systemFontOfSize:nFontSize],
                                   NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#fffc00" withAlpha:self.alpha]};
        
        NSString* strValue = [_arrayValue objectAtIndex:4];
        CGSize valueSize = [DLTextAttributeData sizeOfString:strValue withDict:textAttr];
        [DLTextAttributeData drawString:strValue atPoint:CGPointMake(originX, nOffsetY) withAttributes:textAttr];
        originX += valueSize.width + zInterval;
    }
    else
    {
        for (int nIndex = 4; nIndex < [_arrayValue count]; nIndex++)
        {
            NSDictionary* textAttr = nil;
            switch (nIndex - 4)
            {
                case 0:
                {
                    textAttr = @{NSFontAttributeName:[UIFont systemFontOfSize:nFontSize],
                                 NSForegroundColorAttributeName:[UIColor whiteColor]};
                    break;
                }
                case 1:
                {
                    textAttr = @{NSFontAttributeName:[UIFont systemFontOfSize:nFontSize],
                                 NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#fffc00" withAlpha:self.alpha]};
                    break;
                }
                case 2:
                {
                    if (_klineView.mainchatType == KLINE_TYPE_BOLL)
                    {
                        textAttr = @{NSFontAttributeName:[UIFont systemFontOfSize:nFontSize],
                                     NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#ff0095" withAlpha:self.alpha]};
                    }
                    else
                    {
                        textAttr = @{NSFontAttributeName:[UIFont systemFontOfSize:nFontSize],
                                     NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#1ae405" withAlpha:self.alpha]};
                    }//endi
                    
                    break;
                }
                    
                default:
                    HB_LOG(@"error!");
                    break;
            }
            if (textAttr)
            {
                NSString* strValue = [_arrayValue objectAtIndex:nIndex];
                CGSize valueSize = [DLTextAttributeData sizeOfString:strValue withDict:textAttr];
                [DLTextAttributeData drawString:strValue atPoint:CGPointMake(originX, nOffsetY) withAttributes:textAttr];
                originX += valueSize.width + zInterval;
            }
            else
                HB_LOG(@"error");
        }//endf
    }//endi
    
    return originX;
}

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (_klineView)
    {
        if (_arrayValue)
        {
            if ([_arrayValue count] >= 5)
            {
                NSInteger originX = CONTROL_CONTENT_WIDTH + 10.0f;
                NSInteger nOffsetY = 15.0f;
                
                originX = [self drawPriceValue:originX nOffsetY:nOffsetY];
                originX = [self drawAverageValue:originX nOffsetY:nOffsetY];
                _arrayValue = nil;
            }
            else
                HB_LOG(@"error!");
        }
        //else 刚显示detail view，未点击十字线！n多情况会进入此分支。
    }
    else
        HB_LOG(@"error!");
}


- (void) setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    _klineView.hidden = hidden;
}
#pragma mark - delegate

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    ImScreenTouchesAction *screenTouchesAction = [ImScreenTouchesAction getInstance];
    [screenTouchesAction setScreenLight];
}

#pragma mark - popup

#define VIEW_TAG_INDEX 1

- (UIView*) getIndexView
{
    CGRect segBounds = _periodSegmentView.bounds;
    CGRect segFrame = [self convertRect:segBounds fromView:_periodSegmentView];
    CGFloat width = self.bounds.size.width;
    CGFloat height = 154.0f;//self.view.frame.size.width;
    CGFloat originX = segFrame.origin.x;
    CGFloat originY = segFrame.origin.y - height;
    
    if (!_indexView)
    {
        _indexView = [[UIView alloc] initWithFrame:CGRectMake(originX, originY, width, height)];
        _indexView.backgroundColor = [UIColor colorWithHexString:@"0x101416" withAlpha:0.93];
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
        
        
        
        CGRect spitLineFrame = CGRectZero;
        spitLineFrame.origin.x = 16;
        spitLineFrame.origin.y = 78;
        spitLineFrame.size.width = self.bounds.size.width - spitLineFrame.origin.x * 2;
        spitLineFrame.size.height = 1.0f;
        
        UIImageView* spitLine = [[UIImageView alloc] initWithFrame:spitLineFrame];
        [spitLine setImage:[UIImage imageNamed:@"market_menu_splitline"]];
        
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
        
        CGFloat theWidthRate = self.bounds.size.width / STANDARD_WIDTH;
        CGFloat theHeightRate = self.bounds.size.height / STANDARD_HEIGHT;
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
        [self addSubview:indexView];
        
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

- (IBAction) onItemSelected:(id)sender
{
    UIView* indexView = [self getIndexView];
    
    UIButton* button = sender;
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
    
    if ([self.delegate respondsToSelector:@selector(getCurrentPeriod)])
    {
        NSString* strPeriod = [self.delegate getCurrentPeriod];
        [_klineView initLandScapeSet];
        [_klineView reloadKLineViewWithPeriod:strPeriod];
    }
    //    [self showDetailKLineView:_klineView];
    
    [indexView removeFromSuperview];
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


@end
