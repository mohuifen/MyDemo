//
//  UIColor+helper.h
//  Kline
//
//  Created by zhaomingxi on 14-2-9.
//  Copyright (c) 2014年 zhaomingxi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorModel.h"
//@class colorModel;
@interface UIColor (helper)

+ (UIColor *) textGrayColor;
+ (UIColor *) themeColor;
+ (UIColor *) colorWithHexString: (NSString *)color;//完全不透明
+ (UIColor *) colorWithHexString: (NSString *)color withAlpha:(CGFloat)alpha;
+ (ColorModel *) RGBWithHexString: (NSString *)color withAlpha:(CGFloat)alpha;

@end
