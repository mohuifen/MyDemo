//
//  ImKLineDetailView.h
//  huobiSystem
//
//  Created by FuliangYang on 14-7-31.
//  Copyright (c) 2014年 FuliangYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImKLineLandScapeView.h"

@interface ImFullScreenKLineView : UIView<ImFullScreenKLineViewDelegate>

@property (nonatomic, assign) id<ImKLineViewDelegate> delegate;

- (void) beginDrawKLine:(ImKLineLandScapeView*)kLineView
              strPeriod:(NSString*)strPeriod
               symbolId:(NSString*)strSymbolID;

- (void) setKLineDelegate:(id<ImKLineViewDelegate>)delegate;

- (void) addKLineView:(UIView*)kLineView;

- (void) setExtraChatWithMACDType:(NSInteger)macdType;

- (void) setMainChatWithMainChatType:(NSInteger)mainchatType;
@end
