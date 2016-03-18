//
//  ImRSIObject.m
//  iOSKDJ
//
//  Created by huobiSystem on 15-4-29.
//  Copyright (c) 2015年 huobiSystem. All rights reserved.
//

#import "ImRSIObject.h"
#import "ImMathObject.h"
#import "ImHBLog.h"
@implementation ImRSIObject

#define N1_CONST    6
#define N2_CONST    12
#define N3_CONST    24

- (void) demoKDJ
{
    NSMutableArray* demoArray = [NSMutableArray arrayWithCapacity:100];
    for (int nIndex = 0; nIndex  < 100; nIndex++)
    {
        [demoArray addObject:@(nIndex + 1010)]; //开
        [demoArray addObject:@(nIndex + 1020)]; //高
        [demoArray addObject:@(nIndex + 1000)]; //低
        [demoArray addObject:@(nIndex + 1010)]; //收
    }//endf
}

+ (CGFloat) lastClose:(NSArray*)valuesArray kIndex:(NSUInteger)kIndex
{
    CGFloat result = MAXFLOAT;
    
    if ( kIndex > 0 )
    {
        result = [[valuesArray objectAtIndex:kIndex - 1] floatValue];
    }
    //else cont.
    
    return result;
}

+ (CGFloat) entryRSI1:(NSArray*)valuesArray fromIndex:(NSUInteger)fromIndex
{
    CGFloat result = MAXFLOAT;
    NSInteger endIndex = (fromIndex - N1_CONST) + 1;
    
    if (endIndex >= 0)
    {
        NSMutableArray* ma1Array = [NSMutableArray arrayWithCapacity:1];
        NSMutableArray* ma2Array = [NSMutableArray arrayWithCapacity:1];
        for (NSInteger kIndex = fromIndex; kIndex >= endIndex; kIndex--)
        {
            CGFloat closePrice = [[valuesArray objectAtIndex:kIndex] floatValue];
            CGFloat lastPrice = [ImRSIObject lastClose:valuesArray kIndex:kIndex];
            
            [ma1Array addObject:@(MAX(closePrice - lastPrice, 0))];
            
            [ma2Array addObject:@(fabs(closePrice - lastPrice))];
        }
        
        CGFloat ma1 = [ImMathObject MAOfArray:ma1Array withRange:NSMakeRange(0, N1_CONST)];
        
        CGFloat ma2 = [ImMathObject MAOfArray:ma2Array withRange:NSMakeRange(0, N1_CONST)];
        
        if (ma2)
        {
            result = ma1 / ma2 * 100;
        }
        else
            result = 0;//HB_LOG(@"error!");
    }
    //else cont.

    return result;
}

+ (CGFloat) entryRSI2:(NSArray*)valuesArray fromIndex:(NSUInteger)fromIndex
{
    CGFloat result = MAXFLOAT;
    NSInteger endIndex = (fromIndex - N2_CONST) + 1;
    
    if (endIndex >= 0)
    {
        NSMutableArray* ma1Array = [NSMutableArray arrayWithCapacity:1];
        NSMutableArray* ma2Array = [NSMutableArray arrayWithCapacity:1];
        for (NSInteger kIndex = fromIndex; kIndex >= endIndex; kIndex--)
        {
            CGFloat closePrice = [[valuesArray objectAtIndex:kIndex] floatValue];
            CGFloat lastPrice = [ImRSIObject lastClose:valuesArray kIndex:kIndex];
            
            [ma1Array addObject:@(MAX(closePrice - lastPrice, 0))];
            
            [ma2Array addObject:@(fabs(closePrice - lastPrice))];
        }
        
        CGFloat ma1 = [ImMathObject MAOfArray:ma1Array withRange:NSMakeRange(0, N2_CONST)];
        CGFloat ma2 = [ImMathObject MAOfArray:ma2Array withRange:NSMakeRange(0, N2_CONST)];
        if (ma2)
        {
            result = ma1 / ma2 * 100;
        }
        else
            result = 0;//HB_LOG(@"error!");
    }
    //else cont.
    
    return result;
}

+ (CGFloat) entryRSI3:(NSArray*)valuesArray fromIndex:(NSUInteger)fromIndex
{
    CGFloat result = MAXFLOAT;
    NSInteger endIndex = (fromIndex - N3_CONST) + 1;
    
    if (endIndex >= 0)
    {
        NSMutableArray* ma1Array = [NSMutableArray arrayWithCapacity:1];
        NSMutableArray* ma2Array = [NSMutableArray arrayWithCapacity:1];
        for (NSInteger kIndex = fromIndex; kIndex >= endIndex; kIndex--)
        {
            CGFloat closePrice = [[valuesArray objectAtIndex:kIndex] floatValue];
            CGFloat lastPrice = [ImRSIObject lastClose:valuesArray kIndex:kIndex];
            
            [ma1Array addObject:@(MAX(closePrice - lastPrice, 0))];
            
            [ma2Array addObject:@(fabs(closePrice - lastPrice))];
        }
        
        CGFloat ma1 = [ImMathObject MAOfArray:ma1Array withRange:NSMakeRange(0, N3_CONST)];
        CGFloat ma2 = [ImMathObject MAOfArray:ma2Array withRange:NSMakeRange(0, N3_CONST)];
        if (ma2)
        {
            result = ma1 / ma2 * 100;
        }
        else
            result = 0;
    }
    //else cont.
    
    return result;
}
@end
