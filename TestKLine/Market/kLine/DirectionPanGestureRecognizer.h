//
//  DirectionPanGestureRecognizer.h
//  iOSMainDemo
//
//  Created by FuckYou on 14-10-16.
//  Copyright (c) 2014年 FuckYou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import <UIKit/UIKit.h>
typedef enum {
    DirectionPangestureRecognizerVertical,
    DirectionPanGestureRecognizerHorizontal
} DirectionPangestureRecognizerDirection;

@interface DirectionPanGestureRecognizer : UIPanGestureRecognizer
{
    BOOL _drag;
    int _moveX;
    int _moveY;
    DirectionPangestureRecognizerDirection _direction;
}
@property (nonatomic, assign) DirectionPangestureRecognizerDirection direction;
@end
