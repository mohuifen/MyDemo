//
//  DLSubscribeObject.h
//  BTCTest
//
//  Created by FuYou on 14/11/25.
//  Copyright (c) 2014年 FuckYou. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "SocketIO.h"
//#import "CONFIG_CONSTAN.h"
#import "KlineConstant.h"
#import "ImHBLog.h"
#import "DLMainManager.h"

#define REQUEST_KLINE               NSStringFromSelector(@selector(requestKLineWithSocket:keySymBolid:keyPeriod:))

@class DLSeverObject;

@interface DLSubscribeObject : NSObject
{
    
}

@property (nonatomic,strong) DLSeverObject* serverObject;

//
- (BOOL) subscribeMarketDetailKeySymbolID:(NSString*)keySymbolID marketDetail:(NSString*)keyDetail;

- (BOOL) unSubscribeMarketDetailKeySymbolID:(NSString*)keySymbolID marketDetail:(NSString*)keyDetail ;

//
- (BOOL) subscribeMarketOverviewKeySymbolID:(NSString*)keySymbolID;

- (BOOL) unSubscribeMarketOverviewKeySymbolID:(NSString*)keySymbolID;

//
- (BOOL) subscribeMarketDepthTopShortKeySymbolID:(NSString*)keySymbolID;

- (BOOL) unsubscribeMarketDepthTopShortKeySymbolID:(NSString*)keySymbolID;

//
- (BOOL) subscribeLastKLineKeySymBolid:(NSString*)keySymBolid keyPeriod:(NSString*)keyPeriod;

- (BOOL) unSubscribeLastKLineKeySymBolid:(NSString*)keySymBolid keyPeriod:(NSString*)keyPeriod;

//
- (void) requestKLineWithKeySymBolid:(NSString*)keySymBolid keyPeriod:(NSString*)keyPeriod;

//

- (void) didReceiveReqMsgSub:(NSDictionary* )argsDict;

- (void) didReceiveReqMsgUnSub:(NSDictionary* )argsDict;

//

- (BOOL) setSubscribeTimeOut:(NSDictionary*)jsData;

- (BOOL) subscribeTimeOutWithObject:(NSDictionary*)diction;

- (BOOL) marketSubscribeTimeOut:(NSString*)requestIndex reuqestPeriod:(NSString*)reuqestPeriod;

//
- (NSString*) getPeriodWithRequestIndex:(NSInteger)requestIndex;

@end
