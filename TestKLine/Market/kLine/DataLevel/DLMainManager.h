//
//  DLMainManager.h
//  BtcDemo
//
//  Created by FuYou on 14/11/21.
//  Copyright (c) 2014年 FuckYou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TradeCodeData.h"
#import "ImHBLog.h"

typedef NS_ENUM(NSInteger, E_MARKET_STATUS)
{
    MARKET_NORMAL = 1,
    MARKET_REALTIME,
    MARKET_REALTIME_ONLY_WIFI
};

@interface DLMainManager : NSObject

+ (id) sharedMainManager;

+ (id) sharedNetWorkManager;

+ (id) sharedDBManager;

+ (id) sharedTextAttributeData;

+(id) toArrayOrDictionary:(NSData*)jsonData;

#pragma mark - data

+ (NSArray*) symbolsArrayOfHuobi;

+ (NSArray*) periodsArray;

- (NSUInteger) loadCoinType;

- (void) saveCoinType:(NSUInteger)aType;

- (NSUInteger)loadBtcUnitType;
- (void)saveBtcUnitType:(NSUInteger)aType;

- (NSUInteger)loadLtcUnitType;
- (void)saveLtcUnitType:(NSUInteger)aType;

#pragma mark - default

- (NSString*) loadSymbolType;

- (void) saveSymbolType:(NSString*)aType;

- (NSString*) loadBitvcSymbolType;

- (void) saveBitvcSymbolType:(NSString*)aType;

/***********************************************************
 保存和读取退出前选择的刷新类型
 ***********************************************************/
- (void) saveMarketFlowType:(NSNumber*)aType;

- (NSNumber*) loadMarketFlowType;

/***********************************************************
 周期类型
 ***********************************************************/
- (void) savePeriodType:(NSString*)aType;

- (NSString*) loadPeriodType;

/***********************************************************
 账户名称
 ***********************************************************/
- (void) saveCurrentEmailOrPhone:(NSString*)strEmailOrPhone;

- (NSString*) loadCurrentEmailOrPhone;

- (NSString*) loadAccount;

/***********************************************************
 手势密码错误次数
 ***********************************************************/
- (void) saveGesturePasswordCount:(int)nCount;

- (int) loadGesturePassword;

/***********************************************************
 由于keychain中的数据不会因为程序而自动删除出；
 所以需要在第一次启动的事后清空上次的记录；
 ***********************************************************/
- (void) saveUIDLaunchCount:(int)nCount;

- (int) loadUIDLaunchCount;

- (void) saveShowedGuide:(int)nCount;

- (int) loadShowedGuide;

/***********************************************************
 保存UID
 ***********************************************************/

- (void) saveAccountUID:(NSDictionary*)userInfo;

- (NSNumber*) loadAccountUID;

/***********************************************************
 保存用户信息
 ***********************************************************/
- (void) saveBackTime:(NSTimeInterval)backTime;

- (NSTimeInterval) loadBackTime;

/***********************************************************
 保存用户信息
 ***********************************************************/

// 用户昵称
- (void) saveUserName:(NSString*)userName;

- (NSString*) loadUserName;


// 用户姓名
- (void) saveFullName:(NSString*)fullName;

- (NSString*) loadFullName;

// 手机
- (void) savePhone:(NSString*)phone;

- (NSString*) loadPhone;

// 积分等级
- (void) saveVipLevel:(NSNumber*)vipLevel;

- (NSNumber*) loadVipLevel;

// 实名认证是否通过
// 0未通过，1代表审核中，2代表已经通过
- (void) saveAuthStatus:(NSNumber*)authStatus;

- (NSNumber*) loadAuthStatus;

// 实名认证等级
- (void) saveAuthTypeId:(NSNumber*)authTypeId;

- (NSNumber*) loadAuthTypeId;

// 未读信息数量
- (void) saveMessageNum:(NSNumber*)msgNum;

- (NSNumber*) loadMessageNum;

// 安全等级
- (void) savePasswordSecurityScore:(NSNumber*)passwordSecurityScore;

- (NSNumber*) loadPasswordSecurityScore;

// 用户id，服务器里面的'user_id'
- (void) saveUserId:(NSNumber*)userId;

- (NSNumber*) loadUserId;
/***********************************************************
 个推CID与APNS Device token
 ***********************************************************/
- (void)saveGetuiClientId:(NSString*)clientId;

- (void)saveAPNSDevcieToken:(NSString*)deviceToken;

- (NSString*)loadGetuiClientId;

- (NSString*)loadAPNSDeviceToken;
/***********************************************************
 end
 ***********************************************************/


#pragma mark - 主动从服务器获取的提醒，上一次弹出提示的时间
- (void) savePullMsgLastPopTime:(NSString*)account;

- (NSString*) loadPullMsgLastPopTime;

#pragma mark -- 自定义的存储
- (void)saveValueAtKey:(NSString*)key value:(NSString *)value;
- (NSString*)loadValueAtKey:(NSString*)key;

#pragma mark - 首页相关
#pragma mark -- 存储自选交易代码
- (void)saveChoosedBtcTradeCodes:(NSString*)tradeCodes;
- (NSString*)loadChoosedBtcTradeCodes;

- (void)saveChoosedLtcTradeCodes:(NSString*)tradeCodes;
- (NSString*)loadChoosedLtcTradeCodes;

#pragma mark -- 存储自选交易排序
- (void)saveChoosedBtcTradeCodesOrder:(NSString*)tradeCodes;
- (NSString*)loadChoosedBtcTradeCodesOrder;

- (void)saveChoosedLtcTradeCodesOrder:(NSString*)tradeCodes;
- (NSString*)loadChoosedLtcTradeCodesOrder;

#pragma mark -- 存储价格提醒状态
- (void)saveBtcTradeCodesPriceNoticeState:(NSString*)tradeCodes;
- (NSString*)loadBtcTradeCodesPriceNoticeState;

- (void)saveLtcTradeCodesPriceNoticeState:(NSString*)tradeCodes;
- (NSString*)loadLtcTradeCodesPriceNoticeState;

#pragma mark -- 存储参考币种
- (void)saveChoosedReferToCurrency:(NSString*)tradeCodes;
- (NSString*)loadChoosedReferToCurrency;

#pragma mark -- 转账账户存储
- (void)saveChoosedAccount:(NSString*)cny;
- (NSString*)loadChoosedAccount;

- (void) saveDetectionStatus:(NSNumber*)aStatus;
- (NSNumber*) loadDetectionStatus;

+ (TradeCodeData*) getTradeCodeData:(NSString*)strCode;

- (NSUInteger) loadSpotCoinType;

- (void) saveSpotCoinType:(NSUInteger)aType;

- (void) saveMarketDetail:(NSNumber*)marketDetail;

- (NSUInteger) loadMarketDetail;
@end
