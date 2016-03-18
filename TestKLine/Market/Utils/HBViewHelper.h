//
//  HBViewHelper.h
//  BigHuobi
//
//  Created by huobiSystem on 15/5/22.
//  Copyright (c) 2015年 Huobi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBViewHelper : NSObject

+ (void) reframeView:(UIView*)aview widthRate:(CGFloat)widthRate hightRate:(CGFloat)hightRate;

+ (void) reframeImageView:(UIImageView*)aImageView withRate:(CGFloat)rate;

+ (void) reframeLayer:(CALayer*)aLayer widthRate:(CGFloat)widthRate hightRate:(CGFloat)hightRate;

+ (void) reframeIconView:(UIImageView*)iconView withTitle:(UILabel*)titleView;

+ (void) reframeViewSelf:(UIView*)view widthRate:(CGFloat)widthRate hightRate:(CGFloat)hightRate;
@end
