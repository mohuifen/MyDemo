//
//  ImDrawTask.h
//  huobiSystem
//
//  Created by FuliangYang on 14-8-11.
//  Copyright (c) 2014年 FuliangYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ImDrawTask : NSObject
{
    
}
@property (nonatomic, assign) NSInteger updateType;
@property (nonatomic,assign) BOOL bTimeLine;
@property (nonatomic,retain) NSArray *data;
@property (nonatomic,retain) NSArray *category;
@property (nonatomic,assign) CGFloat frontMaxValue;
@property (nonatomic,assign) CGFloat frontMinValue;
@property (nonatomic,assign) CGFloat frontAmountMaxValue;
@property (nonatomic,assign) CGFloat frontAmountMinValue;
@property (nonatomic,assign) int mainchatType;
@property (nonatomic,assign) int MACDType;
@property (nonatomic,assign) CGFloat MACDMaxValue;
@property (nonatomic,assign) CGFloat MACDMinValue;
@property (nonatomic,assign) NSInteger kLineWidth;
@property (nonatomic,assign) NSInteger kLinePadding;
@property (nonatomic,assign) CGFloat bollMaxValue;
@property (nonatomic,assign) CGFloat bollMinValue;
@end
