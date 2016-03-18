//
//  ImKLineIndexView.h
//  BigHuobi
//
//  Created by huobiSystem on 15/5/27.
//  Copyright (c) 2015年 Huobi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImKLineLandScapeView.h"


/**
 *  这是下面的点击指标选项显示的两排 Button 的 View
 */
@interface ImKLineIndexView : UIView
{
    ImKLineLandScapeView* _klineView;
}

- (void) setMainChatWithMainChatType:(NSInteger)mainchatType;
- (void) setExtraChatWithMACDType:(NSInteger)macdType;
@end
