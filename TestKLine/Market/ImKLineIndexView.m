//
//  ImKLineIndexView.m
//  BigHuobi
//
//  Created by huobiSystem on 15/5/27.
//  Copyright (c) 2015年 Huobi. All rights reserved.
//

#import "ImKLineIndexView.h"
#import "UIColor+helper.h"
//#import "CONFIG_CONSTAN.h"
#import "KlineConstant.h"
#define STANDARD_WIDTH  320

@implementation ImKLineIndexView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) aaa
{
    CGFloat leftSpan = 11.0f;
    
    {
        CGRect mainChartFrame = CGRectMake(leftSpan, 10, 50, 25);
        UILabel* mainChartName = [[UILabel alloc] initWithFrame:mainChartFrame];
        mainChartName.tag = 10;
        mainChartName.textAlignment = NSTextAlignmentLeft;
        mainChartName.text = NSLocalizedString(@"SR_MainChart",@"");
        mainChartName.font = [UIFont systemFontOfSize:12];
        mainChartName.textColor = [UIColor colorWithHexString:@"0x5e6c7f" withAlpha:1.0f];
        [mainChartName sizeToFit];
        [self addSubview:mainChartName];
        
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
    
    [self addSubview:spitLine];
    
    {
        CGRect extraChartFrame = CGRectMake(leftSpan, 87, 50, 25);
        UILabel* extraChartName = [[UILabel alloc] initWithFrame:extraChartFrame];
        extraChartName.tag = 20;
        extraChartName.text = NSLocalizedString(@"SR_EXTRAChart",@"");
        extraChartName.font = [UIFont systemFontOfSize:12];
        extraChartName.textColor = [UIColor colorWithHexString:@"0x5e6c7f" withAlpha:1.0f];
        [extraChartName sizeToFit];
        [self addSubview:extraChartName];
        
        
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
}


- (UIButton*) addButtonWithFrame:(CGRect)frame withTag:(NSInteger)tag withTitle:(NSString*)title
{
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
    [self addSubview:resultButton];
    
    [resultButton addTarget:self action:@selector(onItemSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    return resultButton;
}

- (void) setMainChatWithMainChatType:(NSInteger)mainchatType
{
    UIButton* button = nil;
    switch (mainchatType) {
        case KLINE_TYPE_MA:
            button = (UIButton*)[self viewWithTag:11];
            break;
            
        case KLINE_TYPE_BOLL:
            button = (UIButton*)[self viewWithTag:12];
            break;
            
        case KLINE_TYPE_NONE:
            button = (UIButton*)[self viewWithTag:13];
            break;
        default:
            break;
    }
    
    // 主图菜单按钮
    if (10 < button.tag && button.tag < 20)
    {
        for (NSInteger tag = 11; tag <= 13 ; tag++)
        {
            UIButton* aButton = (UIButton*)[self viewWithTag:tag];
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
    UIButton* button = nil;
    switch (macdType) {
        case MACD_TYPE_MACD:
            button = (UIButton*)[self viewWithTag:21];
            break;
            
        case MACD_TYPE_KDJ:
            button = (UIButton*)[self viewWithTag:22];
            break;
            
        case MACD_TYPE_RSI:
            button = (UIButton*)[self viewWithTag:23];
            break;
        case MACD_TYPE_WR:
            button = (UIButton*)[self viewWithTag:24];
            break;
        case MACD_TYPE_NONE:
            button = (UIButton*)[self viewWithTag:25];
            break;
        default:
            break;
    }
    
    // 副图菜单按钮
    if (20 < button.tag && button.tag < 30)
    {
        for (NSInteger tag = 21; tag <= 25 ; tag++)
        {
            UIButton* aButton = (UIButton*)[self viewWithTag:tag];
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
            UIButton* aButton = (UIButton*)[self viewWithTag:tag];
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
            UIButton* aButton = (UIButton*)[self viewWithTag:tag];
            if ([aButton isKindOfClass:[UIButton class]] && tag != button.tag)
            {
                [aButton setTitleColor:[UIColor colorWithHexString:@"0xffffff" withAlpha:1.0] forState:UIControlStateNormal];
            }
            //else cont.
        }//endf
    }
    //else cont.
    
    [button setTitleColor:[UIColor colorWithHexString:@"0x1686cc" withAlpha:1.0] forState:UIControlStateNormal];
    
    //    [self showDetailKLineView:_klineView];
}
@end
