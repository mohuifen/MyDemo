//
//  ImRSIObject.h
//  iOSKDJ
//
//  Created by huobiSystem on 15-4-29.
//  Copyright (c) 2015年 huobiSystem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImRSIObject : NSObject
+ (CGFloat) entryRSI1:(NSArray*)valuesArray fromIndex:(NSUInteger)fromIndex;
+ (CGFloat) entryRSI2:(NSArray*)valuesArray fromIndex:(NSUInteger)fromIndex;
+ (CGFloat) entryRSI3:(NSArray*)valuesArray fromIndex:(NSUInteger)fromIndex;
@end
