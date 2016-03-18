//
//  ImKLineInfoView.m
//  BigHuobi
//
//  Created by huobiSystem on 15/5/27.
//  Copyright (c) 2015年 Huobi. All rights reserved.
//

#import "ImKLineInfoView.h"
#import "DLMainManager.h"
#import "DLTextAttributeData.h"
#import "ImScreenTouchesAction.h"
#import "UIColor+helper.h"
#import "ImSegmentView.h"
#import "ImHBLog.h"
#import "KlineConstant.h"
#import "HBViewHelper.h"

@interface ImKLineInfoView ()
{
    NSArray* _arrayValue;
}

@end

@implementation ImKLineInfoView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) updateTopLabel:(NSArray*)priceArray
{
    _arrayValue = priceArray;
    [self setNeedsDisplay];
    
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    ImScreenTouchesAction *screenTouchesAction = [ImScreenTouchesAction getInstance];
    [screenTouchesAction setScreenLight];
}

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
    if (self.timeLine)
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
                    if (self.macdType == KLINE_TYPE_BOLL)
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
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    if (_arrayValue)
    {
        if ([_arrayValue count] >= 4)
        {
            NSInteger originX = 15;
            NSInteger nOffsetY = 5.0f;
            
            originX = [self drawPriceValue:originX nOffsetY:nOffsetY];
            
            if (self.bFullScreenMode )
                originX = [self drawAverageValue:originX nOffsetY:nOffsetY];
            //else cont.
            
            _arrayValue = nil;
        }
        else
            HB_LOG(@"error!");
    }
    //else 刚显示detail view，未点击十字线！n多情况会进入此分支。
}

@end
