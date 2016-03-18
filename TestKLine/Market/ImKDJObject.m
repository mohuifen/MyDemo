//
//  ImKDJObject.m
//  iOSKDJ
//
//  Created by huobiSystem on 15-4-29.
//  Copyright (c) 2015年 huobiSystem. All rights reserved.
//

#import "ImKDJObject.h"
#import "ImMathObject.h"
#import "KlineConstant.h"

@implementation ImKDJObject

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

#define N_CONST 9

+ (CGFloat) RSV:(NSDictionary*)dataDiction nIndex:(NSUInteger)nIndex
{
    CGFloat RSV = MAXFLOAT;
    //NSArray* item = [valuesArray objectAtIndex:nIndex];
    //CGFloat closePrice = [[item objectAtIndex:3] floatValue];
    
//    NSArray* amountArray = [dataDiction objectForKey:AMOUNT];
//    NSArray* pricehighArray = [dataDiction objectForKey:PRICEHIGH];
//    NSArray* pricelowArray = [dataDiction objectForKey:PRICELOW];
//    NSArray* pricelastArray = [dataDiction objectForKey:PRICELAST];
//    NSArray* priceOpenArray = [dataDiction objectForKey:PRICEOPEN];
//    NSArray* timeArray = [dataDiction objectForKey:TIME];
    
    
    NSArray* priceLastArray = [dataDiction objectForKey:PRICELAST];
    CGFloat closePrice = [[priceLastArray objectAtIndex:nIndex] floatValue];
    
    NSArray* lowPriceArray = [dataDiction objectForKey:PRICELOW];
    NSArray* highPriceArray = [dataDiction objectForKey:PRICEHIGH];
    CGFloat lowInNLowsValue = [ImMathObject getLowestOfArray:lowPriceArray fromIndex:nIndex withCount:N_CONST];   //N日内最低价的最低值
    
    CGFloat highInHighsValue = [ImMathObject getHighestOfArray:highPriceArray fromIndex:nIndex withCount:N_CONST];   //N日内最低价的最低值
    
    CGFloat valueSpan = highInHighsValue - lowInNLowsValue;
    if (lowInNLowsValue != MAXFLOAT && highInHighsValue != -1)
    {
        if (valueSpan > 0)
            RSV = (closePrice - lowInNLowsValue) / valueSpan * 100;
        else
            RSV = 0;
    }
    //else cont.
    
    return RSV;
}

#define M1_CONST 3

+ (CGFloat) entryK:(NSDictionary*)dataDiction kIndex:(NSUInteger)kIndex
{
    CGFloat result = MAXFLOAT;
    NSMutableArray* rsvArray = [NSMutableArray arrayWithCapacity:M1_CONST];
    for (NSUInteger rsvIndex = kIndex + 1; rsvIndex > kIndex - (M1_CONST - 1); rsvIndex--)
    {
        CGFloat rsvValue = [ImKDJObject RSV:dataDiction nIndex:rsvIndex - 1];
        if(MAXFLOAT != rsvValue)
        {
            [rsvArray addObject:@(rsvValue)];
        }
        else
        {
            return result;
        }
    }//endf
    
    result = [ImMathObject MAOfArray:rsvArray withRange:NSMakeRange(0, M1_CONST)];
    
    return result;
}

#define M2_CONST 3
+ (CGFloat) entryD:(NSDictionary*)dataDiction dIndex:(NSUInteger)dIndex
{
    CGFloat result = MAXFLOAT;
    if (dIndex >= (M2_CONST - 1))
    {
        NSMutableArray* kArray = [NSMutableArray arrayWithCapacity:M2_CONST];
        for (NSUInteger kIndex = dIndex + 1; kIndex > dIndex - (M2_CONST - 1); kIndex--)
        {
            CGFloat kValue = [ImKDJObject entryK:dataDiction kIndex:kIndex - 1];
            if(MAXFLOAT != kValue)
                [kArray addObject:@(kValue)];
            else
                return result;
        }//endf
        result = [ImMathObject MAOfArray:kArray withRange:NSMakeRange(0, M2_CONST)];
        //result = [ImMathObject MAOfArray:kArray withCount:M2_CONST];
    }
    //else cont.
    
    return result;
}

+ (CGFloat) entryJ:(NSDictionary*)dataDiction JIndex:(NSUInteger)JIndex
{
    CGFloat result = MAXFLOAT;
    CGFloat kValue = [ImKDJObject entryK:dataDiction kIndex:JIndex];
    CGFloat dValue = [ImKDJObject entryD:dataDiction dIndex:JIndex];
    if (MAXFLOAT != kValue && MAXFLOAT != dValue)
        result = kValue * 3 + dValue * 2;
    //else cont.

    return result;
}

@end
