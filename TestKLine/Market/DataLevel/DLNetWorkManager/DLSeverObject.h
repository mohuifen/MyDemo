//
//  DLSeverObject.h
//  BTCTest
//
//  Created by FuYou on 14/11/25.
//  Copyright (c) 2014年 FuckYou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLSubscribeObject.h"



#if HB_TEST_MARKET
// for test
#define SERVER_HUOBI_MARKET_IP        @"172.32.1.229:58390" //@"10.0.0.158"
#define SERVER_HUOBI_MARKET_IP_SLOW   @"172.32.1.229:48390/slow" //@"10.0.0.158"
// test end
#else

#define SERVER_HUOBI_MARKET_IP        @"hq.huobi.com" //@"10.0.0.158"
#define SERVER_HUOBI_MARKET_IP_SLOW   @"hq.huobi.com/slow" //@"10.0.0.158"

#endif

#define SERVER_BITVC_MARKET           @"hq.bitvc.com"

#define SERVER_MARKET_PORT 80

@interface DLSeverObject : NSObject
{
    
}

@property (nonatomic,copy) NSString* serverName;

@property (nonatomic,assign) BOOL bReachable;

@property (nonatomic,assign) BOOL bApplicationEnteredBack;

//@property (nonatomic,retain) SocketIO *socketIO;

- (void) suspendNetWork;

- (BOOL) connectsWithServerName:(NSString*)strServerName;

- (BOOL) connectsServer;

- (BOOL) connectsToMarketServer:(NSString*)strServerName;

- (BOOL) disconnectsMarketServer;

- (BOOL) badConnectToServer;

- (BOOL) badConnectToServerRepeate;

- (BOOL) closeBadRepeat;

- (BOOL) didReceiveMarketDetail:(NSDictionary* )argsDict;

- (void) localRequestMarketDetailWithSymbolID:(NSString*)keySymbolID;

- (void) localRequestKLineWithPeriod:(NSString*)strPeriodType widthSymbolId:(NSString*)strSymbolId;

- (void) unSubscribeLastKLine:(NSString*)strPeriodType widthSymbolId:(NSString*)strSymbolId;

- (void) cancelSubscribeTimeOut;

- (NSString*) getMarketDetailDepth;
@end
