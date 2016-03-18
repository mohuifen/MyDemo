//
//  DLMainManager.m
//  BtcDemo
//
//  Created by FuYou on 14/11/21.
//  Copyright (c) 2014年 FuckYou. All rights reserved.
//

#import "DLMainManager.h"
#import "DLNetWorkManager.h"
#import "DLConfigureManager.h"
#import "ImHBLog.h"
#import "DLDataBaseManager.h"
#import "constants.h"
#import "CONFIG_CONSTAN.h"
#import "DLTextAttributeData.h"
#import "TradeCodeData.h"
#import "AppDelegate.h"

#import "NSUserDefaults+Helper.h"

#define DEFAULTS_HUOBI_SYMBOL_TYPE @"DEFAULTS_HUOBI_SYMBOL_TYPE"

#define DEFAULTS_BITVC_SYMBOL_TYPE @"DEFAULTS_BITVC_SYMBOL_TYPE"

#define DEFAULTS_MARKETFLOW_TYPE @"MarketFlowType"

#define DEFAULTS_TAB_INDEX @"tabIndex"

@interface DLMainManager ()
@property (nonatomic) DLNetWorkManager* networkManager;
@property (nonatomic) DLDataBaseManager* dbManager;
@property (retain,nonatomic) DLTextAttributeData* textAttributeData;
@end

@implementation DLMainManager
+ (DLMainManager *)sharedMainManager
{
    static DLMainManager *sharedMainManagerInstance = nil;
    
    static dispatch_once_t predicate; dispatch_once(&predicate, ^{
        sharedMainManagerInstance = [[self alloc] init];
    });
    
    return sharedMainManagerInstance;
}

+ (id) sharedNetWorkManager
{
    DLNetWorkManager* dbResult = nil;
    DLMainManager* mainManager = [DLMainManager sharedMainManager];
    if (mainManager)
    {
        if (!mainManager.networkManager)
            mainManager.networkManager = [[DLNetWorkManager alloc] init];
        //else cont.
        
        dbResult = mainManager.networkManager;
    }
    else
        HB_LOG(@"error!");
    
    return dbResult;
}

+ (id) sharedDBManager
{
    DLDataBaseManager* dbResult = nil;
    DLMainManager* mainManager = [DLMainManager sharedMainManager];
    if (mainManager)
    {
        if (!mainManager.dbManager)
            mainManager.dbManager = [[DLDataBaseManager alloc] init];
        //else cont.
        
        dbResult = mainManager.dbManager;
    }
    else
        HB_LOG(@"error!");
    
    return dbResult;
}

+ (id) sharedTextAttributeData
{
    DLTextAttributeData* textAttributeData = nil;
    DLMainManager* mainManager = [DLMainManager sharedMainManager];
    if (mainManager)
    {
        if (!mainManager.textAttributeData)
            mainManager.textAttributeData = [[DLTextAttributeData alloc] init];
        //else cont.
        
        textAttributeData = mainManager.textAttributeData;
    }
    else
        HB_LOG(@"error!");
    
    return textAttributeData;
}


#pragma mark - tool
+(id) toArrayOrDictionary:(NSData*)jsonData
{
    NSError* error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    
    if ( jsonObject != nil && error == nil )
        ;
    else
        jsonObject = nil;
    
    return jsonObject;
}

#pragma mark - data


+ (TradeCodeData*) getTradeCodeData:(NSString*)strCode
{
    TradeCodeData* dataResult = nil;
    BOOL bFind = NO;
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    for (TradeCodeData* data in delegate.btcTradeCodeAry)
    {
        if([data.strCode isEqualToString:strCode])
        {
            dataResult = data;
            bFind = YES;
            break;
        }
        //else cont.
    }//endf
    
    if (!bFind)
    {
        for (TradeCodeData* data in delegate.ltcTradeCodeAry)
        {
            if([data.strCode isEqualToString:strCode])
            {
                dataResult = data;
                bFind = YES;
                break;
            }
            //else cont.
        }//endf
    }
    //else cont.
    
    return dataResult;
}

+ (NSArray*) symbolsArrayOfHuobi
{
    NSArray* symbolArray = @[@"btccny",@"ltccny"];
    
    return symbolArray;
}

+ (NSArray*) periodsArray
{
    NSArray* symbolArray = @[@"timeLine_type",@"1min",@"5min",@"30min",@"60min",@"1day",KLINE1WEEK];
    
    return symbolArray;
}

- (NSUInteger) loadCoinType
{
    NSString* strCount = [[self loadAccountUID] stringValue];
    NSString* strKey = [NSString stringWithFormat:@"%@_CoinType",strCount];
    NSNumber* nType = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
    if (!nType)
        nType = @(COIN_TYPE_BTC);
    //else cont.
    
    return  [nType unsignedIntegerValue];
}

- (void) saveCoinType:(NSUInteger)aType
{
    NSNumber *nType = [NSNumber numberWithUnsignedInteger:aType];
    
    NSString* strCount = [[self loadAccountUID] stringValue];
    NSString* strKey = [NSString stringWithFormat:@"%@_CoinType",strCount];
    [[NSUserDefaults standardUserDefaults] setObject:nType forKey:strKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSUInteger) loadSpotCoinType
{
    NSString* strCount = [[self loadAccountUID] stringValue];
    NSString* strKey = [NSString stringWithFormat:@"%@_SpotCoinType",strCount];
    NSNumber* nType = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
    if (!nType)
        nType = @(COIN_TYPE_BTC);
    //else cont.
    
    return  [nType unsignedIntegerValue];
}

- (void) saveSpotCoinType:(NSUInteger)aType
{
    NSNumber *nType = [NSNumber numberWithUnsignedInteger:aType];
    
    NSString* strCount = [[self loadAccountUID] stringValue];
    NSString* strKey = [NSString stringWithFormat:@"%@_SpotCoinType",strCount];
    [[NSUserDefaults standardUserDefaults] setObject:nType forKey:strKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) saveMarketDetail:(NSNumber*)marketDetail
{
    NSString* strCount = [[self loadAccountUID] stringValue];
    NSString* strKey = [NSString stringWithFormat:@"%@_marketdetail",strCount];
    [[NSUserDefaults standardUserDefaults] setObject:marketDetail forKey:strKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSUInteger) loadMarketDetail
{
    NSString* strCount = [[self loadAccountUID] stringValue];
    NSString* strKey = [NSString stringWithFormat:@"%@_marketdetail",strCount];
    NSNumber* nType = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
    if (!nType)
        nType = @(SPOT_MARKET_0);
    //else cont.
    
    return  [nType unsignedIntegerValue];
}

- (NSUInteger)loadBtcUnitType {
    
    NSString* strCount = [[self loadAccountUID] stringValue];
    NSString* strKey = [NSString stringWithFormat:@"%@_BtcUnitType",strCount];
    
    NSNumber* nType = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
    if (!nType)
        nType = @0;
    //else cont.
    
    return  [nType unsignedIntegerValue];
}
- (void)saveBtcUnitType:(NSUInteger)aType {
    
    NSNumber *nType = [NSNumber numberWithUnsignedInteger:aType];
    
    NSString* strCount = [[self loadAccountUID] stringValue];
    NSString* strKey = [NSString stringWithFormat:@"%@_BtcUnitType",strCount];
    
    [[NSUserDefaults standardUserDefaults] setObject:nType forKey:strKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSUInteger)loadLtcUnitType {
    
    NSString* strCount = [[self loadAccountUID] stringValue];
    NSString* strKey = [NSString stringWithFormat:@"%@_LtcUnitType",strCount];
    
    NSNumber* nType = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
    if (!nType)
        nType = @0;
    //else cont.
    
    return  [nType unsignedIntegerValue];
}
- (void)saveLtcUnitType:(NSUInteger)aType {
    
    NSNumber *nType = [NSNumber numberWithUnsignedInteger:aType];
    
    NSString* strCount = [[self loadAccountUID] stringValue];
    NSString* strKey = [NSString stringWithFormat:@"%@_LtcUnitType",strCount];
    [[NSUserDefaults standardUserDefaults] setObject:nType forKey:strKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - defaluts

- (void) saveSymbolType:(NSString*)aType
{
    NSString* strCount = [[self loadAccountUID] stringValue];
    strCount = strCount != nil ? strCount : @"un_user";
    NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,DEFAULTS_HUOBI_SYMBOL_TYPE];
    
    [[NSUserDefaults standardUserDefaults] setObject:aType forKey:strKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*) loadSymbolType
{
    NSString* strCount = [[self loadAccountUID] stringValue];
    strCount = strCount != nil ? strCount : @"un_user";
    NSString* symbolType = nil;
    if (strCount)
    {
        NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,DEFAULTS_HUOBI_SYMBOL_TYPE];
        symbolType = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
    }
    
    if (!symbolType)
    {
        NSArray* symbolsArray = [DLMainManager symbolsArrayOfHuobi];
        symbolType = [symbolsArray firstObject];
    }
    //else cont.

    
    return  symbolType;
}

- (void) saveBitvcSymbolType:(NSString*)aType
{
    NSString* strCount = [[self loadAccountUID] stringValue];
    strCount = strCount != nil ? strCount : @"un_user";
    NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,DEFAULTS_BITVC_SYMBOL_TYPE];
    
    [[NSUserDefaults standardUserDefaults] setObject:aType forKey:strKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*) loadBitvcSymbolType
{
    NSString* strCount = [[self loadAccountUID] stringValue];
    strCount = strCount != nil ? strCount : @"un_user";
    NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,DEFAULTS_BITVC_SYMBOL_TYPE];
    
    NSString* symbolType = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
    
    if (!symbolType)
    {
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        NSArray* symbolsArray = delegate.btcTradeCodeAry; //[DLMainManager symbolsArray];
        TradeCodeData* tradeCode = [symbolsArray firstObject];
        symbolType = tradeCode.strCode;
    }
    //else cont.
    
    return  symbolType;
}

/***********************************************************
 保存和读取退出前选择的刷新类型
 ***********************************************************/
- (void) saveMarketFlowType:(NSNumber*)aType
{
    NSString* strKey = [self userDefaultsKeyForMarketFlowType];
    [[NSUserDefaults standardUserDefaults]setValue:aType forKey:strKey withDefaultValue:[NSNumber numberWithInteger:MARKET_NORMAL]];
}

- (NSNumber*) loadMarketFlowType
{
    NSString *strKey=[self userDefaultsKeyForMarketFlowType];
    [[NSUserDefaults standardUserDefaults]setValue:nil forKey:strKey withDefaultValue:[NSNumber numberWithInteger:MARKET_NORMAL]];
    
    NSNumber* aType = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
    
    return  aType;
}

- (NSString *)userDefaultsKeyForMarketFlowType {
    NSString* strCount = [[self loadAccountUID] stringValue];
    NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,DEFAULTS_MARKETFLOW_TYPE];
    return strKey;
}


/***********************************************************
 周期类型
 ***********************************************************/

- (void) savePeriodType:(NSString*)aType
{
    NSString* strCount = [[self loadAccountUID] stringValue];
    strCount = strCount != nil ? strCount : @"un_user";
    NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"PeriodType"];
    
    [[NSUserDefaults standardUserDefaults] setObject:aType forKey:strKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*) loadPeriodType
{
    NSString* strCount = [[self loadAccountUID] stringValue];
    strCount = strCount != nil ? strCount : @"un_user";
    NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"PeriodType"];
    
    NSString* aType = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
    aType = aType == nil ? KLINE1MIN :aType;
    return  aType;
}

/***********************************************************
 账户名称
 ***********************************************************/

- (void) saveCurrentEmailOrPhone:(NSString*)strEmailOrPhone
{
    [[NSUserDefaults standardUserDefaults] setObject:strEmailOrPhone forKey:@"account"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*) loadCurrentEmailOrPhone
{
    NSString* account = [[NSUserDefaults standardUserDefaults] objectForKey:@"account"];
    //account = account != nil ? account : @"unlogin";
    return  account;
}

- (NSString*) loadAccount
{
    NSString* account = [[NSUserDefaults standardUserDefaults] objectForKey:@"account"];
    //account = account != nil ? account : @"unlogin";
    return  account;
}

/***********************************************************
 手势密码错误次数
 ***********************************************************/
- (void) saveGesturePasswordCount:(int)nCount
{
    NSString* strCount = [[self loadAccountUID] stringValue];
    if (strCount)
    {
        NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"GesutrePasswordCount"];
        
        [[NSUserDefaults standardUserDefaults] setObject:@{strCount:@(nCount)} forKey:strKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
        HB_LOG(@"error!");
}

- (int) loadGesturePassword
{
    int nResult = 0;
    NSString* strCount = [[self loadAccountUID] stringValue];
    if (strCount)
    {
        NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"GesutrePasswordCount"];
        
        NSDictionary* info = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
        if (info && [info isKindOfClass:[NSDictionary class]])
        {
            NSNumber* countNumber =  [info objectForKey:strCount];
            if (countNumber)
                nResult = [countNumber intValue];
            //else cont.
        }
        //else ocnt.
    }
    else
        HB_LOG(@"error!");
    
    return  nResult;
}


/***********************************************************
 由于keychain中的数据不会因为程序而自动删除出；
 所以需要在第一次启动的事后清空上次的记录；
 ***********************************************************/
- (void) saveShowedGuide:(int)nCount
{
    NSString* strCount = [[self loadAccountUID] stringValue];
    if (strCount)
    {
        NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"launchcount"];
        
        [[NSUserDefaults standardUserDefaults] setObject:@{strCount:@(nCount)} forKey:strKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
        HB_LOG(@"error!");
}

- (int) loadShowedGuide
{
    int nResult = 0;
    NSString* strCount = [[self loadAccountUID] stringValue];
    if (strCount)
    {
        NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"launchcount"];
        
        NSDictionary* info = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
        if (info && [info isKindOfClass:[NSDictionary class]])
        {
            NSNumber* countNumber =  [info objectForKey:strCount];
            if (countNumber)
                nResult = [countNumber intValue];
            //else cont.
        }
        //else ocnt.
    }
    else
        HB_LOG(@"error!");
    
    return  nResult;
}

- (void) saveUIDLaunchCount:(int)nCount
{
    NSString* strCount = [[self loadAccountUID] stringValue];
    if (strCount)
    {
        NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"launchcount"];
        
        [[NSUserDefaults standardUserDefaults] setObject:@{strCount:@(nCount)} forKey:strKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
        HB_LOG(@"error!");
}

- (int) loadUIDLaunchCount
{
    int nResult = 0;
    NSString* strCount = [[self loadAccountUID] stringValue];
    if (strCount)
    {
        NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"launchcount"];
        
        NSDictionary* info = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
        if (info && [info isKindOfClass:[NSDictionary class]])
        {
            NSNumber* countNumber =  [info objectForKey:strCount];
            if (countNumber)
                nResult = [countNumber intValue];
            //else cont.
        }
        //else ocnt.
    }
    else
        HB_LOG(@"error!");
    
    return  nResult;
}

/***********************************************************
 保存用户信息
 ***********************************************************/
- (void) saveBackTime:(NSTimeInterval)backTime
{
    NSString* strCount = [[self loadAccountUID] stringValue];
    if (strCount)
    {
        NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"backtime"];
        
        [[NSUserDefaults standardUserDefaults] setObject:@{strCount:@(backTime)} forKey:strKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
        HB_LOG(@"error!");
}

- (NSTimeInterval) loadBackTime
{
    NSTimeInterval nResult;
    NSString* strCount = [[self loadAccountUID] stringValue];
    if (strCount)
    {
        NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"backtime"];
        NSDictionary* info = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
        NSNumber* backTime = [info objectForKey:strCount];
        if (backTime)
            nResult = [backTime doubleValue];
        //else cont.
    }
    //else cont.
    
    return nResult;
}

/***********************************************************
 保存UID
 ***********************************************************/

- (void) saveAccountUID:(NSDictionary*)userInfo
{
    /*
     {
        authStatus = 2;
        authTypeId = 2;
        countryCode = "";
        email = "yangfuliang@huobi.com";
        fullname = "";
        id = 6813;
        messageNum = 15;
        passwordSecurityScore = 0;
        phone = "";
        status = 0;
        uid = 68134;
        username = "";
        vipLevel = 0;
     }
     */
    if (userInfo)
    {
        NSNumber* userID = [userInfo objectForKey:@"uid"];
        
        NSString* strEmail = [userInfo objectForKey:@"email"];
        if (strEmail && ![strEmail isEqualToString:@""])
        {
            NSString* strEmailUIDKey = [NSString stringWithFormat:@"%@_%@",strEmail,@"UID"];
            [[NSUserDefaults standardUserDefaults] setObject:userID forKey:strEmailUIDKey];
        }
        //else cont.

        
        NSString* strPhone = [userInfo objectForKey:@"phone"];
        if (strPhone && ![strPhone isEqualToString:@""])
        {
            NSString* strPhoneUIDKey = [NSString stringWithFormat:@"%@_%@",strPhone,@"UID"];
            [[NSUserDefaults standardUserDefaults] setObject:userID forKey:strPhoneUIDKey];
        }
        //else cont.

        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
        HB_LOG(@"error!");
}

- (NSNumber*) loadAccountUID
{
    NSString* strCount = [self loadCurrentEmailOrPhone];
    NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"UID"];
    
    NSNumber* uid = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
    if (!uid)
    {
        uid = @0;
    }
    return uid;
}

- (void) saveDetectionStatus:(NSNumber*)aStatus
{
    [[NSUserDefaults standardUserDefaults] setObject:aStatus forKey:@"DETECTION_SATUS"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSNumber*) loadDetectionStatus
{
    NSNumber* status = [[NSUserDefaults standardUserDefaults] objectForKey:@"DETECTION_SATUS"];
    if (!status)
        status = @0;
    //else cont.
    
    return status;
}

#pragma mark - 保存用户信息 -
// 用户昵称
- (void) saveUserName:(NSString*)userName
{
    if (userName && userName.length > 0) {
        NSString* strCount = [[self loadAccountUID] stringValue];
        NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"username"];
        
        [[NSUserDefaults standardUserDefaults] setObject:userName forKey:strKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
        HB_LOG(@"error!");
}

- (NSString*) loadUserName
{
    NSString* strCount = [[self loadAccountUID] stringValue];
    NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"username"];
    
    NSString* name = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
    
    return name;
}

// 用户姓名
- (void) saveFullName:(NSString*)fullName
{
    if (fullName && fullName.length > 0) {
        NSString* strCount = [[self loadAccountUID] stringValue];
        NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"fullname"];
        
        [[NSUserDefaults standardUserDefaults] setObject:fullName forKey:strKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
        HB_LOG(@"error!");
}

- (NSString*) loadFullName
{
    NSString* strCount = [[self loadAccountUID] stringValue];
    NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"fullname"];
    
    NSString* name = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
    
    return name;
}

// 手机
- (void) savePhone:(NSString*)phone
{
    if (phone && phone.length > 0) {
        NSString* strCount = [[self loadAccountUID] stringValue];
        NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"phone"];
        
        [[NSUserDefaults standardUserDefaults] setObject:phone forKey:strKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
        HB_LOG(@"error!");
}

- (NSString*) loadPhone
{
    NSString* strCount = [[self loadAccountUID] stringValue];
    NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"phone"];
    
    NSString* phone = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
    
    return phone;
}

// 积分等级
- (void) saveVipLevel:(NSNumber*)vipLevel
{
    if (vipLevel) {
        NSString* strCount = [[self loadAccountUID] stringValue];
        NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"vipLevel"];
        
        [[NSUserDefaults standardUserDefaults] setObject:vipLevel forKey:strKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
        HB_LOG(@"error!");
}

- (NSNumber*) loadVipLevel
{
    NSString* strCount = [[self loadAccountUID] stringValue];
    NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"vipLevel"];
    
    NSNumber* vipLevel = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
    
    return vipLevel;
}

// 实名认证是否通过
// 0未通过，1代表审核中，2代表已经通过
- (void) saveAuthStatus:(NSNumber*)authStatus
{
    if (authStatus) {
        NSString* strCount = [[self loadAccountUID] stringValue];
        NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"authStatus"];
        
        [[NSUserDefaults standardUserDefaults] setObject:authStatus forKey:strKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
        HB_LOG(@"error!");
}

- (NSNumber*) loadAuthStatus
{
    NSString* strCount = [[self loadAccountUID] stringValue];
    NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"authStatus"];
    
    NSNumber* authStatus = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
    
    return authStatus;
}

// 实名认证等级
- (void) saveAuthTypeId:(NSNumber*)authTypeId
{
    if (authTypeId) {
        NSString* strCount = [[self loadAccountUID] stringValue];
        NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"authTypeId"];
        
        [[NSUserDefaults standardUserDefaults] setObject:authTypeId forKey:strKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
        HB_LOG(@"error!");
}

- (NSNumber*) loadAuthTypeId
{
    NSString* strCount = [[self loadAccountUID] stringValue];
    NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"authTypeId"];
    
    NSNumber* authTypeId = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
    
    return authTypeId;
}

// 未读信息数量
- (void) saveMessageNum:(NSNumber*)messageNum
{
    if (messageNum) {
        NSString* strCount = [[self loadAccountUID] stringValue];
        NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"messageNum"];
        
        [[NSUserDefaults standardUserDefaults] setObject:messageNum forKey:strKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
        HB_LOG(@"error!");
}

- (NSNumber*) loadMessageNum
{
    NSString* strCount = [[self loadAccountUID] stringValue];
    NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"messageNum"];
    
    NSNumber* messageNum = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
    
    return messageNum;
}

// 安全等级
- (void) savePasswordSecurityScore:(NSNumber*)passwordSecurityScore
{
    if (passwordSecurityScore) {
        NSString* strCount = [[self loadAccountUID] stringValue];
        NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"passwordSecurityScore"];
        
        [[NSUserDefaults standardUserDefaults] setObject:passwordSecurityScore forKey:strKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
        HB_LOG(@"error!");
}

- (NSNumber*) loadPasswordSecurityScore
{
    NSString* strCount = [[self loadAccountUID] stringValue];
    NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"passwordSecurityScore"];
    
    NSNumber* passwordSecurityScore = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
    
    return passwordSecurityScore;
}

// 用户id，服务器里面的'user_id'
- (void) saveUserId:(NSNumber*)userId
{
    if (userId) {
        NSString* strCount = [[self loadAccountUID] stringValue];
        NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"id"];
        
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:strKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
        HB_LOG(@"error!");
}

- (NSNumber*) loadUserId
{
    NSString* strCount = [[self loadAccountUID] stringValue];
    NSString* strKey = [NSString stringWithFormat:@"%@_%@",strCount,@"id"];
    
    NSNumber* userId = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
    
    return userId;
}


#pragma mark - 主动从服务器获取的提醒，上一次弹出提示的时间
- (void) savePullMsgLastPopTime:(NSString*)time
{
    [[NSUserDefaults standardUserDefaults] setObject:time forKey:@"PullMsgLastPopTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*) loadPullMsgLastPopTime
{
    NSString* time = [[NSUserDefaults standardUserDefaults] objectForKey:@"PullMsgLastPopTime"];
    return  time;
}

#pragma mark -- 自定义的存储
- (void)saveValueAtKey:(NSString*)key value:(NSString *)value {
    
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSString*)loadValueAtKey:(NSString*)key {
    if(!key)
    {
        return @"";
    }
    NSString* value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return  value;
}

#pragma mark - 首页相关
#pragma mark -- 存储自选交易代码
- (void)saveChoosedBtcTradeCodes:(NSString*)tradeCodes {
    
    [[NSUserDefaults standardUserDefaults] setObject:tradeCodes forKey:@"ChoosedBtcTradeCodes"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSString*)loadChoosedBtcTradeCodes {
    
    NSString* choosedBtcTradeCodes = [[NSUserDefaults standardUserDefaults] objectForKey:@"ChoosedBtcTradeCodes"];
    return  choosedBtcTradeCodes;
}

- (void)saveChoosedLtcTradeCodes:(NSString*)tradeCodes {
    
    [[NSUserDefaults standardUserDefaults] setObject:tradeCodes forKey:@"ChoosedLtcTradeCodes"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSString*)loadChoosedLtcTradeCodes {
    
    NSString* choosedLtcTradeCodes = [[NSUserDefaults standardUserDefaults] objectForKey:@"ChoosedLtcTradeCodes"];
    return  choosedLtcTradeCodes;
}

#pragma mark -- 存储自选交易排序
- (void)saveChoosedBtcTradeCodesOrder:(NSString*)tradeCodes {
    
    [[NSUserDefaults standardUserDefaults] setObject:tradeCodes forKey:@"ChoosedBtcTradeCodesOrder"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSString*)loadChoosedBtcTradeCodesOrder {
    
    NSString* choosedBtcTradeCodesOrder = [[NSUserDefaults standardUserDefaults] objectForKey:@"ChoosedBtcTradeCodesOrder"];
    return  choosedBtcTradeCodesOrder;
}

- (void)saveChoosedLtcTradeCodesOrder:(NSString*)tradeCodes {
    
    [[NSUserDefaults standardUserDefaults] setObject:tradeCodes forKey:@"ChoosedLtcTradeCodesOrder"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSString*)loadChoosedLtcTradeCodesOrder {
    
    NSString* choosedLtcTradeCodesOrder = [[NSUserDefaults standardUserDefaults] objectForKey:@"ChoosedLtcTradeCodesOrder"];
    return  choosedLtcTradeCodesOrder;
}

#pragma mark -- 存储价格提醒状态
- (void)saveBtcTradeCodesPriceNoticeState:(NSString*)tradeCodes {
    
    [[NSUserDefaults standardUserDefaults] setObject:tradeCodes forKey:@"BtcTradeCodesPriceNoticeState"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSString*)loadBtcTradeCodesPriceNoticeState {
    
    NSString* choosedBtcTradeCodesOrder = [[NSUserDefaults standardUserDefaults] objectForKey:@"BtcTradeCodesPriceNoticeState"];
    return  choosedBtcTradeCodesOrder;
}

- (void)saveLtcTradeCodesPriceNoticeState:(NSString*)tradeCodes {
    
    [[NSUserDefaults standardUserDefaults] setObject:tradeCodes forKey:@"LtcTradeCodesPriceNoticeState"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSString*)loadLtcTradeCodesPriceNoticeState {
    
    NSString* choosedLtcTradeCodesOrder = [[NSUserDefaults standardUserDefaults] objectForKey:@"LtcTradeCodesPriceNoticeState"];
    return  choosedLtcTradeCodesOrder;
}

#pragma mark -- 存储参考币种
- (void)saveChoosedReferToCurrency:(NSString*)tradeCodes {
    
    [[NSUserDefaults standardUserDefaults] setObject:tradeCodes forKey:@"ChoosedReferToCurrency"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSString*)loadChoosedReferToCurrency {
    
    NSString* choosedBtcTradeCodes = [[NSUserDefaults standardUserDefaults] objectForKey:@"ChoosedReferToCurrency"];
    return  choosedBtcTradeCodes;
}

#pragma mark -- 转账账户存储
- (void)saveChoosedAccount:(NSString*)cny {
    
    [[NSUserDefaults standardUserDefaults] setObject:cny forKey:@"ChoosedAccount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)loadChoosedAccount {
    
    NSString* choosedAccount = [[NSUserDefaults standardUserDefaults] objectForKey:@"ChoosedAccount"];
    
    if (nil == choosedAccount || [choosedAccount isEqualToString:@""]) {
        
        choosedAccount = @"cny";
    }
    return  choosedAccount;
}
/***********************************************************
个推CID与APNS Device token
 ***********************************************************/
- (void)saveGetuiClientId:(NSString*)clientId
{
    [[NSUserDefaults standardUserDefaults] setObject:clientId forKey:@"GexinCid"];
}

- (void)saveAPNSDevcieToken:(NSString*)deviceToken
{
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:@"APNSDeviceToken"];
}

- (NSString*)loadGetuiClientId
{
    NSString* clientId = [[NSUserDefaults standardUserDefaults] objectForKey:@"GexinCid"];
    return clientId;
}

- (NSString*)loadAPNSDeviceToken
{
    NSString* deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"APNSDeviceToken"];
    return deviceToken;
}
/***********************************************************
 end
 ***********************************************************/

@end
