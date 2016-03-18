//
//  ImWRObject.m
//  iOSKDJ
//
//  Created by huobiSystem on 15-4-29.
//  Copyright (c) 2015年 huobiSystem. All rights reserved.
//

#import "ImWRObject.h"
#import "ImMathObject.h"
#import "KlineConstant.h"

@implementation ImWRObject
#define N_CONST     10
#define N1_CONST    6

- (void) demoKDJ
{
    NSMutableArray* demoArray = [NSMutableArray arrayWithCapacity:100];
    for (int nIndex = 0; nIndex  < 100; nIndex++)
    {
        [demoArray addObject:@(nIndex + 1010)]; //开
        [demoArray addObject:@(nIndex + 1020)]; //高
        [demoArray addObject:@(nIndex + 1000)]; //低
        [demoArray addObject:@(nIndex + 1010)]; //收
        [demoArray addObject:@(10000)]; //量
    }//endf
}

+ (CGFloat) entryWR1:(NSDictionary*)dataDiction nIndex:(NSUInteger)nIndex
{
    CGFloat result = MAXFLOAT;
    NSArray* priceLastArray = [dataDiction objectForKey:PRICELAST];
    CGFloat closePrice = [[priceLastArray objectAtIndex:nIndex] floatValue];
    
    NSArray* lowPriceArray = [dataDiction objectForKey:PRICELOW];
    NSArray* highPriceArray = [dataDiction objectForKey:PRICEHIGH];
    
    CGFloat lowInNLowsValue = [ImMathObject getLowestOfArray:lowPriceArray fromIndex:nIndex withCount:N_CONST];   //N日内最低价的最低值
    
    CGFloat highInHighsValue = [ImMathObject getHighestOfArray:highPriceArray fromIndex:nIndex withCount:N_CONST];   //N日内最低价的最低值
    
    CGFloat valueSpan =  highInHighsValue - lowInNLowsValue;
    if (valueSpan > 0)
    {
        result = 100 * (highInHighsValue - closePrice) / valueSpan;
    }
    else
        result = 0;
    
    return result;
}

+ (CGFloat) entryWR2:(NSDictionary*)dataDiction nIndex:(NSUInteger)nIndex
{
    CGFloat result = MAXFLOAT;
    NSArray* priceLastArray = [dataDiction objectForKey:PRICELAST];
    CGFloat closePrice = [[priceLastArray objectAtIndex:nIndex] floatValue];
    
    NSArray* lowPriceArray = [dataDiction objectForKey:PRICELOW];
    NSArray* highPriceArray = [dataDiction objectForKey:PRICEHIGH];
    
    
    CGFloat lowInNLowsValue = [ImMathObject getLowestOfArray:lowPriceArray fromIndex:nIndex withCount:N1_CONST];   //N日内最低价的最低值
    
    CGFloat highInHighsValue = [ImMathObject getHighestOfArray:highPriceArray fromIndex:nIndex withCount:N1_CONST];   //N日内最低价的最低值
    
    
    CGFloat valueSpan =  highInHighsValue - lowInNLowsValue;
    if (valueSpan > 0)
    {
        result = 100 * (highInHighsValue - closePrice) / valueSpan;
    }
    else
        result = 0;
    
    return result;
}

#define M1_CONST    5
#define M2_CONST    10

- (CGFloat) mavol1:(NSMutableArray*)valuesArray fromIndex:(NSUInteger)fromIndex
{
    NSMutableArray* mavol1Array = [NSMutableArray arrayWithCapacity:M1_CONST];
    for (NSInteger vIndex = fromIndex; vIndex >= fromIndex - (M1_CONST - 1); vIndex--)
    {
        NSArray* item = [valuesArray objectAtIndex:vIndex];
        CGFloat closePrice = [[item objectAtIndex:4] floatValue];
        
        [mavol1Array addObject:@(closePrice)];
    }
    CGFloat result = [ImMathObject MAOfArray:mavol1Array withRange:NSMakeRange(0, M1_CONST)];
    
    return result;
}

- (CGFloat) mavol2:(NSMutableArray*)valuesArray fromIndex:(NSUInteger)fromIndex
{
    NSMutableArray* mavol1Array = [NSMutableArray arrayWithCapacity:M2_CONST];
    for (NSInteger vIndex = fromIndex; vIndex >= fromIndex - (M2_CONST - 1); vIndex--)
    {
        NSArray* item = [valuesArray objectAtIndex:vIndex];
        CGFloat closePrice = [[item objectAtIndex:4] floatValue];
        
        [mavol1Array addObject:@(closePrice)];
    }
    CGFloat result = [ImMathObject MAOfArray:mavol1Array withRange:NSMakeRange(0, M2_CONST)];
    
    return result;
}

@end
