//
//  DLConfigureManager.m
//  BTCTest
//
//  Created by FuYou on 14/11/25.
//  Copyright (c) 2014年 FuckYou. All rights reserved.
//

#import "DLConfigureManager.h"
#import "CONFIG_CONSTAN.h"
@implementation DLConfigureManager
+ (NSArray*) symbolsArray
{
    NSArray* symbolArray = @[@"btccny",@"ltccny"];
    
    return symbolArray;
}

+ (NSArray*) periodsArray
{
    NSArray* symbolArray = @[@"timeLine_type",@"1min",@"5min",@"30min",@"60min",@"1day",KLINE1WEEK];
    
    return symbolArray;
}
@end
