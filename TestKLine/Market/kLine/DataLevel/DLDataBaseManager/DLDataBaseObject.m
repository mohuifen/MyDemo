//
//  DLDataBaseObject.m
//  BTCTest
//
//  Created by FuYou on 14/11/26.
//  Copyright (c) 2014年 FuckYou. All rights reserved.
//  某些函数：
//  dbQueryLastKLineDataWithSql

#import "DLDataBaseObject.h"
#import <sqlite3.h>
#import "ImHBLog.h"

#import "CONFIG_CONSTAN.h"
#import "constants.h"
#import "DLDBOperation.h"

#define TABLE_KLINE_NAME @"KLine"
#define MAIN_ID @"mainid"

@interface DLDataBaseObject()
{
    sqlite3 *_db;
    NSMutableArray* _operationArray;
    dispatch_queue_t databaseQueue;
    BOOL _bBeginDemo;
}

@end

@implementation DLDataBaseObject

- (id) init
{
    self = [super init];
    if (self)
    {
        _operationArray = [[NSMutableArray alloc] initWithCapacity:6];
    }
    //else cont.
    
    return self;
}


- (void) dealloc
{
    [self suspendDataBase];
}

- (void) addOperation:(DLDBOperation*)theOperation
{
     if (_bBeginDemo)
    {
        [_operationArray addObject:theOperation];
        dispatch_sync(databaseQueue, theOperation.block);
        [_operationArray removeObject:theOperation];
    }
    //else cont.
}


#pragma mark - database

- (NSNumber*) openDataBase:(NSString*)dbPath
{
    BOOL bResult = NO;
    if (dbPath && ![dbPath isEqualToString:@""])
    {
        self.dbPath = dbPath;
        @try {
            
            if (sqlite3_open([self.dbPath UTF8String], &_db) == SQLITE_OK)
            {
                bResult = YES;
            }
            else
            {
                sqlite3_close(_db);
                HB_LOG(@"数据库打开失败");
            }
        }
        @catch (NSException *exception) {
            HB_LOG(@"");
            sqlite3_close(_db);
        }
        @finally {
        }
    }
    else
        HB_LOG(@"error!");
    
    return @(bResult);
}

- (NSNumber*) reopenDataBase
{
    BOOL bResult = NO;
    
    if (self.dbPath)
    {
        @try
        {
            sqlite3_close(_db);
            if (sqlite3_open([self.dbPath UTF8String], &_db) == SQLITE_OK)
            {
                bResult = YES;
            }
            else
            {
                sqlite3_close(_db);
                HB_LOG(@"数据库打开失败");
            }
        }
        @catch (NSException *exception) {
            HB_LOG(@"");
            sqlite3_close(_db);
        }
        @finally {
        }
    }
    //else cont.
    
    return @(bResult);
}

- (NSNumber*) closeDataBase
{
    sqlite3_close(_db);
    return @YES;
}

- (NSNumber*) deleteDataBase
{
    BOOL bResult = NO;
    if( [[NSFileManager defaultManager] fileExistsAtPath:self.dbPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:self.dbPath error:nil];
        _db = nil;
        self.dbPath = nil;
        bResult = YES;
    }
    else
        HB_LOG(@"error!");
    
    return @(bResult);
}

-(NSNumber*) execSql:(NSString *)sql
{
    BOOL bResult = NO;
    if (sql && ![sql isEqualToString:@""])
    {
        if (_db)
        {
            char *err;
            @try
            {
                int nExecCode = sqlite3_exec(_db, [sql UTF8String], NULL, NULL, &err);
                if (nExecCode == SQLITE_OK)
                    bResult = YES;
                else
                {
                    sqlite3_close(_db);
                    HB_LOG(@"数据库操作数据失败!%s",err);
                }
            }
            @catch (NSException *exception) {
                HB_LOG(@"");
                [self reopenDataBase];
            }
            @finally {
            }
        }
        else
        {
            HB_LOG(@"");
            [self reopenDataBase];
        }
    }
    else
        HB_LOG(@"error!");
    
    
    return @(bResult);
}

- (NSNumber*) createKLineTable:(NSString*)strTableName
{
    NSNumber* bResult = @NO;
    if (strTableName && ![strTableName isEqualToString:@""])
    {
        NSString *sqlCreateTable = [NSString stringWithFormat:@"CREATE  TABLE IF NOT EXISTS \"main\".\"%@\" ( \
                                    \"%@\" INTEGER PRIMARY KEY  NOT NULL  UNIQUE ,  \
                                    \"%@\" DOUBLE,                                    \
                                    \"%@\" DOUBLE,                                      \
                                    \"%@\" DOUBLE,                                     \
                                    \"%@\" DOUBLE,                                     \
                                    \"%@\" DOUBLE,                                    \
                                    \"%@\" DOUBLE,                                     \
                                    \"%@\" DOUBLE)",strTableName, TIME, AMOUNT, COUNT,PRICEHIGH,PRICELOW,PRICELAST,PRICEOPEN,VOLUME];
        
        bResult = [self execSql:sqlCreateTable];
    }
    else
        HB_LOG(@"error!");
    
    return bResult;
}

- (void) createMarketTable
{
    
}

- (void) createInformationTable
{
    
}

- (void) createPlacardTable
{
    
}


- (NSNumber*) dbInsertKLineValue:(NSDictionary*)dict
{
    BOOL bResult = NO;
    DLDBOperation* weakOperation = [dict objectForKey:@"weakObject"];
    if (weakOperation)
    {
        @try {
            NSString* strTableName = [dict objectForKey:@"TABLE"];
            NSArray* dbArray = [dict objectForKey:@"INSERTDATA"];
            
            if (strTableName && dbArray)
            {
                
                sqlite3_exec(_db, "BEGIN", 0, 0, 0);
                NSString* strDrop = [NSString stringWithFormat:@"DROP TABLE IF EXISTS main.%@",strTableName];
                [self execSql:strDrop];
                [self createKLineTable:strTableName];
                
                NSString* strSQL = nil;
                //写数据库
                for (int nIndex = 0; nIndex < [dbArray count]; nIndex++)
                {
                    if (weakOperation.cancelled)
                    {
                        return @(bResult);
                    }
                    //else cont.
                    
                    strSQL = [dbArray objectAtIndex:nIndex];
                    if (strSQL)
                        [self execSql:strSQL];
                    //else cont.
                }//endf
                
                sqlite3_exec(_db, "COMMIT", 0, 0, 0);
                
                bResult = YES;
            }
            //else cont.
        }
        @catch (NSException *exception) {
            HB_LOG(@"error!");
        }
        @finally {
            [_operationArray removeObject:weakOperation];
        }
    }
    //else cont.
    
    return @(bResult);
}

- (void) updateKLineInBackground:(NSDictionary*) pldDict
{
    _bBeginDemo = YES;
    
    NSArray* tArray = [pldDict objectForKey:TIME];
    if ([tArray count] > 0)
    {
        NSArray* amtArray = [pldDict objectForKey:AMOUNT];
        if (!amtArray) HB_LOG(@"error");
        
        NSArray* cArray = [pldDict objectForKey:COUNT];
        if (!cArray) HB_LOG(@"error");
        
        NSString* strPeriod = [pldDict objectForKey:PERIOD];
        if (!strPeriod) HB_LOG(@"error");
        
        NSArray* phArray = [pldDict objectForKey:PRICEHIGH];
        if (!phArray) HB_LOG(@"error");
        
        NSArray* plArray = [pldDict objectForKey:PRICELOW];
        if (!plArray) HB_LOG(@"error");
        
        NSArray* pltArray = [pldDict objectForKey:PRICELAST];
        if (!pltArray) HB_LOG(@"error");
        
        NSArray* poArray = [pldDict objectForKey:PRICEOPEN];
        if (!poArray) HB_LOG(@"error");
        
        NSString* strSmb = [pldDict objectForKey:SYMBOLID];
        if (!strSmb) HB_LOG(@"error");
        
        NSArray* vArray = [pldDict objectForKey:VOLUME];
        if (!vArray) HB_LOG(@"error");
        
        NSString* strTable = [NSString stringWithFormat:@"%@%@",strSmb,strPeriod];
        
        DLDBOperation* theCreateTableOP = [[DLDBOperation alloc] init];
        [theCreateTableOP setBlockWithTarget:self aSelector:@selector(createKLineTable:) argsObject:strTable];
        [self addOperation:theCreateTableOP];
        
        if (databaseQueue)
        {
            NSMutableArray* dbArray = [NSMutableArray arrayWithCapacity:[tArray count]];
            //写数据库
            for (int nIndex = 0; nIndex < [tArray count]; nIndex++)
            {
                NSNumber* valueAMOUNT       = [amtArray objectAtIndex:nIndex];
                NSNumber* valueCOUNT        = [cArray objectAtIndex:nIndex];
                NSNumber* valuePRICEHIGH    = [phArray objectAtIndex:nIndex];
                NSNumber* valuePRICELOW     = [plArray objectAtIndex:nIndex];
                NSNumber* valuePRICELAST    = [pltArray objectAtIndex:nIndex];
                NSNumber* valuePRICEOPEN    = [poArray objectAtIndex:nIndex];
                NSNumber* valueTIME         = [tArray objectAtIndex:nIndex];
                NSNumber* valueVOLUME       = [vArray objectAtIndex:nIndex];
                
                NSString *sql2 = [NSString stringWithFormat:
                                  @"REPLACE INTO '%@' ('time', 'amount', 'count', 'priceHigh', 'priceLow', 'priceLast', 'priceOpen','volume') \
                                  VALUES ('%ld', '%f', '%f', '%f', '%f', '%f', '%f', '%f')",
                                  strTable,
                                  (long)[valueTIME integerValue],
                                  [valueAMOUNT doubleValue],
                                  [valueCOUNT doubleValue],
                                  [valuePRICEHIGH doubleValue],
                                  [valuePRICELOW doubleValue],
                                  [valuePRICELAST doubleValue],
                                  [valuePRICEOPEN doubleValue],
                                  [valueVOLUME doubleValue]];
                
                
                
                [dbArray addObject:sql2];
            }//endf
            
            //theInsertOP = [theInsertOP initWithTarget:self aSelector:@selector(insertKLineValue:) argsObject:dict];
            DLDBOperation* theInsertOP = [[DLDBOperation alloc] init];
            __weak DLDBOperation* weakOperation = theInsertOP;
            NSDictionary* dict = @{@"TABLE":strTable, @"INSERTDATA":dbArray,@"weakObject":weakOperation};
            [theInsertOP setBlockWithTarget:self aSelector:@selector(dbInsertKLineValue:) argsObject:dict];
            [self addOperation:theInsertOP];
        
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATON_KLINE_UPDATE object:pldDict];
        }
        //else cont.
    }
    //else server bug.
}

#pragma mark - query data

- (NSNumber*) dbQueryMaxOrMinValueWithSql:(NSString*)sqlQuery
{
    NSNumber* numResult = @0;
    @try {
        sqlite3_stmt * statement;
        if (sqlite3_prepare_v2(_db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                numResult = @(sqlite3_column_int(statement, 0));
            }//endw
        }
        else
            HB_LOG(@"no table!");
    }
    @catch (NSException *exception) {
        HB_LOG(@"");
        [self reopenDataBase];
    }
    @finally {
    }
    return numResult;
}

- (NSInteger) queryMinValueWithKey:(NSString*)strKey ofTableName:(NSString*)tableName
{
    if (![strKey isEqualToString:TIME])
    {
        /***************************************************************
         呵呵，sqlite3_column_int返回的是NSInteger类型，不适用其他类型.
         所以想查询其他字段的同学,请自己扩展函数。
         ***************************************************************/
        assert(nil);
    }
    //else cont.
    
    NSString* sqlQuery = [NSString stringWithFormat:@"SELECT MIN(%@) FROM %@",strKey,tableName];
    
    //DLDBOperation* theCreateDB = [[DLDBOperation alloc] initWithTarget:self aSelector:@selector(dbQueryMinValueWithSql:) argsObject:sqlQuery];
    DLDBOperation* theCreateDB = [[DLDBOperation alloc] init];
    [theCreateDB setBlockWithTarget:self aSelector:@selector(dbQueryMaxOrMinValueWithSql:) argsObject:sqlQuery];
    [self addOperation:theCreateDB];
    
    return [theCreateDB.resultObject integerValue];
}

- (NSInteger) queryMaxValueWithKey:(NSString*)strKey ofTableName:(NSString*)tableName
{
    if (![strKey isEqualToString:TIME])
    {
        /***************************************************************
         呵呵，sqlite3_column_int返回的是NSInteger类型，不适用其他类型.
         所以想查询其他字段的同学,请自己扩展函数。
         ***************************************************************/
        assert(nil);
    }
    //else cont.
    
    
    NSString* sqlQuery = [NSString stringWithFormat:@"SELECT MAX(%@) FROM %@",strKey,tableName];
    //DLDBOperation* theCreateDB = [[DLDBOperation alloc] initWithTarget:self aSelector:@selector(dbQueryMinValueWithSql:) argsObject:sqlQuery];
    DLDBOperation* theCreateTableOP = [[DLDBOperation alloc] init];
    [theCreateTableOP setBlockWithTarget:self aSelector:@selector(dbQueryMaxOrMinValueWithSql:) argsObject:sqlQuery];
    [self addOperation:theCreateTableOP];
    return [theCreateTableOP.resultObject integerValue];
}

- (NSDictionary*) dbQueryKLineDataWithSql:(NSDictionary*)argsDict
{
    
    NSDictionary* dictResult = @{};
    @autoreleasepool {
        NSString* sqlQuery = [argsDict objectForKey:@"sqlString"];
        DLDBOperation* weakObject = [argsDict objectForKey:@"weakObject"];
        if (sqlQuery && weakObject)
        {
            NSMutableArray* arrayAmount = [[NSMutableArray alloc] initWithCapacity:50];
            NSMutableArray* arrayPriceHight = [[NSMutableArray alloc] initWithCapacity:50];
            NSMutableArray* arrayPriceLow = [[NSMutableArray alloc] initWithCapacity:50];
            NSMutableArray* arrayPriceLast = [[NSMutableArray alloc] initWithCapacity:50];
            NSMutableArray* arrayPriceOpen = [[NSMutableArray alloc] initWithCapacity:50];
            NSMutableArray* arrayTime = [[NSMutableArray alloc] initWithCapacity:50];
            
            @try {
                sqlite3_stmt * statement;
                int nErrorCode = sqlite3_prepare_v2(_db, [sqlQuery UTF8String], -1, &statement, nil);
                if (nErrorCode == SQLITE_OK)
                {
                    while (sqlite3_step(statement) == SQLITE_ROW) {
                        
                        if (weakObject.cancelled)
                            return dictResult;
                        //else cont.
                        
                        [arrayAmount addObject:@(sqlite3_column_double(statement, 0))];
                        [arrayPriceHight addObject:@(sqlite3_column_double(statement, 1))];
                        [arrayPriceLow addObject:@(sqlite3_column_double(statement, 2))];
                        [arrayPriceLast addObject:@(sqlite3_column_double(statement, 3))];
                        [arrayPriceOpen addObject:@(sqlite3_column_double(statement, 4))];
                        [arrayTime addObject: @(sqlite3_column_int(statement, 5))];
                    }//endw
                    dictResult = @{AMOUNT:arrayAmount, PRICEHIGH:arrayPriceHight,PRICELOW:arrayPriceLow,PRICELAST:arrayPriceLast,PRICEOPEN:arrayPriceOpen,TIME:arrayTime};
                    
                }
                //else 第一次启动时，可能会因为还没有创建是数据库而进入这个分支。
            }
            @catch (NSException *exception) {
                HB_LOG(@"");
                [self reopenDataBase];
            }
            @finally {
            }
        }
        
    }//end auto
    return dictResult;
}


- (NSDictionary*) queryLastKLineArrayWithDictionary:(NSDictionary*)argsDict ofTableName:(NSString*)tableName
{
    //解析数据
    //NSArray *nResult = nil;
    NSString* strFrom = [argsDict objectForKey:FROM];
    NSString* strTo = [argsDict objectForKey:TO];
    NSString *sqlQuery = nil;
    if ([strFrom integerValue] < 0)
    {
        NSString* strDataCount = [argsDict objectForKey:@"dataCount"];
        sqlQuery = [NSString stringWithFormat:@"SELECT * FROM (SELECT amount,priceHigh,priceLow,priceLast,priceOpen,time FROM %@ ORDER BY TIME DESC LIMIT %@) ORDER BY TIME",
                    tableName,
                    strDataCount];
    }
    else
    {
        sqlQuery = [NSString stringWithFormat:@"SELECT amount,priceHigh,priceLow,priceLast,priceOpen,time FROM %@ WHERE time >= '%@' and time <='%@'",
                    tableName,
                    strFrom,
                    strTo];
    }//endi
    
    //DLDBOperation* theCreateDB = [[DLDBOperation alloc] initWithTarget:self aSelector:@selector(dbQueryKLineDataWithSql:) argsObject:sqlQuery];
    DLDBOperation* theCreateTableOP = [[DLDBOperation alloc] init];
    __weak DLDBOperation* weakOperation = theCreateTableOP;
    NSDictionary* dict = @{@"sqlString":sqlQuery, @"weakObject":weakOperation};
    [theCreateTableOP setBlockWithTarget:self aSelector:@selector(dbQueryKLineDataWithSql:) argsObject:dict];
    [self addOperation:theCreateTableOP];
    return theCreateTableOP.resultObject;
}

- (NSDictionary*) dbQueryLastKLineDataWithSql:(NSDictionary*)argsDict
{
    NSDictionary* dictResult = @{};
    NSString* sqlQuery = [argsDict objectForKey:@"sqlString"];
    DLDBOperation* weakObject = [argsDict objectForKey:@"weakObject"];
    if (sqlQuery && weakObject)
    {
        @try {
            sqlite3_stmt * statement;
            if (sqlite3_prepare_v2(_db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK)
            {
                NSMutableArray* arrayValue0 = [[NSMutableArray alloc] initWithCapacity:50];
                NSMutableArray* arrayValue1 = [[NSMutableArray alloc] initWithCapacity:50];
                NSMutableArray* arrayValue2 = [[NSMutableArray alloc] initWithCapacity:50];
                NSMutableArray* arrayTime = [[NSMutableArray alloc] initWithCapacity:50];
                NSMutableArray* arrayAmount = [[NSMutableArray alloc] initWithCapacity:50];
                
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    
                    if (weakObject.cancelled)
                        return dictResult;
                    //else cont.
                    
                    char *value0 = (char*)sqlite3_column_text(statement, 0);
                    NSString *strValue0 = [[NSString alloc]initWithUTF8String:value0];
                    [arrayValue0 addObject:strValue0];
                    
                    char *value1 = (char*)sqlite3_column_text(statement, 1);
                    NSString *strValue1 = [[NSString alloc]initWithUTF8String:value1];
                    [arrayValue1 addObject:strValue1];
                    
                    char *value2 = (char*)sqlite3_column_text(statement, 2);
                    NSString *strValue2 = [[NSString alloc]initWithUTF8String:value2];
                    [arrayValue2 addObject:strValue2];
                    
                    int time = sqlite3_column_int(statement, 3);
                    [arrayTime addObject:@(time)];
                    
                    int amount = sqlite3_column_int(statement, 4);
                    [arrayAmount addObject:@(amount)];
                }//endw
                
                dictResult = @{PRICELOW:arrayValue0, PRICEHIGH:arrayValue1, PRICELAST:arrayValue2, TIME:arrayTime, AMOUNT:arrayAmount};
            }
            else
                HB_LOG(@"error!");
        }
        @catch (NSException *exception) {
            HB_LOG(@"");
            [self reopenDataBase];
        }
        @finally {
            
        }
    }
    //else cont.
    

    return dictResult;
}

- (NSDictionary*) queryLastKLineValue:(NSString*)strType withDictionary:(NSDictionary*)argsDict ofTableName:(NSString*)tableName
{
    //解析数据
    __block NSDictionary* dictResult = Nil;
    NSString *sqlQuery = nil;
    NSString* strDataCount = [argsDict objectForKey:@"dataCount"];
    sqlQuery = [NSString stringWithFormat:@"SELECT * FROM (SELECT %@,%@,%@,%@,%@ FROM %@ ORDER BY TIME DESC LIMIT %@) ORDER BY TIME",
                PRICELOW,
                PRICEHIGH,
                PRICELAST,
                TIME,
                AMOUNT,
                tableName,
                strDataCount];
    
    DLDBOperation* theQueryOP = [[DLDBOperation alloc] init];
    __weak DLDBOperation* weakOperation = theQueryOP;
    NSDictionary* dict = @{@"sqlString":sqlQuery, @"weakObject":weakOperation};
    [theQueryOP setBlockWithTarget:self aSelector:@selector(dbQueryLastKLineDataWithSql:) argsObject:dict];
    [self addOperation:theQueryOP];
    dictResult = theQueryOP.resultObject;
    return dictResult;
}

#pragma mark - json data
- (void) updateLastKLine:(NSDictionary*) jsonData
{
    @autoreleasepool {
        if(jsonData)
        {
            NSDictionary* pldDict = [jsonData objectForKey:PAYLOAD];
            if (pldDict)
            {
                NSNumber* valueAMOUNT = [pldDict objectForKey:AMOUNT];
                NSNumber* valueCOUNT = [pldDict objectForKey:COUNT];
                NSString* strPeriod = [pldDict objectForKey:PERIOD];
                
                NSNumber* valuePRICEHIGH = [pldDict objectForKey:PRICEHIGH];
                NSNumber* valuePRICELOW = [pldDict objectForKey:PRICELOW];
                NSNumber* valuePRICELAST = [pldDict objectForKey:PRICELAST];
                NSNumber* valuePRICEOPEN = [pldDict objectForKey:PRICEOPEN];
                NSString* strSmb = [pldDict objectForKey:SYMBOLID];
                NSNumber* valueTIME = [pldDict objectForKey:TIME];
                NSNumber* valueVOLUME = [pldDict objectForKey:VOLUME];
                
                NSString* strTable = [NSString stringWithFormat:@"%@%@",strSmb,strPeriod];
                
                NSArray* valueArray = @[valueTIME,
                                        valueAMOUNT,
                                        valueCOUNT,
                                        valuePRICEHIGH,
                                        valuePRICELOW,
                                        valuePRICELAST,
                                        valuePRICEOPEN,
                                        valueVOLUME];
                
                NSString *sql2 = [NSString stringWithFormat:
                                  @"REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@') \
                                  VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')",
                                  strTable,TIME,AMOUNT, COUNT, PRICEHIGH,PRICELOW, PRICELAST, PRICEOPEN,VOLUME,
                                  [valueArray objectAtIndex:0],
                                  [valueArray objectAtIndex:1],
                                  [valueArray objectAtIndex:2],
                                  [valueArray objectAtIndex:3],
                                  [valueArray objectAtIndex:4],
                                  [valueArray objectAtIndex:5],
                                  [valueArray objectAtIndex:6],
                                  [valueArray objectAtIndex:7]];
                
                DLDBOperation* theInsertOP = [[DLDBOperation alloc] init];
                [theInsertOP setBlockWithTarget:self aSelector:@selector(execSql:) argsObject:sql2];
                [self addOperation:theInsertOP];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATON_LSAT_KLINE_UPDATE object:pldDict];
            }
            else
                HB_LOG(@"error!");
        }
        else
            HB_LOG(@"error!");
    }//end autopool
}

#pragma mark - const

- (void) restartDataBase
{
    if (!databaseQueue)
    {
        databaseQueue = dispatch_queue_create("databaseQueue",DISPATCH_QUEUE_SERIAL);
    }
    else
        dispatch_resume(databaseQueue);
    
    if (!_operationArray) {
        _operationArray = [NSMutableArray arrayWithCapacity:10];
    }
    //else cont.
    
    DLDBOperation* theCreateDB = [[DLDBOperation alloc] initWithTarget:self aSelector:@selector(reopenDataBase) argsObject:nil];
    [_operationArray addObject:theCreateDB];
    dispatch_sync(databaseQueue, theCreateDB.block);
    [_operationArray removeObject:theCreateDB];
}

- (void) suspendDataBase
{
    if (_operationArray)
    {
        for (DLDBOperation* theCreateDB in _operationArray)
        {
            theCreateDB.cancelled = YES;
        }//endf
        
        DLDBOperation* theCreateDB = [[DLDBOperation alloc] initWithTarget:self aSelector:@selector(closeDataBase) argsObject:nil];
        [self addOperation:theCreateDB];
        
        dispatch_suspend(databaseQueue);
        [_operationArray removeAllObjects];
        _operationArray = nil;
    }
    //else cont.
    
    _bBeginDemo = NO;
}
@end
