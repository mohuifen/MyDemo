//
//  DLDataBaseManager.h
//  BTCTest
//
//  Created by FuYou on 14/11/25.
//  Copyright (c) 2014年 FuckYou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLDataBaseManager : NSObject
- (void) restartManager;

- (void) suspendManager;

- (NSInteger) queryMinValueWithKey:(NSString*)strKey ofTableName:(NSString*)tableName;

- (NSInteger) queryMaxValueWithKey:(NSString*)strKey ofTableName:(NSString*)tableName;

- (NSDictionary*) dbQueryKLineDataWithSql:(NSDictionary*)argsDict;

- (NSDictionary*) queryLastKLineArrayWithDictionary:(NSDictionary*)argsDict ofTableName:(NSString*)tableName;

- (NSDictionary*) dbQueryLastKLineDataWithSql:(NSDictionary*)argsDict;

- (NSDictionary*) queryLastKLineValue:(NSString*)strType withDictionary:(NSDictionary*)argsDict ofTableName:(NSString*)tableName;

#pragma mark - update
- (void) updateMarketDetail:(NSDictionary*) jsonData localUpdate:(BOOL)bLocalUpdate;

- (void) updateMarketOverview:(NSDictionary*) jsonData localUpdate:(BOOL)bLocalUpdate;

- (void) updateLastKLine:(NSDictionary*) jsonData;

- (void) updateKLine:(NSDictionary*) pldDict localUpdate:(BOOL)bLocalUpdate;

- (void) updateMarketDepthTopShort:(NSDictionary*) pldDict localUpdate:(BOOL)bLocalUpdate;
@end
