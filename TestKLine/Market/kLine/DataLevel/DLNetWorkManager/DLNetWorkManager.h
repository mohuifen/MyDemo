//
//  DLNetWorkManager.h
//  BtcDemo
//
//  Created by FuYou on 14/11/21.
//  Copyright (c) 2014年 FuckYou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLNetWorkManager : NSObject
{
}

@property(nonatomic,assign) BOOL bEnterBack;

- (void) timerInvalidate;

- (void) timerFire;

- (void) suspendNetWork;

- (void) restartNetWork;

- (BOOL) initReachability:(BOOL)bRestarted;

- (NSString*) getHuobiMarketServerID;

- (void) localRequestKLineWithPeriod:(NSString*)strPeriodType widthSymbolId:(NSString*)strSymbolId;

- (void) localRequestMarketDetailWithSymbolID:(NSString*)keySymbolID;

- (BOOL) isNetWorkConnect;

- (void) showNetWorkAlert;

- (void) spotRequestMarketDetailWithSymbolID:(NSString*)keySymbolID;

- (void) futureGoodsMarketDetailWithSymbolID:(NSString*)keySymbolID;

- (void) unSubscribeLastKLine:(NSString*)strPeriodType widthSymbolId:(NSString*)strSymbolId;
@end
