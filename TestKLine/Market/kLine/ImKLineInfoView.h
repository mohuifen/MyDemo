//
//  ImKLineInfoView.h
//  BigHuobi
//
//  Created by huobiSystem on 15/5/27.
//  Copyright (c) 2015年 Huobi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImKLineLandScapeView.h"
@interface ImKLineInfoView : UIView
@property (assign) BOOL timeLine;
@property (assign) NSInteger mainchatType;
@property (assign) NSInteger macdType;
@property (assign) BOOL bFullScreenMode;
- (void) updateTopLabel:(NSArray*)priceArray;
@end
