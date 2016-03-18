//
//  DLSubscribeObject.m
//  BTCTest
//
//  Created by FuYou on 14/11/25.
//  Copyright (c) 2014年 FuckYou. All rights reserved.
//

#import "DLSubscribeObject.h"
#import "DLSeverObject.h"
@implementation DLSubscribeObject

- (void) didReceiveReqMsgSub:(NSDictionary* )argsDict
{
    NSDictionary* dictionary = @{@"requestIndex":[argsDict objectForKey:@"requestIndex"],
                                 @"period":@""};
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(subscribeTimeOutWithObject:) object:dictionary];
}

- (void) didReceiveReqMsgUnSub:(NSDictionary* )argsDict
{
    NSDictionary* dictionary = @{@"requestIndex":[argsDict objectForKey:@"requestIndex"],
                                 @"period":@""};
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(unSubscribeTimeOut:) object:dictionary];
}
//MARK: 请求300条数据


- (void) requestKLineWithKeySymBolid:(NSString*)keySymBolid keyPeriod:(NSString*)keyPeriod
{
    /************************************************************************
     思路概述：
     1、先请求last kline 把last通道打通,再请求kLine:如果顺序颠倒会出现注册lastKLine不及时的情况;
     2、数据库在收到 kLine数据的时候把数据全部清空。防止数据错误。
     ************************************************************************/
    
    /****************************************************
     注册定时推送last kline消息
     ****************************************************/
/*
    [self subscribeLastKLine:socket keySymBolid:keySymBolid keyPeriod:keyPeriod];
    
    NSDictionary* jsonDict = @{
                             @"version":@1,
                             @"msgType":@"reqKLine",
                             SYMBOLID:keySymBolid,
                             PERIOD:keyPeriod,
                             @"from":@0,
                             @"to":@-1
                             };
 */
    /****************************************************
     请求300条k线数据
     ****************************************************/
/*
    [socket sendEvent:@"request" withData:jsonDict];
*/
    
    /**********************************返回值**********************************
     idx = 1404103038520;
     msg = reqKLine;
     pld =     {
     amt = ("1.0358","18.299");         //成交量
     c = (8,10);                        //交易次数
     pd = 1min;                         //k线周期
     ph = ("3816.74","3815.8");         //最高价
     pl = ("3815.02","3815.02");        //最低价
     plt = ("3815.02","3815.7");        //收盘价
     po = ("3815.02","3815.8");         //开盘价
     smb = btccny;                      //交易代码
     t = (1405333680,1405333740);
     v = ("3951.74","69825.14999999999"); // 成交额
     };
     rc = 200;
     rm = "";
     ver = 1;
     ************************************************************************/

}

#pragma mark - subscribe
- (BOOL) subscribekeySymbolID:(NSString*)keySymbolID marketDetail:(NSString*)keyDetail
{
    BOOL bResult = NO;
    NSString* strRequestIndex = [keySymbolID isEqualToString:@"btccny"] ? REQUEST_INDEX_MARKET_OVERVIEW_BTC : REQUEST_INDEX_MARKET_OVERVIEW_LTC;
    if ([keySymbolID isEqualToString:@"btccny"])
    {
        strRequestIndex = REQUEST_INDEX_MARKET_OVERVIEW_BTC;
    }
    else if ([keySymbolID isEqualToString:@"ltccny"])
    {
        strRequestIndex = REQUEST_INDEX_MARKET_OVERVIEW_LTC;
    }
    else if ([keySymbolID isEqualToString:@"btcusd"])
    {
        strRequestIndex = REQUEST_INDEX_MARKET_OVERVIEW_LTC;
    }
    else
    {
        strRequestIndex = @"30000";
    }

    NSDictionary* jsonData= @{
                              @"version":@1,
                              @"msgType":@"reqMsgSubscribe",
                              @"requestIndex":strRequestIndex,
                              @"symbolList":@{keyDetail: @[@{@"symbolId":keySymbolID,@"pushType":@"pushLong"}]}
                              };
    
    
//    [socket sendEvent:@"request" withData:jsonData];
    [self setSubscribeTimeOut:jsonData];
    
    return bResult;
}

- (BOOL) unSubscribeMarketDetailKeySymbolID:(NSString*)keySymbolID marketDetail:(NSString*)keyDetail
{
    BOOL bResult = NO;
    NSString* strRequestIndex = [keySymbolID isEqualToString:@"btccny"] ? UNREQUEST_INDEX_MARKET_DETAIL_BTC : UNREQUEST_INDEX_MARKET_DETAIL_LTC;
    NSDictionary* dictionUnSub= @{
                                  @"version":@1,
                                  @"msgType":@"reqMsgUnsubscribe",
                                  @"requestIndex":strRequestIndex,
                                  @"symbolList":@{keyDetail: @[@{@"symbolId":keySymbolID,@"pushType":@"pushLong"}]}
                                  };
//    [socket sendEvent:@"request" withData:dictionUnSub];
    return bResult;
}

- (BOOL) subscribeMarketOverviewKeySymbolID:(NSString*)keySymbolID
{
    BOOL bResult = NO;
    /*********************************************************************************
     请求的返回结果的数据结构如下：
     {
     "name":"message",
     "args":
     [
     {
     "ver":1,
     "msg":"marketOverview",
     "smb":"btccny",
     "pld":
     {
     "smb":"btccny",
     "pn":"3825.14",
     "po":3816.01,
     "ph":3850.11,
     "pl":3791.29,
     "pa":3825.9,
     "pb":"3825.14",
     "tv":122190333.25,
     "tamt":31714.4868
     }}
     ]
     }
     ************************************************************************************/
    BOOL bKeySymbolID = keySymbolID && ![keySymbolID isEqualToString:@""];
    if ( bKeySymbolID)
    {
        NSString* strRequestIndex = [keySymbolID isEqualToString:@"btccny"] ? REQUEST_INDEX_MARKET_OVERVIEW_BTC : REQUEST_INDEX_MARKET_OVERVIEW_LTC;
        NSDictionary* jsonData= @{
                                  @"version":@1,
                                  @"msgType":@"reqMsgSubscribe",
                                  @"requestIndex":strRequestIndex,
                                  @"symbolList":@{MARKETOVERVIEW: @[@{@"symbolId":keySymbolID,@"pushType":@"pushLong"}]}
                                  };
        
        
//        [socket sendEvent:@"request" withData:jsonData];
        bResult = [self setSubscribeTimeOut:jsonData];
        //[_requestTaskDictionary setObject:keySymbolID forKey:@"MarketOverview"];
    }
    else
        HB_LOG(@"error!");
    
    return bResult;
}

- (BOOL) unSubscribeMarketOverviewKeySymbolID:(NSString*)keySymbolID
{
    BOOL bResult = NO;
    NSString* strRequestIndex = [keySymbolID isEqualToString:@"btccny"] ? UNREQUEST_INDEX_MARKET_OVERVIEW_BTC : UNREQUEST_INDEX_MARKET_OVERVIEW_LTC;
    NSDictionary* dictionUnSub= @{
                                  @"version":@1,
                                  @"msgType":@"reqMsgUnsubscribe",
                                  @"requestIndex":strRequestIndex,
                                  @"symbolList":@{MARKETOVERVIEW: @[@{@"symbolId":keySymbolID,@"pushType":@"pushLong"}]}
                                  };
//    [socket sendEvent:@"request" withData:dictionUnSub];
    return bResult;
}

- (BOOL) subscribeMarketDepthTopShortKeySymbolID:(NSString*)keySymbolID
{
    BOOL bResult = NO;
    BOOL bKeySymbol = keySymbolID && ![keySymbolID isEqualToString:@""];
    if (bKeySymbol)
    {
        NSString* strRequestIndex = [keySymbolID isEqualToString:@"btccny"] ? REQUEST_INDEX_REQ_MARKETDEPTHTOPSHORT_BTC : REQUEST_INDEX_REQ_MARKETDEPTHTOPSHORT_LTC;
        NSDictionary* jsonDict= @{
                                  @"version":@1,
                                  @"msgType":@"reqMsgSubscribe",
                                  @"requestIndex":strRequestIndex,
                                  @"symbolList":@{@"marketDepthTopShort":@[@{@"symbolId":keySymbolID,@"pushType":@"pushLong"}]}
                                  };
        
//        [socket sendEvent:@"request" withData:jsonDict];
        bResult = [self setSubscribeTimeOut:jsonDict];
        //[_requestTaskDictionary setObject:keySymbolID forKey:@"MarketDepthTopShort"];
    }
    else
        HB_LOG(@"error!");

    return bResult;
}
/*
- (BOOL) unsubscribeMarketDepthTopShort:(SocketIO *)socket keySymbolID:(NSString*)keySymbolID
{
    BOOL bResult = NO;
    NSString* strRequestIndex = [keySymbolID isEqualToString:@"btccny"] ? UNREQUEST_INDEX_REQ_MARKETDEPTHTOPSHORT_BTC : UNREQUEST_INDEX_REQ_MARKETDEPTHTOPSHORT_LTC;
    NSDictionary* dictionUnSub= @{
                                  @"version":@1,
                                  @"msgType":@"reqMsgUnsubscribe",
                                  @"requestIndex":strRequestIndex,
                                  @"symbolList":@{@"marketDepthTopShort":@[@{@"symbolId":keySymbolID,@"pushType":@"pushLong"}]}
                                  };
    [socket sendEvent:@"request" withData:dictionUnSub];
    return bResult;
}
*/
- (BOOL) subscribeLastKLineKeySymBolid:(NSString*)keySymBolid keyPeriod:(NSString*)keyPeriod
{
    BOOL bResult = NO;
    /*
     返回结果的数据结构
     {"name":"message","args":[{
     "ver":1,
     "msg":"lastKLine",
     "smb":"btccny",
     "pld":
     {
     "_id":1405328280,
     "smb":"btccny",
     "t":1405328280,
     "pd":"1min",
     "po":3817.22,
     "ph":3817.22,
     "pl":3816.92,
     "plt":3816.92,
     "amt":7.6171,
     "v":29074.61,
     "c":15
     }
     }]}
     */
    
    BOOL bKeySymbol = keySymBolid && ![keySymBolid isEqualToString:@""];
    BOOL bKeyPeriod = keyPeriod && ![keyPeriod isEqualToString:@""];
    if (bKeySymbol && bKeyPeriod)
    {
        NSUInteger nIndex = [self requestIndexOfSymbolId:keySymBolid keyPeriod:keyPeriod];
        NSString* strRequestIndex = [NSString stringWithFormat:@"%lu",(unsigned long)nIndex];

        NSDictionary* jsonDict= @{
                                  @"version":@1,
                                  @"msgType":@"reqMsgSubscribe",
                                  @"requestIndex":strRequestIndex,
                                  @"symbolList":@{LASTKLINE:@[@{@"symbolId":keySymBolid,@"pushType":@"pushShort",@"period":keyPeriod}]}
                                  };
        
//        [socket sendEvent:@"request" withData:jsonDict];
        bResult = [self setSubscribeTimeOut:jsonDict];
    }
    else
        HB_LOG(@"error!");
    
    return bResult;
}

//MARK: 取消 SocketIO 连接
/*
- (BOOL) unSubscribeLastKLine:(SocketIO *)socket keySymBolid:(NSString*)keySymBolid keyPeriod:(NSString*)keyPeriod
{
    BOOL bResult = NO;
    */
/*
     返回结果的数据结构
     {"name":"message","args":[{
     "ver":1,
     "msg":"lastKLine",
     "smb":"btccny",
     "pld":
     {
     "_id":1405328280,
     "smb":"btccny",
     "t":1405328280,
     "pd":"1min",
     "po":3817.22,
     "ph":3817.22,
     "pl":3816.92,
     "plt":3816.92,
     "amt":7.6171,
     "v":29074.61,
     "c":15
     }
     }]}
*/
     /*
    if (keySymBolid && keyPeriod)
    {
        NSString* strRequestIndex = [keySymBolid isEqualToString:@"btccny"] ? UNREQUEST_INDEX_LAST_KLINE_BTC : UNREQUEST_INDEX_LAST_KLINE_LTC;
        NSDictionary* diction= @{
                                 @"version":@1,
                                 @"msgType":@"reqMsgUnsubscribe",
                                 @"requestIndex":strRequestIndex,
                                 @"symbolList":@{LASTKLINE:@[@{@"symbolId":keySymBolid,@"pushType":@"pushShort",@"period":keyPeriod}]}
                                 };
        
        [socket sendEvent:@"request" withData:diction];
    }
    //else cont.
    
    return bResult;
}
*/
#pragma mark - sub time out
- (BOOL) setSubscribeTimeOut:(NSDictionary*)jsData
{
    /**
     1、记录当前的sub状态
     */
    //NSString* strPeriod = [[DLMainManager sharedMainManager] loadPeriodType];
    BOOL bResult = NO;
    if (jsData)
    {
        NSString* reqIndex = [jsData objectForKey:@"requestIndex"];
        if (reqIndex)
        {
            NSString* strPeriod = [jsData objectForKey:@"period"];
            if (!strPeriod)
            {
                NSDictionary* symbolList = [jsData objectForKey:@"symbolList"];
                if (symbolList)
                {
                    NSArray* lastKLine  = [symbolList objectForKey:@"lastKLine"];
                    if (lastKLine)
                    {
                        NSDictionary* firstObject = [lastKLine firstObject];
                        if (firstObject)
                            strPeriod = [firstObject objectForKey:@"period"];
                        //else cont.
                    }
                    //else cont.
                }
                //else cont.
            }
            //else cont.
            
            if (!strPeriod)
                strPeriod = @"not kline";
            //else cont.
            
            NSDictionary* dictionary = @{@"requestIndex":reqIndex,
                                         @"period":strPeriod};

            [self performSelector:@selector(subscribeTimeOutWithObject:) withObject:dictionary afterDelay:30.0f];
            
            bResult = YES;
        }
        else
            HB_LOG(@"error!");
    }
    else
        HB_LOG(@"");
    
    
    return bResult;
}

- (BOOL) subscribeTimeOutWithObject:(NSDictionary*)diction
{
    BOOL bReSend = NO;
    if (diction)
    {
        NSString* reuqestPeriod = [diction objectForKey:@"period"];
        NSString* requestIndex = [diction objectForKey:@"requestIndex"];
        bReSend = [self marketSubscribeTimeOut:requestIndex reuqestPeriod:reuqestPeriod];
    }
    else
        HB_LOG(@"error!");
    
    return bReSend;
}


- (NSString*) getPeriodWithRequestIndex:(NSInteger)requestIndex
{
    NSString* strPeriod = nil;
    switch (requestIndex) {
        case 1030385211:
        case 2030385211:
        {
            strPeriod = KLINE1MIN;
            break;
        }
        case 1030385212:
        case 2030385212:
        {
            strPeriod = KLINE5MIN;
            break;
        }
        case 1030385213:
        case 2030385213:
        {
            strPeriod = KLINE15MIN;
            break;
        }
        case 1030385214:
        case 2030385214:
        {
            strPeriod = KLINE30MIN;
            break;
        }
        case 1030385215:
        case 2030385215:
        {
            strPeriod = KLINE60MIN;
            break;
        }
        case 1030385216:
        case 2030385216:
        {
            strPeriod = KLINE1DAY;
            break;
        }
        case 1030385217:
        case 2030385217:
        {
            strPeriod = KLINE1WEEK;
            break;
        }
        case 1030385218:
        case 2030385218:
        {
            strPeriod = KLINE1MON;
            break;
        }
        case 1030385219:
        case 2030385219:
        {
            strPeriod = KLINE1YEAR;
            break;
        }
        default:
            HB_LOG(@"error!");
            break;
    }
    
    return strPeriod;
}

- (BOOL) marketSubscribeTimeOut:(NSString*)requestIndex reuqestPeriod:(NSString*)reuqestPeriod
{
    BOOL bReSend = NO;
    NSString* curSymbolID = [[DLMainManager sharedMainManager] loadSymbolType];
    
    switch ([requestIndex integerValue])
    {
        case 103038520: //MARKET_OVERVIEW btc   这个值应该是marketDetail的标识，但是写了MARKET_OVERVIEW
        {
            // 因为还有btc的美元，应该不能这么判断
//            if ([curSymbolID isEqualToString:@"btccny"])
//            {
//                // 据说不用再订阅marketOverview,
//                //bReSend = [self subscribeMarketOverview:self.serverObject.socketIO keySymbolID:curSymbolID];
//            }
//            else
//                HB_LOG(@"error!");
            /*
            NSString* keyDepth = [self.serverObject getMarketDetailDepth];
            bReSend = [self subscribeMarketDetail:self.serverObject.socketIO keySymbolID:curSymbolID marketDetail:keyDepth];
            break;
             */
        }
        case 103038525: //MARKETDEPTHTOPSHORT btc
        {
            /*
            if ([curSymbolID isEqualToString:@"btccny"])
            {
                bReSend = [self subscribeMarketDepthTopShort:self.serverObject.socketIO keySymbolID:curSymbolID];
            }
             
            else
                HB_LOG(@"error!");
             */
            break;
        }
        case 1030385211: //LAST_KLINE btc
        case 1030385212: //LAST_KLINE btc
        case 1030385213: //LAST_KLINE btc
        case 1030385214: //LAST_KLINE btc
        case 1030385215: //LAST_KLINE btc
        case 1030385216: //LAST_KLINE btc
        case 1030385217: //LAST_KLINE btc
        case 1030385218: //LAST_KLINE btc
        case 1030385219: //LAST_KLINE btc
        {
            NSString* curPeriod = [self getPeriodWithRequestIndex:[requestIndex integerValue]];
            if ([curSymbolID isEqualToString:@"btccny"])
            {
                /*
                if ( [curPeriod isEqualToString:reuqestPeriod] )
                {
                    bReSend = [self subscribeLastKLine:self.serverObject.socketIO
                                 keySymBolid:curSymbolID
                                   keyPeriod:reuqestPeriod];
                }
                 
                else
                    HB_LOG(@"error!");
                 */
            }
            //else cont.
            break;
        }
        case 203038520: //MARKET_OVERVIEW ltc
        {
            /*
            NSString* keyDepth = [self.serverObject getMarketDetailDepth];
            bReSend = [self subscribeMarketDetail:self.serverObject.socketIO keySymbolID:curSymbolID marketDetail:keyDepth];
            //bReSend = [self subscribeMarketOverview:self.serverObject.socketIO keySymbolID:curSymbolID];
             */
            break;
        }
        case 203038525: //MARKETDEPTHTOPSHORT ltc
        {
            /*
            if ([curSymbolID isEqualToString:@"ltccny"])
            {
                bReSend = [self subscribeMarketDepthTopShort:self.serverObject.socketIO keySymbolID:curSymbolID];
            }
            else
                HB_LOG(@"error!");
            break;
             */
        }
        case 2030385211: //LAST_KLINE ltc
        case 2030385212: //LAST_KLINE ltc
        case 2030385213: //LAST_KLINE ltc
        case 2030385214: //LAST_KLINE ltc
        case 2030385215: //LAST_KLINE ltc
        case 2030385216: //LAST_KLINE ltc
        case 2030385217: //LAST_KLINE ltc
        case 2030385218: //LAST_KLINE ltc
        case 2030385219: //LAST_KLINE ltc
        {
            if ([curSymbolID isEqualToString:@"ltccny"])
            {
                /*
                NSString* curPeriod = [self getPeriodWithRequestIndex:[requestIndex integerValue]];
                if ( [curPeriod isEqualToString:reuqestPeriod] )
                {
                    bReSend = [self subscribeLastKLine:self.serverObject.socketIO
                                 keySymBolid:curSymbolID
                                   keyPeriod:reuqestPeriod];
                }
                else
                    HB_LOG(@"error!");
                 */
            }
            else
                HB_LOG(@"error!");
            break;
        }
        case 30000: //期货
        {
            NSLog(@"未知的参数：30000");
            break;
        }
        default:
            HB_LOG(@"error!");
            break;
    }//ends
    
    return bReSend;
}

#pragma mark - unsub time out

- (NSUInteger) requestIndexOfSymbolId:(NSString*)keySymbolId keyPeriod:(NSString*)keyPeriod
{
    NSUInteger nResult = 0;
    
    NSUInteger beginIndex = 0;
    if ( [keySymbolId isEqualToString:@"btccny"] )
    {
        beginIndex = 1030385210;
    }
    else if ( [keySymbolId isEqualToString:@"ltccny"] )
    {
        beginIndex = 2030385210;
    }
    else
        beginIndex = 30000;
    
    if (30000 != beginIndex)
    {
        NSUInteger preiodIndex = [[DLMainManager periodsArray] indexOfObject:keyPeriod];
        if (NSNotFound != preiodIndex)
        {
            nResult = beginIndex + preiodIndex;
        }
        else
            HB_LOG(@"error!");
    }
    else
        nResult = 30000;

    return nResult;
}

- (void) setUnSubscribeTimeOut:(NSDictionary*)jsData
{
    /**
     1、记录当前的sub状态
     */
    NSDictionary* dictionary = @{@"requestIndex":[jsData objectForKey:@"requestIndex"],
                                 @"period":@""};
    [self performSelector:@selector(unSubscribeTimeOut:) withObject:dictionary afterDelay:30.0f];
}


- (void) unSubscribeTimeOut:(NSDictionary*)diction
{
    BOOL bReSend = NO;
    NSString* reuqestPeriod = @"";
    NSString* requestIndex = [diction objectForKey:@"requestIndex"];
    bReSend = [self marketUnSubscribeTimeOut:requestIndex reuqestPeriod:reuqestPeriod];
}

- (BOOL) marketUnSubscribeTimeOut:(NSString*)requestIndex reuqestPeriod:(NSString*)reuqestPeriod
{
    BOOL bReSend = NO;
    
    NSString* curSymbolID = @"";
    switch ([requestIndex integerValue])
    {
        case 103038620: //UN MARKET_OVERVIEW btc
        case 103038625: //UN MARKETDEPTHTOPSHORT btc
        {
            if (![curSymbolID isEqualToString:@"btccny"])
            {
                bReSend = YES;
            }
            else
                HB_LOG(@"error!");
            break;
        }
        case 103038621: //UN LAST_KLINE btc
        {
            //我觉得这个事情不应该发生
            HB_LOG(@"error!");
            break;
        }
        case 203038620: //UN MARKET_OVERVIEW ltc
        case 203038625: //UN MARKETDEPTHTOPSHORT ltc
        {
            if (![curSymbolID isEqualToString:@"ltccny"])
            {
                bReSend = YES;
            }
            else
                HB_LOG(@"error!");
            break;
        }
        case 203038621: //UN LAST_KLINE ltc
        {
            //我觉得这个事情不应该发生
            HB_LOG(@"error!");
        }
        default:
            HB_LOG(@"error!");
            break;
    }//ends
    
    return bReSend;
}
@end
