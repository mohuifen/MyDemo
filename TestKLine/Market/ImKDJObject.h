//
//  ImKDJObject.h
//  iOSKDJ
//
//  Created by huobiSystem on 15-4-29.
//  Copyright (c) 2015年 huobiSystem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImKDJObject : NSObject

+ (CGFloat) entryK:(NSDictionary*)dataDiction kIndex:(NSUInteger)kIndex;

+ (CGFloat) entryD:(NSDictionary*)dataDiction dIndex:(NSUInteger)dIndex;

+ (CGFloat) entryJ:(NSDictionary*)dataDiction JIndex:(NSUInteger)JIndex;

@end
