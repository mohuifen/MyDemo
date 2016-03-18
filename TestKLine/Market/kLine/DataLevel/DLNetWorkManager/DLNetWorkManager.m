//
//  DLNetWorkManager.m
//  BtcDemo
//
//  Created by FuYou on 14/11/21.
//  Copyright (c) 2014年 FuckYou. All rights reserved.
//

#import "DLNetWorkManager.h"
#import "DLMainManager.h"
#import "Reachability.h"
#import "DLSeverObject.h"
#import "DLDataBaseManager.h"
#import "AppDelegate.h"
#import "TradeCodeData.h"
#import "HBMessageAlertWindow.h"
#import "BitVCHttpRequest2.h"
#import "StoryBoardController.h"
#define USE_WIFI_NET 1

#define server_done 0
@interface DLNetWorkManager()
{
    /********************************************
     网络是否可以可用，通过Reachability类来判断。
     ********************************************/
    BOOL _bReachable;
    BOOL _bReachableViaWWAN;
    BOOL _bReachableViaWiFi;
    
    DLSeverObject* _huobiServerObject;
    
    DLSeverObject* _bitvcServerObject;
    
    NSMutableDictionary* _serverManager;
    
    NSTimer* _timer;
}
- (BOOL) initReachability:(BOOL)bRestarted;
@end



@implementation DLNetWorkManager
- (id) init
{
    self = [super init];
    if (self)
    {
        [self initNotification];
        
        [self initHttpsRequestTimer];
    }
    //else cont.
    
    return self;
}


- (void) initNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMarketServerChanged:) name:NOTIFICATION_MARKETFLOWTYPE_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMarketServerRateChanged:) name:NOTIFICATION_USER_MARKETREFRESHRATE_CHANGE object:nil];
    
    //加三次是什么鬼？
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMarketServerChanged:) name:NOTIFICATION_MARKETFLOWTYPE_CHANGED object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMarketServerChanged:) name:NOTIFICATION_MARKETFLOWTYPE_CHANGED object:nil];
//    
    
}

- (void) dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MARKETFLOWTYPE_CHANGED object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_USER_MARKETREFRESHRATE_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_bReachable)
    {
        NSArray* keysArray = [_serverManager allKeys];
        for (NSString* key in keysArray)
        {
            DLSeverObject* bitvcServer = [self getServerObjectWithName:key];
            [bitvcServer disconnectsMarketServer];
        }
        _bReachable = NO;
    }
    //else cont.
}

#pragma mark - https request

- (void) initHttpsRequestTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(fireHttpsRequest) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void) fireHttpsRequest
{
    UIViewController* rootController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    if (rootController)
    {
        StoryBoardController* storyController = (StoryBoardController*)rootController;
        if ([storyController isKindOfClass:[StoryBoardController class]])
        {
            NSInteger current = [storyController getCurrentTabIndex];
            if (1 == current)
            {
                [[BitVCHttpRequest2 getInstance] requestSpotEntrustCount];
            }
            //不是交易界面
        }
        //else cont
    }
    //else cont
}

- (void) timerInvalidate
{
    [_timer invalidate];
}

- (void) timerFire
{
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(fireHttpsRequest) userInfo:nil repeats:YES];
    [_timer fire];
}

#pragma mark - server object

- (DLSeverObject*) getServerObjectWithName:(NSString*)strServername
{
    if (!_serverManager)
    {
        _serverManager = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    
    DLSeverObject* serverObject = [_serverManager objectForKey:strServername];
    if (!serverObject)
    {
        serverObject = [[DLSeverObject alloc] init];
        [_serverManager setObject:serverObject forKey:strServername];
    }
    //else cont.
    
    [serverObject connectsWithServerName:strServername];
    
    return serverObject;
}

#pragma mark - notification response
- (void) onMarketServerRateChanged:(NSNotification*)aNotification
{
    if (_bReachable){
        NSArray* keysArray = [_serverManager allKeys];
        for (NSString* serverName in keysArray)
        {
            DLSeverObject* serverObject = [self getServerObjectWithName:serverName];
            [serverObject cancelSubscribeTimeOut];
            [serverObject disconnectsMarketServer];
        }
        [_serverManager removeAllObjects];
        
        NSString* strSymbolType = [[DLMainManager sharedMainManager] loadSymbolType];
        NSString* strServerName = [self getServerNameWithSymbolID:strSymbolType];
        
        DLSeverObject* serverObject = [self getServerObjectWithName:strServerName];
        [serverObject localRequestMarketDetailWithSymbolID:strSymbolType];
        
    }
}

- (void) onMarketServerChanged:(NSNotification*)aNotification
{
#if server_done
    DLSeverObject* huobiServer = [self getServerObjectWithName:[self getHuobiMarketServerID]];
    DLSeverObject* bitvcServer = [self getServerObjectWithName:[self getBitVCMarketServerID]];
    
    huobiServer.bReachable = _bReachable;
    bitvcServer.bReachable = _bReachable;
    
    if (_bReachable){
        NSString* huobiServerName = [self getHuobiMarketServerID];
        [huobiServer connectsWithServerName:huobiServerName];
        
        NSString* bitvcServerName =  [self getBitVCMarketServerID];
        [bitvcServer connectsWithServerName:bitvcServerName];
    }
    //else cont.
#else
    if (_bReachable){
        NSArray* keysArray = [_serverManager allKeys];
        for (NSString* serverName in keysArray)
        {
            DLSeverObject* serverObject = [self getServerObjectWithName:serverName];
            [serverObject connectsWithServerName:serverName];
        }
    }
#endif

}

#pragma mark - suspend and restart
- (void) suspendNetWork
{
    [self timerInvalidate];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MARKETFLOWTYPE_CHANGED object:nil];
#if server_done
    if (_bReachable)
    {
        DLSeverObject* huobiServer = [self getServerObjectWithName:[self getHuobiMarketServerID]];
        DLSeverObject* bitvcServer = [self getServerObjectWithName:[self getBitVCMarketServerID]];
        
        [huobiServer suspendNetWork];
        
        [bitvcServer suspendNetWork];
    }
    //else cont.
    
#else
    if (_bReachable){
        NSArray* keysArray = [_serverManager allKeys];
        for (NSString* serverName in keysArray)
        {
            DLSeverObject* serverObject = [self getServerObjectWithName:serverName];
            [serverObject suspendNetWork];
        }
    }
    
#endif
}

- (void) restartNetWork
{
    [self timerFire];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMarketServerChanged:) name:NOTIFICATION_MARKETFLOWTYPE_CHANGED object:nil];
    
    [self initReachability:YES];
}


- (void) setBEnterBack:(BOOL)bEnterBack
{
    _bEnterBack = bEnterBack;
#if server_done
    
    DLSeverObject* huobiServer = [self getServerObjectWithName:[self getHuobiMarketServerID]];
    DLSeverObject* bitvcServer = [self getServerObjectWithName:[self getBitVCMarketServerID]];
    [huobiServer bApplicationEnteredBack];
    [bitvcServer bApplicationEnteredBack];
    
#else
    NSArray* keysArray = [_serverManager allKeys];
    for (NSString* serverName in keysArray)
    {
        DLSeverObject* serverObject = [self getServerObjectWithName:serverName];
        [serverObject bApplicationEnteredBack];
    }
#endif
}

#pragma mark - handware
- (BOOL) initReachability:(BOOL)bRestarted
{
    BOOL bResult = NO;
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    reach.reachableBlock = ^(Reachability* reachability)
    {
        _bReachableViaWWAN = reachability.isReachableViaWWAN;
        _bReachableViaWiFi = reachability.isReachableViaWiFi;
        
        _bReachable = YES;
#if server_done
        DLSeverObject* huobiServer = [self getServerObjectWithName:[self getHuobiMarketServerID]];
        DLSeverObject* bitvcServer = [self getServerObjectWithName:[self getBitVCMarketServerID]];
        
        NSString* strServerName = [self getHuobiMarketServerID];
        huobiServer.bReachable = YES;
        [huobiServer connectsWithServerName:strServerName];
        
        NSString* bitvcServerName =  [self getBitVCMarketServerID];
        bitvcServer.bReachable = YES;
        [bitvcServer connectsWithServerName:bitvcServerName];
#else
//        NSArray* keysArray = [_serverManager allKeys];
//        for (NSString* serverName in keysArray)
//        {
//            DLSeverObject* serverObject = [self getServerObjectWithName:serverName];
//            serverObject.bReachable = YES;
//            [serverObject connectsWithServerName:serverName];
//        }
        [self onMarketServerRateChanged:nil];
#endif
        
    };
    
    reach.unreachableBlock = ^(Reachability* reachability)
    {
#if server_done
        
        DLSeverObject* huobiServer = [self getServerObjectWithName:[self getHuobiMarketServerID]];
        DLSeverObject* bitvcServer = [self getServerObjectWithName:[self getBitVCMarketServerID]];
        
        huobiServer.bReachable = NO;
        bitvcServer.bReachable = NO;
        
#else
        
        NSArray* keysArray = [_serverManager allKeys];
        for (NSString* serverName in keysArray)
        {
            DLSeverObject* serverObject = [self getServerObjectWithName:serverName];
            serverObject.bReachable = NO;
        }
#endif
    };
    
    [reach startNotifier];
    
    bResult = YES;
    return bResult;
}

- (BOOL) isNetWorkConnect
{
    return _bReachable;
}

- (void) showNetWorkAlert
{
#if 0
    if (!_alertInfoNetWork)
    {
        _alertInfoNetWork = [[ImMessageAlertWindow alloc] initMessageAlert];
    }
    //else cont.
    
    [_alertInfoNetWork setContentWithMessage:NSLocalizedString(@"SR_NetworkSpeedSlow", @"")];
    if (!_alertInfoNetWork.bAlertShowing)
        [_alertInfoNetWork showAlert];
    //else cont.
#else
    [HBMessageAlertWindow showMessageAlertWindow:NSLocalizedString(@"SR_NetworkSpeedSlow", @"")];
#endif
}

#pragma mark - server

- (NSString*) getHuobiMarketServerID
{
    NSString* serverName = @"";
    NSNumber* marketFlowType = [[DLMainManager sharedMainManager] loadMarketFlowType];
   
    switch ([marketFlowType integerValue])
    {
        case MARKET_REALTIME:
        {
            //Always Real Time
            serverName = SERVER_HUOBI_MARKET_IP;
            break;
        }
        case MARKET_REALTIME_ONLY_WIFI:
        {
            //Real Time Under WiFi
            if (_bReachableViaWiFi)
            {
                serverName = SERVER_HUOBI_MARKET_IP;
            }
            else if (_bReachableViaWWAN)
            {
                serverName = SERVER_HUOBI_MARKET_IP_SLOW;
            }
            else if (!_bReachable)
            {
                //断网了，什么都不做
            }
            else
                HB_LOG(@"error!");
            break;
        }
        case MARKET_NORMAL:
        {
            //Always Normal
            serverName = SERVER_HUOBI_MARKET_IP_SLOW;
            break;
        }
        default:
            HB_LOG(@"error!");
            break;
    }//ends
    
    return serverName;
}

- (NSString*) getBitVCMarketServerID
{
    NSString* serverName = SERVER_BITVC_MARKET;
    
    return serverName;
}

#pragma mark - request

- (void) reLocalDataWithSymbolID:(NSString*)keySymbolID
{
    NSDictionary* diction= @{
                             @"version":@1,
                             @"msgType":@"reqMsgSubscribe",
                             @"symbolList":@{MARKETOVERVIEW: @[@{@"symbolId":keySymbolID,@"pushType":@"pushLong"}]}
                             };
    [[DLMainManager sharedDBManager] updateMarketOverview:diction localUpdate:YES];
    
    NSDictionary* jsonDict= @{
                              @"version":@1,
                              @"msgType":@"reqMsgSubscribe",
                              @"symbolList":@{@"marketDepthTopShort":@[@{@"symbolId":keySymbolID,@"pushType":@"pushLong"}]}
                              };
    
    [[DLMainManager sharedDBManager] updateMarketDepthTopShort:jsonDict localUpdate:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATON_RELOAD_SYMBOLID object:nil];
    
}

/******************************************************
 请求实时数据,只有当切换交易类型的时候才会变化；
 *****************************************************/
- (void) spotRequestMarketDetailWithSymbolID:(NSString*)keySymbolID
{
    NSString* strServerName = [self getServerNameWithSymbolID:keySymbolID];
    DLSeverObject* serverObject = [self getServerObjectWithName:strServerName];
    [serverObject localRequestMarketDetailWithSymbolID:keySymbolID];
}

- (NSString*) getServerNameWithSymbolID:(NSString*)keySymbolID
{
    NSString* strServerName = nil;
    TradeCodeData* tradeData = [DLMainManager getTradeCodeData:keySymbolID];
    if (tradeData)
    {
//#if 0
//        strServerName = tradeData.strSlowQuotation;
//#else
//        strServerName = tradeData.strFastQuotation;
//#endif
        NSNumber* marketRate = [[DLMainManager sharedMainManager] loadMarketFlowType];
        if (marketRate)
        {
            if (marketRate.integerValue == MARKET_REALTIME)
            {
                strServerName = tradeData.strFastQuotation;
#if HB_TEST_MARKET
                // for test
                strServerName = @"http://172.32.1.229:58390";
                // test end
#endif
            }
            else if (marketRate.integerValue == MARKET_REALTIME_ONLY_WIFI)
            {
                strServerName = _bReachableViaWiFi ? tradeData.strFastQuotation : tradeData.strSlowQuotation;
#if HB_TEST_MARKET
                // for test
                strServerName = _bReachableViaWiFi ? @"http://172.32.1.229:58390" : @"http://172.32.1.229:48390/slow";
                // test end
#endif
            }
            else {
                strServerName = tradeData.strSlowQuotation;
#if HB_TEST
                // for test
                strServerName = @"http://172.32.1.229:48390/slow";
                //strServerName = @"http://hq.huobi.com/slow";
                // test end
#endif
            }
        }
    }
    else
    {
        strServerName = _bReachableViaWiFi ? tradeData.strFastQuotation : tradeData.strSlowQuotation;
    }
    //else cont.
    
    if (!strServerName)
    {
        strServerName = [self getHuobiMarketServerID];
        keySymbolID = @"btccny";
    }
    //else cont.
    NSRange httpRange = [strServerName rangeOfString:@"http://"];
    if (httpRange.length > 0)
        strServerName = [strServerName substringFromIndex:httpRange.location + httpRange.length];
    //else cont.
    
    NSRange httpsRange = [strServerName rangeOfString:@"https://"];
    if (httpsRange.length > 0)
        strServerName = [strServerName substringFromIndex:httpsRange.location + httpRange.length];
    //else cont.
    
    [[DLMainManager sharedMainManager] saveSymbolType:keySymbolID];
    
    return strServerName;
}

- (void) futureGoodsMarketDetailWithSymbolID:(NSString*)keySymbolID
{
    DLSeverObject* bitvcServer = [self getServerObjectWithName:[self getBitVCMarketServerID]];
    [bitvcServer localRequestMarketDetailWithSymbolID:keySymbolID];
}

- (void) localRequestKLineWithPeriod:(NSString*)strPeriodType widthSymbolId:(NSString*)strSymbolId
{
    if (!self.bEnterBack)
    {
#if server_done
        DLSeverObject* huobiServer = [self getServerObjectWithName:[self getHuobiMarketServerID]];
        DLSeverObject* bitvcServer = [self getServerObjectWithName:[self getBitVCMarketServerID]];
        
        NSArray* symbolIdArray = [DLMainManager symbolsArrayOfHuobi];
        if (NSNotFound != [symbolIdArray indexOfObject:strSymbolId])
            [huobiServer localRequestKLineWithPeriod:strPeriodType widthSymbolId:strSymbolId];
        else
            [bitvcServer localRequestKLineWithPeriod:strPeriodType widthSymbolId:strSymbolId];
#else
        NSString* strServerName = [self getServerNameWithSymbolID:strSymbolId];
        DLSeverObject* serverObject = [self getServerObjectWithName:strServerName];
        [serverObject localRequestKLineWithPeriod:strPeriodType widthSymbolId:strSymbolId];
#endif
    }
    else
        HB_LOG(@"error!");
}

- (void) unSubscribeLastKLine:(NSString*)strPeriodType widthSymbolId:(NSString*)strSymbolId
{
    NSString* strServerName = [self getServerNameWithSymbolID:strSymbolId];
    DLSeverObject* serverObject = [self getServerObjectWithName:strServerName];
    [serverObject unSubscribeLastKLine:strPeriodType widthSymbolId:strSymbolId];
}

/******************************************************
 请求买卖盘历史数据,只有当切换交易类型、的时候才会变化；
 *****************************************************/
- (void) localRequestMarketDetailWithSymbolID:(NSString*)keySymbolID
{
    if (!self.bEnterBack)
    {
#if server_done
        DLSeverObject* huobiServer = [self getServerObjectWithName:[self getHuobiMarketServerID]];
        DLSeverObject* bitvcServer = [self getServerObjectWithName:[self getBitVCMarketServerID]];
        
        NSArray* symbolIdArray = [DLMainManager symbolsArrayOfHuobi];
        if (NSNotFound != [symbolIdArray indexOfObject:keySymbolID])
            [huobiServer localRequestMarketDetailWithSymbolID:keySymbolID];
        else
            [bitvcServer localRequestMarketDetailWithSymbolID:keySymbolID];
#else
        
        NSString* strServerName = [self getServerNameWithSymbolID:keySymbolID];
        DLSeverObject* serverObject = [self getServerObjectWithName:strServerName];
        [serverObject localRequestMarketDetailWithSymbolID:keySymbolID];
        
//        NSArray* keysArray = [_serverManager allKeys];
//        for (NSString* serverName in keysArray)
//        {
//            DLSeverObject* serverObject = [self getServerObjectWithName:serverName];
//            [serverObject localRequestMarketDetailWithSymbolID:keySymbolID];
//        }
#endif
    }
    else
        HB_LOG(@"error!");
}
@end
