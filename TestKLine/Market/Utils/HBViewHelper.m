//
//  HBViewHelper.m
//  BigHuobi
//
//  Created by huobiSystem on 15/5/22.
//  Copyright (c) 2015年 Huobi. All rights reserved.
//

#import "HBViewHelper.h"
#import "UIView+Extension.h"

@implementation HBViewHelper

+ (void) reframeView:(UIView*)aview widthRate:(CGFloat)widthRate hightRate:(CGFloat)hightRate
{
    if ([[aview subviews] count] > 0)
    {
        CGRect rect = CGRectZero;
        for (UIView* subView in [aview subviews])
        {
            rect = subView.frame;
            
            NSInteger orginX = rect.origin.x * widthRate;
            NSInteger orginY = rect.origin.y * hightRate;
            
            NSInteger width = rect.size.width * widthRate;
            
            if (0 == width)
            {
                width = 1;
            }
            //else cont.
            
            NSInteger height = rect.size.height * hightRate;
            if (0 == height)
            {
                height = 1;
            }
            //else cont.
            
            [subView setFrame:CGRectMake(orginX, orginY, width, height)];
            
            [HBViewHelper reframeView:subView widthRate:widthRate hightRate:hightRate];
        }//endf
    }
    //else cont.
}

+ (void) reframeLayer:(CALayer*)aLayer widthRate:(CGFloat)widthRate hightRate:(CGFloat)hightRate
{
    if ([[aLayer sublayers] count] > 0)
    {
        CGRect rect = CGRectZero;
        for (CALayer* subLayer in [aLayer sublayers])
        {
            rect = subLayer.frame;
            
            NSInteger orginX = rect.origin.x * widthRate;
            NSInteger orginY = rect.origin.y * hightRate;            
            [subLayer setFrame:CGRectMake(orginX, orginY, rect.size.width, rect.size.height)];
            
            [HBViewHelper reframeLayer:subLayer widthRate:widthRate hightRate:hightRate];
        }//endf
    }
    //else cont.
}

+ (void) reframeImageView:(UIImageView*)aImageView withRate:(CGFloat)rate
{
    CGSize buySize = aImageView.image.size;
    CGFloat buyWidth = buySize.width * rate;
    CGFloat buyHeight = buySize.height * rate;
    CGRect buyFrame = aImageView.frame;
    [aImageView setFrame:CGRectMake(buyFrame.origin.x, buyFrame.origin.y, buyWidth, buyHeight)];
    [aImageView setX:(buyFrame.origin.x + buyWidth*fabs(1-rate)*0.5)];
    [aImageView setY:(buyFrame.origin.y + buyHeight*fabs(1-rate)*0.5)];
}

+ (void) reframeIconView:(UIImageView*)iconView withTitle:(UILabel*)titleView
{
    [iconView sizeToFit];
    CGRect rectPriceTitle = titleView.frame;
    CGRect rectPrice = iconView.frame;
    rectPrice.origin.x = rectPriceTitle.origin.x + rectPriceTitle.size.width + 1;
    rectPrice.origin.y = rectPriceTitle.origin.y + (rectPriceTitle.size.height - rectPrice.size.height) / 2;
    [iconView setFrame:rectPrice];
}

+ (void) reframeViewSelf:(UIView*)view widthRate:(CGFloat)widthRate hightRate:(CGFloat)hightRate
{
    [view setFrame:CGRectMake(view.x * widthRate, view.y * hightRate, view.width * widthRate, view.height * hightRate)];
}

+ (void) reframeView:(UIView*)aview widthRate:(CGFloat)widthRate hightRate:(CGFloat)hightRate exceptHeightOfView:(UIView*)exceptView
{
    CGFloat exceptOriginHeight = exceptView.height;
    [self reframeView:aview widthRate:widthRate hightRate:hightRate];
    [exceptView setHeight:exceptOriginHeight];
}

@end
