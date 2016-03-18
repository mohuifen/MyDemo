//
//  DLDataBaseManager.m
//  BTCTest
//
//  Created by FuYou on 14/11/25.
//  Copyright (c) 2014年 FuckYou. All rights reserved.
//

#import "DLDataBaseManager.h"
#import "ImHBLog.h"
#import "DLDataBaseObject.h"

#import "KlineConstant.h"

#define DBNAME @"ZCGHD"

@interface DLDataBaseManager()
{
    DLDataBaseObject* _dbObject;
    
    NSMutableDictionary* _marketDepthTopShortDict;
    NSMutableDictionary* _marketOverDict;
}

@end

@implementation DLDataBaseManager
- (id) init
{
    self = [super init];
    if (self)
    {
        _marketDepthTopShortDict = [[NSMutableDictionary alloc] init];
        _marketOverDict = [[NSMutableDictionary alloc] init];
        
        _dbObject = [[DLDataBaseObject alloc] init];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documents = [paths objectAtIndex:0];
        NSString *database_path = [documents stringByAppendingPathComponent:DBNAME];
        _dbObject.dbPath = database_path;
        [_dbObject restartDataBase];
    }
    //else cont.
    
    return self;
}

- (void) restartManager
{
    [_dbObject restartDataBase];
    
    _marketDepthTopShortDict = [[NSMutableDictionary alloc] init];
    _marketOverDict = [[NSMutableDictionary alloc] init];
}

- (void) suspendManager
{
    
    if (_marketOverDict)
    {
        _marketOverDict = nil;
    }
    //else cont.
    
    if (_marketDepthTopShortDict)
    {
        _marketDepthTopShortDict = nil;
    }
    //else cont.
    
    [_dbObject suspendDataBase];
}

- (void) dealloc
{

}

#pragma mark - json data

- (void) updateMarketDetail:(NSDictionary*) jsonData localUpdate:(BOOL)bLocalUpdate
{
    if (bLocalUpdate)
    {
        
    }
    else
    {
        NSString* strSymbolId = [jsonData objectForKey:SYMBOLID];
        [_marketOverDict setObject:jsonData forKey:strSymbolId];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATON_MARKET_DETAIL_UPDATE object:jsonData];
    }
}

- (void) updateMarketOverview:(NSDictionary*) jsonData localUpdate:(BOOL)bLocalUpdate
{
    if (bLocalUpdate)
    {
        if (!jsonData)
            return;
        
        NSDictionary* symbolDict = [jsonData objectForKey:@"symbolList"];
        if (!symbolDict)
            return;
        
        NSArray* symbolArray = [symbolDict objectForKey:MARKETOVERVIEW];
        if (!symbolArray)
            return;
        
        NSDictionary* tempDict = [symbolArray firstObject];
        if (!tempDict)
            return;
        
        NSString* strSmbKey = [tempDict objectForKey:SYMBOLID];
        if (!strSmbKey)
            return;
        
        NSDictionary* dictResult = [_marketOverDict objectForKey:strSmbKey];
        if (!dictResult)
            dictResult = [NSDictionary dictionary];
        //else 未请求过此类型的数据；
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATON_MARKET_OVERVIEW_UPDATE object:dictResult];
    }
    else
    {
        NSString* strSymbolId = [jsonData objectForKey:SYMBOLID];
        [_marketOverDict setObject:jsonData forKey:strSymbolId];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATON_MARKET_OVERVIEW_UPDATE object:jsonData];
    }//endi
}

- (void) updateMarketDepthTopShort:(NSDictionary*) pldDict localUpdate:(BOOL)bLocalUpdate
{
    if (bLocalUpdate)
    {
        if (!pldDict)
            return;
        
        NSDictionary* symbolDict = [pldDict objectForKey:@"symbolList"];
        if (!symbolDict)
            return;
        
        NSArray* symbolArray = [symbolDict objectForKey:MARKETDEPTHTOPSHORT];
        if (!symbolArray)
            return;
        NSDictionary* tempDict = [symbolArray firstObject];
        if (!tempDict)
            return;
        
        NSString* strSmbKey = [tempDict objectForKey:SYMBOLID];
        if (!strSmbKey)
            return;
        
        NSDictionary* localDict = [_marketDepthTopShortDict objectForKey:strSmbKey];
        if (localDict)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATON_MARKETDEPTHTOPSHORT_UPDATE object:localDict];
        }
        //else 未请求过此类型的数据；
    }
    else
    {
        NSString* strSmb = [pldDict objectForKey:SYMBOLID];
        [_marketDepthTopShortDict setObject:pldDict forKey:strSmb];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATON_MARKETDEPTHTOPSHORT_UPDATE object:pldDict];
    }//endi
}

#pragma mark - kline

- (void) updateKLine:(NSDictionary*) pldDict localUpdate:(BOOL)bLocalUpdate
{
    /********************************************
     amt    成交量
     c      交易次数
     pd     k线周期
     ph     最高价
     pl     最低价
     plt    收盘价
     po     开盘价
     smb    交易代码
     t      时间
     v      成交额
     rc     返回代码
     rm     返回消息
     ver    协议版本号
     ********************************************/
    
    if (bLocalUpdate)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATON_KLINE_UPDATE_LOCAL object:pldDict];
    }
    else if (pldDict)
    {
        [_dbObject updateKLineInBackground:pldDict];
    }
    else
        HB_LOG(@"error!");
}

- (NSInteger) queryMinValueWithKey:(NSString*)strKey ofTableName:(NSString*)tableName
{
    return [_dbObject queryMinValueWithKey:strKey ofTableName:tableName];
}

- (NSInteger) queryMaxValueWithKey:(NSString*)strKey ofTableName:(NSString*)tableName
{
    return [_dbObject queryMaxValueWithKey:strKey ofTableName:tableName];
}

- (NSDictionary*) dbQueryKLineDataWithSql:(NSDictionary*)argsDict
{
    return [_dbObject dbQueryKLineDataWithSql:argsDict];
}

- (NSDictionary*) queryLastKLineArrayWithDictionary:(NSDictionary*)argsDict ofTableName:(NSString*)tableName
{
    return [_dbObject queryLastKLineArrayWithDictionary:argsDict ofTableName:tableName];
}

- (NSDictionary*) dbQueryLastKLineDataWithSql:(NSDictionary*)argsDict
{
    return [_dbObject dbQueryLastKLineDataWithSql:argsDict];
}

- (NSDictionary*) queryLastKLineValue:(NSString*)strType withDictionary:(NSDictionary*)argsDict ofTableName:(NSString*)tableName
{
    return [_dbObject queryLastKLineValue:strType withDictionary:argsDict ofTableName:tableName];
}

- (void) updateLastKLine:(NSDictionary*) jsonData
{
    [_dbObject updateLastKLine:jsonData];
}
@end
