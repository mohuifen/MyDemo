//
//  DLSeverObject.m
//  BTCTest
//
//  Created by FuYou on 14/11/25.
//  Copyright (c) 2014年 FuckYou. All rights reserved.
//

#import "DLSeverObject.h"
//#import "SocketIOPacket.h"
#import "DLConfigureManager.h"
#import "DLDataBaseManager.h"
#import "TradeCodeData.h"

#define REQUEST_MARKETDEPTHTOPSHORT NSStringFromSelector(@selector(requestMarketDepthTopShort:withJSONData:))

@interface DLSeverObject ()//<SocketIODelegate>
{
//    SocketIO *_socketIO;

    DLSubscribeObject* _subscribe;
    
    /********************************************
     当服务器失败的次数。
     ********************************************/
    int _nBadRepeatCount;
    
    NSMutableArray* _requestKLineArray;
    
    NSMutableDictionary* _requestTaskDictionary;
}
/********************************************
 当服务器超过三次连接失败时，需要启动timer无限重连
 服务器。
 ********************************************/
@property (weak) NSTimer* timerBadRepeat;


@end

@implementation DLSeverObject
/*
- (id) init
{
    self = [super init];
    if (self)
    {
        _subscribe = [[DLSubscribeObject alloc] init];
        _subscribe.serverObject = self;
        _requestTaskDictionary = [[NSMutableDictionary alloc] initWithCapacity:12];
        _requestKLineArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) initNotification
{

}


- (NSString*) getMarketDetailDepth
{
    NSString* result = 0;
//    NSInteger marketDetail = [[DLMainManager sharedMainManager] loadMarketDetail];
//    result = [NSString stringWithFormat:@"%@%ld",MARKETDETAIL,(long)marketDetail];
    // 只用marketDetail,后面不再加0、1、2...
    result = MARKETDETAIL;
    return result;
}

- (void) suspendNetWork
{
    if (_bReachable)
    {
        {
            NSString* keyDepth = [_requestTaskDictionary objectForKey:@"MarketDetail_Depth"];
            NSString* strSymbolId = [_requestTaskDictionary objectForKey:@"MarketDetail"];
            [_subscribe unSubscribeMarketDetail:_socketIO keySymbolID:strSymbolId marketDetail:keyDepth];
        }
        {
            
            NSDictionary* klineDict = [_requestTaskDictionary objectForKey:REQUEST_KLINE];
            NSString* strSymbolId = [klineDict objectForKey:SYMBOLID];
            NSString* strPeriodType = [klineDict objectForKey:PERIOD];
            [_subscribe unSubscribeLastKLine:_socketIO keySymBolid:strSymbolId keyPeriod:strPeriodType];
        }
    }
    //else cont.
}


- (BOOL) connectsWithServerName:(NSString*)strServerName
{
    BOOL bResult = NO;
*/
    /********************************************
     连接行情服务器
     ********************************************/
/*
    if (strServerName && ![strServerName isEqualToString:@""])
    {
        if (_socketIO.isConnecting || _socketIO.isConnected)
        {
            if (![strServerName isEqualToString:self.serverName])
            {
                [self disconnectsMarketServer];
                bResult = [self connectsToMarketServer:strServerName];
            }
            //else cont.
        }
        else
            bResult = [self connectsToMarketServer:strServerName];
    }
    else
        HB_LOG(@"error!");
    
    return bResult;
}

- (void) subscribesDefaultAction
{
     NSString* detailSymbolId = [_requestTaskDictionary objectForKey:@"MarketDetail"];
    if (detailSymbolId)
    {
        NSString* keyDepth = [_requestTaskDictionary objectForKey:@"MarketDetail_Depth"];
        [_subscribe subscribeMarketDetail:_socketIO keySymbolID:detailSymbolId marketDetail:keyDepth];
    }
    
    NSDictionary* klineDict = [_requestTaskDictionary objectForKey:REQUEST_KLINE];
    if (klineDict)
    {
        NSString* strSymbolId = [klineDict objectForKey:SYMBOLID];
        NSString* strPeriodType = [klineDict objectForKey:PERIOD];
        [_subscribe requestKLineWithSocket:_socketIO keySymBolid:strSymbolId keyPeriod:strPeriodType];
    }
    //else cont.
}
*/
#pragma mark - market detail
/******************************************************
 请求实时数据,只有当切换交易类型的时候才会变化；
 *****************************************************/
/*
- (void) localRequestMarketDetailWithSymbolID:(NSString*)keySymbolID
{
    NSString* oldSymbolID = [_requestTaskDictionary objectForKey:@"MarketDetail"];
    NSString* oldKeyDepth = [_requestTaskDictionary objectForKey:@"MarketDetail_Depth"];
    NSString* keyDepth = [self getMarketDetailDepth];
    BOOL bChangeSymbolID = oldSymbolID && ![oldSymbolID isEqualToString:keySymbolID];
    BOOL bChangeDepth = oldKeyDepth && ![oldKeyDepth isEqualToString:keyDepth];
    if (bChangeDepth || bChangeSymbolID)
    {
        [_subscribe unSubscribeMarketDetail:_socketIO keySymbolID:oldSymbolID marketDetail:oldKeyDepth];
    }
    //else cont.
    
    [_subscribe subscribeMarketDetail:_socketIO keySymbolID:keySymbolID marketDetail:keyDepth];
    [_requestTaskDictionary setObject:keySymbolID forKey:@"MarketDetail"];
    [_requestTaskDictionary setObject:keyDepth forKey:@"MarketDetail_Depth"];
}

#pragma mark - kline

- (BOOL) addRequestTask:(NSString*)keyType
{
    BOOL bResult = YES;
    if (keyType)
    {
        if (![_requestTaskDictionary objectForKey:keyType])
            [_requestTaskDictionary setObject:@NO forKey:keyType];
        //else cont.
        
        if (![[_requestTaskDictionary objectForKey:keyType] boolValue])
        {
            [_requestTaskDictionary setObject:@"YES" forKey:keyType];
            [self performSelector:@selector(clearResquestTask:) withObject:keyType afterDelay:30.0f];
        }
        else
            bResult = NO;
    }
    else
        HB_LOG(@"error!");
    
    return bResult;
}

- (void) clearResquestTask:(NSString*)keyType
{
    if (keyType)
    {
        if (_requestTaskDictionary)
            [_requestTaskDictionary setObject:@NO forKey:keyType];
        else
            HB_LOG(@"error!");
    }
    //else cont.
}

- (void) localRequestKLineWithPeriod:(NSString*)strPeriodType widthSymbolId:(NSString*)strSymbolId
{
    NSDictionary* diction= @{
                             @"version":@1,
                             @"msgType":@"reqKLine",
                             SYMBOLID:strSymbolId,
                             PERIOD:strPeriodType,
                             @"from":@0,
                             @"to":@-1
                             };
    
    [[DLMainManager sharedDBManager] updateKLine:diction localUpdate:YES];
    
    if (_socketIO.isConnected)
    {
*/
        /******************************************************
         这个限制必须放到有网的情况下，否则永远不会返回，会造成死等待。
         一旦发生这种情况就需要30s之后解开这种死等待。
         ******************************************************/
/*
        NSString* strKey = [NSString stringWithFormat:@"%@_%@",strSymbolId,strPeriodType];
        if ([self addRequestTask:strKey])
        {
            [_subscribe requestKLineWithSocket:_socketIO keySymBolid:strSymbolId keyPeriod:strPeriodType];
        }
        //else 上次请求的数据尚未返回，不再重复请求
    }
    //else cont.
    
    [_requestTaskDictionary setObject:diction forKey:REQUEST_KLINE];
}


- (void) unSubscribeLastKLine:(NSString*)strPeriodType widthSymbolId:(NSString*)strSymbolId
{
    if (strPeriodType && strSymbolId)
        [_subscribe unSubscribeLastKLine:_socketIO keySymBolid:strSymbolId keyPeriod:strPeriodType];
    //else cont.
}

#pragma mark - service

- (BOOL) connectsServer
{
    BOOL bResult = NO;
*/
    /********************************************
     连接行情服务器
     ********************************************/
/*
    if (_socketIO.isConnecting || _socketIO.isConnected)
    {
        bResult = YES;
    }
    else
    {
        if (self.serverName)
            bResult = [self connectsToMarketServer:self.serverName];
        else
            HB_LOG(@"error!");
    }
    
    return bResult;
}
*/
/*
- (BOOL) connectsToMarketServer:(NSString*)strServerName
{
    BOOL bResult = NO;
    if (strServerName)
    {
        if (!_socketIO)
            _socketIO = [[SocketIO alloc] initWithDelegate:self];
        //else cont.
        
        NSInteger nPort = 0;
        if ([strServerName isEqualToString:SERVER_HUOBI_MARKET_IP])
        {
            nPort = 80;
            bResult = YES;
        }
        else if ([strServerName isEqualToString:SERVER_HUOBI_MARKET_IP_SLOW])
            bResult = YES;
        else if ([strServerName isEqualToString:SERVER_BITVC_MARKET])
            bResult = YES;
        else
            bResult = YES;
        
        if (bResult)
        {
            self.serverName = strServerName;
            [_socketIO connectToHost:strServerName onPort:nPort];
        }
        else
            HB_LOG(@"error!");
    }
    else
        HB_LOG(@"error!");
    
    return bResult;
}

- (BOOL) disconnectsMarketServer
{
    BOOL bResult = NO;
    [self closeBadRepeat];
    
    SocketIOCallback cb = ^(id argsData) {
        NSDictionary *response = argsData;
        // do something with response
        DEBUGLOG_HB(@"ack arrived: %@", response);
        if (_socketIO)
        {
            // test forced disconnect
            [_socketIO disconnectForced];
        }
        else
            HB_LOG(@"error!");
    };
    
    [_socketIO sendMessage:@"hello back!" withAcknowledge:cb];
    bResult = YES;
    return bResult;
}

- (void) cancelSubscribeTimeOut
{
    //[NSObject cancelPreviousPerformRequestsWithTarget:_subscribe selector:@selector(subscribeTimeOutWithObject:) object:dictionary];
    [NSObject cancelPreviousPerformRequestsWithTarget:_subscribe];
}

#pragma mark - bad server connect

- (BOOL) badConnectToServer
{
    BOOL bResult = NO;
    if (self.bReachable)
    {
*/
        /****************************************************
         当网络可以连接的时候，发生连接服务器错误，
         需要重新尝试连接服务器。
         ****************************************************/
/*
        [self badConnectToServerRepeate];
    }
    else
    {
        //HB_LOG(@"Network is not reachable!");
        
    }//endi
    
    bResult = YES;
    
    return bResult;
}
*/
/*********************************************************************************
 在网络可用的情况下，也会出现服务器请求错误的情况。需要重新连接服务器：
 第1次失败：立即链接；
 第2次失败：等待3s连接；
 第3次失败：等待10s连接；
 之后每隔30s连接一次，直到服务器连接上为止。
 服务器连接上之后，将错误次数设置为0；
 *********************************************************************************/

/*
- (BOOL) badConnectToServerRepeate
{
    BOOL bResult = NO;
    switch (_nBadRepeatCount) {
        case 0:
        {
            //立即链接；
            [self connectsServer];
            break;
        }
        case 1:
        {
            //等待3s连接;
            [self performSelector:@selector(connectsServer) withObject:nil afterDelay:3.0f];
            break;
        }
        case 2:
        {
            //等待10s连接；
            [self performSelector:@selector(connectsServer) withObject:nil afterDelay:10.0f];
            break;
        }
        case 3:
        {
            //之后每隔30s连接一次，直到服务器连接上为止。
            if (!_timerBadRepeat)
            {
                self.timerBadRepeat = [NSTimer scheduledTimerWithTimeInterval:30.0f
                                                                       target:self
                                                                     selector:@selector(connectRepeateWithTimer:)
                                                                     userInfo:nil
                                                                      repeats:YES];
            }
            //else cont.
            
            break;
        }
        default:
            HB_LOG(@"error!");
            break;
    }//ends
    
    _nBadRepeatCount++;
    
    bResult = YES;
    
    return bResult;
}

- (BOOL) closeBadRepeat
{
    BOOL bResult = NO;
*/
    /****************************************************
     成功链接服务器当服务器可以连接的时候，停止重新连接机制。
     ****************************************************/
/*
    if(self.timerBadRepeat && [self.timerBadRepeat isValid])
    {
        [self.timerBadRepeat invalidate];
        self.timerBadRepeat = nil;
    }
    //else 没有发生
    
    _nBadRepeatCount = 0;
    
    bResult = YES;
    
    return bResult;
}
*/
/*
- (void) connectRepeateWithTimer:(NSTimer*)aTimer
{
    [self connectsServer];
}

*/

#pragma mark - did receive event
//MARK: 横屏K线数据
- (BOOL) didReceiveMarketDetail:(NSDictionary* )argsDict
{
    BOOL bResult = NO;
    if (!self.bApplicationEnteredBack)
    {
        NSDictionary* pldDict = [argsDict objectForKey:PAYLOAD];
        if (pldDict)
        {
            //有时候美元的行情中，卖1会出现价格为0的情况。在这加个判断过滤掉，觉得这样不太好，最好还是服务器端查一下
            // for special use
            NSDictionary* asks = [pldDict objectForKey:@"asks"];
            if (asks) {
                NSArray* price = [asks objectForKey:@"price"];
                NSString* aPrice = [price objectAtIndex:0];
                if (aPrice.integerValue == 0) {
                    return bResult;
                }
            }
            // special use end
            
            [[DLMainManager sharedDBManager] updateMarketDetail:pldDict localUpdate:NO];
        }
        else
            HB_LOG(@"error!");
    }
    //else cont.
    return bResult;
}
/*
- (void) didReceiveMarketOverview:(NSDictionary* )argsDict
{
#if 1
    if (self.bApplicationEnteredBack)
        return;
    //else cont.
    
    NSDictionary* pldDict = [argsDict objectForKey:PAYLOAD];
    if (pldDict)
    {
        [[DLMainManager sharedDBManager] updateMarketOverview:pldDict localUpdate:NO];
    }
    else
        HB_LOG(@"error!");
#endif
}
*/
//MARK: 这是获取最新一条的数据后的处理
- (void) didReceiveLastKLine:(NSDictionary* )argsDict
{
    if (!self.bApplicationEnteredBack)
    {
        [[DLMainManager sharedDBManager] updateLastKLine:argsDict];
    }
    //else cont.
}
//MARK: 这是获取300条的数据后的处理
- (void) didReceiveREQKLine:(NSDictionary* )argsDict
{
    NSDictionary* pldDict = [argsDict objectForKey:PAYLOAD];
    if(pldDict)
    {
        NSString* strPeriod = [pldDict objectForKey:PERIOD];
        NSString* strSymBolid = [pldDict objectForKey:SYMBOLID];
        NSString* strKey = [NSString stringWithFormat:@"%@_%@",strSymBolid,strPeriod];
        [_requestTaskDictionary setObject:@"NO" forKey:strKey];
        
        if (self.bApplicationEnteredBack)
            return;
        //else cont.
        [[DLMainManager sharedDBManager] updateKLine:pldDict localUpdate:NO];
    }
    else
        HB_LOG(@"error!");
}
/*
- (void) didReceiveMarketDepthTopShort:(NSDictionary* )argsDict
{
#if 1
    if (self.bApplicationEnteredBack)
        return;
    //else cont.
    NSDictionary* pldDict = [argsDict objectForKey:PAYLOAD];
    [[DLMainManager sharedDBManager] updateMarketDepthTopShort:pldDict localUpdate:NO];
#endif
}

# pragma mark -
# pragma mark socket.IO-objc delegate methods

- (void) socketIODidConnect:(SocketIO *)socket
{
    DEBUGLOG_HB(@"socket.io connected.");
    
    [self closeBadRepeat];
    [self subscribesDefaultAction];
}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    DEBUGLOG_HB(@"socket.io disconnected. did error occur? %@", error);
    
    [self badConnectToServer];
}

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet
{
    DEBUGLOG_HB(@"socket.io did receive message.");
}

- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet
{
    DEBUGLOG_HB(@"socket.io did receive json.");
}

- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet
{
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
    [self badConnectToServer];
    
    if (error)
    {
        if ([error code] == SocketIOUnauthorized) {
            DEBUGLOG_HB(@"not authorized");
        } else {
            DEBUGLOG_HB(@"onError() %@", error);
        }
    }
    //else cont.
}


- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    DEBUGLOG_HB(@"socket.io did receive event.");
    
    NSString* jsonString  = packet.data;
    
    NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData)
    {
        NSDictionary* jsonDict = [DLMainManager toArrayOrDictionary:jsonData];
        if (jsonDict && [jsonDict isKindOfClass:[NSDictionary class]])
        {
            NSDictionary* argsDict = [[jsonDict objectForKey:@"args"] firstObject];
            if (argsDict)
            {
                
                NSString* keyMarketDetail = [self getMarketDetailDepth];
                
                NSString* msgType = [argsDict objectForKey:MSGTYPE];
                //NSLog(@"%@", msgType);
                if ([msgType isEqualToString:REQMSGSUBSCRIBLE])
                {
                    [_subscribe didReceiveReqMsgSub:argsDict];
                }
                else if ([msgType isEqualToString:REQMSGUNSUBSCRIBE])
                {
                    [_subscribe didReceiveReqMsgUnSub:argsDict];
                }
                else if ([msgType isEqualToString:keyMarketDetail])
                {
                    [self didReceiveMarketDetail:argsDict];
                }
                else if ([msgType isEqualToString:MARKETOVERVIEW])
                {
                    [self didReceiveMarketOverview:argsDict];
//                    NSDate *now = [NSDate date];
//                    NSLog(@"%@", now);
                }
                else if ([msgType isEqualToString:LASTKLINE])
                {
                    [self didReceiveLastKLine:argsDict];
                }
                else if ([msgType isEqualToString:REQKLINE])
                {
                    [self didReceiveREQKLine:argsDict];
                }
                else if ([msgType isEqualToString:REQSYMBOLLIST])
                    ;//交易列表
                else if ([msgType isEqualToString:MARKETDEPTHTOPSHORT])
                {
                    [self didReceiveMarketDepthTopShort:argsDict];
                }
                else
                    HB_LOG(@"error!");
            }
            else
                HB_LOG(@"error!");
        }
        else
            HB_LOG(@"error");
    }
    else
        HB_LOG(@"error");
}
 */
@end
