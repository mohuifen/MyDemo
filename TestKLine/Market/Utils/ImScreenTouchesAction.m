//
//  ImScreenTouchesAction.m
//  huobiSystem
//
//  Created by 张仓阁 on 14-10-27.
//  Copyright (c) 2014年 张仓阁. All rights reserved.
//

#import "ImScreenTouchesAction.h"
#import "AppDelegate.h"
static ImScreenTouchesAction* _screenTouchesAction;

@interface ImScreenTouchesAction ()
{
    NSTimer *_timerScreen;
}

- (void)timerActionScreenLight:(NSTimer *)timer;
@end

@implementation ImScreenTouchesAction

+ (ImScreenTouchesAction*) getInstance {
    if (nil == _screenTouchesAction) {
        _screenTouchesAction = [[ImScreenTouchesAction alloc] init];
    }
    
    return _screenTouchesAction;
}

- (void)timerActionScreenLight:(NSTimer *)timer {
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO] ;
}

- (void)setScreenLight {
    [_timerScreen invalidate];
    _timerScreen = nil;
    
    _timerScreen = [NSTimer scheduledTimerWithTimeInterval: 5 * 60
                                                    target: self
                                                  selector: @selector(timerActionScreenLight:)
                                                  userInfo: nil
                                                   repeats: YES];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES] ;
}

- (void)setScreenCanDarken {
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO] ;
}
@end
