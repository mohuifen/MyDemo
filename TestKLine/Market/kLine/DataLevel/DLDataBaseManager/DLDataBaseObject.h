//
//  DLDataBaseObject.h
//  BTCTest
//
//  Created by FuYou on 14/11/26.
//  Copyright (c) 2014年 FuckYou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLDataBaseObject : NSObject

@property (nonatomic,copy) NSString* dbPath;

- (NSNumber*) openDataBase:(NSString*)dbPath;

- (NSNumber*) closeDataBase;

- (NSNumber*) deleteDataBase;

- (NSNumber*) execSql:(NSString *)sql;

- (NSNumber*) createKLineTable:(NSString*)strTableName;

- (NSNumber*) dbInsertKLineValue:(NSDictionary*)dict;

- (NSNumber*) dbQueryMaxOrMinValueWithSql:(NSString*)sqlQuery;

- (void) updateKLineInBackground:(NSDictionary*) pldDict;

#pragma mark - data base

- (void) restartDataBase;

- (void) suspendDataBase;

- (NSInteger) queryMinValueWithKey:(NSString*)strKey ofTableName:(NSString*)tableName;

- (NSInteger) queryMaxValueWithKey:(NSString*)strKey ofTableName:(NSString*)tableName;

- (NSDictionary*) dbQueryKLineDataWithSql:(NSDictionary*)argsDict;

- (NSDictionary*) queryLastKLineArrayWithDictionary:(NSDictionary*)argsDict ofTableName:(NSString*)tableName;

- (NSDictionary*) dbQueryLastKLineDataWithSql:(NSDictionary*)argsDict;

- (NSDictionary*) queryLastKLineValue:(NSString*)strType withDictionary:(NSDictionary*)argsDict ofTableName:(NSString*)tableName;

- (void) updateLastKLine:(NSDictionary*) jsonData;
@end
