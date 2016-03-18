//
//  ImMathObject.m
//  iOSKDJ
//
//  Created by huobiSystem on 15-4-29.
//  Copyright (c) 2015年 huobiSystem. All rights reserved.
//

#import "ImMathObject.h"

@implementation ImMathObject
+ (ImMathObject *)sharedManager {
    static ImMathObject *sharedAccountManagerInstance = nil;
    
    static dispatch_once_t predicate; dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    
    return sharedAccountManagerInstance;
    
}

+ (CGFloat) MAOfArray:(NSArray*)data withRange:(NSRange)range
{
    CGFloat value = 0;
    if (data.count - range.location >= range.length) {
        NSArray *newArray = [data objectsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:range]];
        for (NSString *item in newArray) {
            value += [item doubleValue];
        }
        if (value>0) {
            value = value / newArray.count;
        }
    }
    //else
    //    HB_LOG(@"error!");
    
    return value;
}

+ (CGFloat) getLowestOfArray:(NSArray*)valuesArray fromIndex:(NSUInteger)fromIndex withCount:(NSUInteger) nCount
{
    CGFloat result = MAXFLOAT;
    NSUInteger endIndex = fromIndex - (nCount - 1);
    if (fromIndex >= endIndex)
    {
        for (NSUInteger itemIndex = fromIndex + 1; itemIndex > endIndex; itemIndex--)
        {
            CGFloat lowPrice = [[valuesArray objectAtIndex:itemIndex - 1] floatValue];
            result = result <= lowPrice ? result : lowPrice;
        }//endf
    }
    //else cont.
    
    return result;
}

+ (CGFloat) getHighestOfArray:(NSArray*)valuesArray fromIndex:(CGFloat)fromIndex withCount:(NSUInteger) nCount
{
    CGFloat result = -1;
    NSUInteger endIndex = fromIndex - (nCount - 1);
    if (fromIndex >= endIndex)
    {
        for (NSUInteger itemIndex = fromIndex + 1; itemIndex > endIndex; itemIndex--)
        {
            CGFloat highPrice = [[valuesArray objectAtIndex:itemIndex - 1] floatValue];
            result = result >= highPrice ? result : highPrice;
        }//endf
    }
    //else cont.
    
    return result;
}
@end
