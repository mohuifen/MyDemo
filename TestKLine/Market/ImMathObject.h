//
//  ImMathObject.h
//  iOSKDJ
//
//  Created by huobiSystem on 15-4-29.
//  Copyright (c) 2015年 huobiSystem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImMathObject : NSObject
+ (CGFloat) MAOfArray:(NSArray*)data withRange:(NSRange)range;
+ (CGFloat) getLowestOfArray:(NSArray*)valuesArray fromIndex:(NSUInteger)fromIndex withCount:(NSUInteger) nCount;
+ (CGFloat) getHighestOfArray:(NSArray*)valuesArray fromIndex:(CGFloat)fromIndex withCount:(NSUInteger) nCount;
@end
