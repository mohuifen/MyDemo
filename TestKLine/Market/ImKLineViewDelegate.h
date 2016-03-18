//
//  ImKLineViewDelegate.h
//  huobiSystem
//
//  Created by FuliangYang on 14-8-1.
//  Copyright (c) 2014年 FuliangYang. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol ImKLineViewDelegate <NSObject>
@optional
- (void) showDetailKLineView:(UIView*)currentKLineView;

- (void) closeDetailKLineView:(UIView*)currentKLineView periodKey:(NSString*)strPeriodKey;

- (void) updateTopLabel:(NSArray*)priceArray;

- (void) pansOnKLineView:(UIView*)currentKLineView;

- (void) longPressesOnKLineView:(UIView*)currentKLineView;

- (void) requestKLineWithPeriod:(NSString*)strPeriod;

- (void) reloadKLineWithPeriod:(NSString*)strPeriod;

- (NSString*) getCurrentPeriod;

- (NSString*) getTimeFromatByPeriod:(NSString*)strPeriod;
@end

@protocol ImFullScreenKLineViewDelegate <NSObject>
@optional
- (void) updateTopLabel:(NSArray*)priceArray;
@end

