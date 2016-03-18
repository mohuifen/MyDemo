//
//  DLSubscribeObject.h
//  BTCTest
//
//  Created by FuYou on 14/11/25.
//  Copyright (c) 2014年 FuckYou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketIO.h"
#import "CONFIG_CONSTAN.h"
#import "constants.h"
#import "ImHBLog.h"
#import "DLMainManager.h"

#define REQUEST_KLINE               NSStringFromSelector(@selector(requestKLineWithSocket:keySymBolid:keyPeriod:))

@class DLSeverObject;

@interface DLSubscribeObject : NSObject
{
    
}

@property (nonatomic,strong) DLSeverObject* serverObject;

//
- (BOOL) subscribeMarketDetail:(SocketIO *)socket keySymbolID:(NSString*)keySymbolID marketDetail:(NSString*)keyDetail;

- (BOOL) unSubscribeMarketDetail:(SocketIO *)socket keySymbolID:(NSString*)keySymbolID marketDetail:(NSString*)keyDetail ;

//
- (BOOL) subscribeMarketOverview:(SocketIO *)socket keySymbolID:(NSString*)keySymbolID;

- (BOOL) unSubscribeMarketOverview:(SocketIO *)socket keySymbolID:(NSString*)keySymbolID;

//
- (BOOL) subscribeMarketDepthTopShort:(SocketIO *)socket keySymbolID:(NSString*)keySymbolID;

- (BOOL) unsubscribeMarketDepthTopShort:(SocketIO *)socket keySymbolID:(NSString*)keySymbolID;

//
- (BOOL) subscribeLastKLine:(SocketIO *)socket keySymBolid:(NSString*)keySymBolid keyPeriod:(NSString*)keyPeriod;

- (BOOL) unSubscribeLastKLine:(SocketIO *)socket keySymBolid:(NSString*)keySymBolid keyPeriod:(NSString*)keyPeriod;

//
- (void) requestKLineWithSocket:(SocketIO *)socket keySymBolid:(NSString*)keySymBolid keyPeriod:(NSString*)keyPeriod;

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
