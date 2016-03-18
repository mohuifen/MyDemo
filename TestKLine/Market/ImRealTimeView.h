//
//  ImRealTimeView.h
//  huobiSystem
//
//  Created by FuliangYang on 14-8-21.
//  Copyright (c) 2014年 FuliangYang. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  K线页面头部的行情信息
 */
@interface ImRealTimeView : UIView
@property (nonatomic,copy) NSString* priceNew;
@property (nonatomic,copy) NSString* priceHigh;
@property (nonatomic,copy) NSString* priceLow;
@property (nonatomic,copy) NSString* margin;
@property (nonatomic,copy) NSString* amount;
@property (nonatomic,assign) NSInteger priceChangeType;
@property (nonatomic,assign) NSInteger bSpotGoods;
@end
