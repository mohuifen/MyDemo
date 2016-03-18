//
//  TradeCodeData.h
//  BitVCProject
//
//  Created by 张仓阁 on 14/12/6.
//  Copyright (c) 2014年 Huobi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface TradeCodeData : NSObject

@property BOOL isPriceNoticeOn;
@property CGFloat fHighNotice;
@property CGFloat fLowNotice;
@property BOOL isOld;
@property NSInteger nIndex;
@property BOOL isSelected;
@property (strong, nonatomic) NSString *strCode;
@property (strong, nonatomic) NSString *strContractType;
@property (strong, nonatomic) NSString *strContractName;
@property (strong, nonatomic) NSString *strName;
@property (strong, nonatomic) NSMutableArray *aryLeverage;
@property NSInteger nLever;
@property int coinType;
@property (strong, nonatomic) NSString *isHuobi;
@property BOOL isFutures;
@property (strong, nonatomic) NSString *strFastQuotation;
@property (strong, nonatomic) NSString *strSlowQuotation;
@property (strong, nonatomic) NSString *strCurrency;
@property (strong, nonatomic) NSString *strCurrency2;

@property (strong, nonatomic) NSString *strMarketId;
@property (strong, nonatomic) NSString *strMarketName;
@property (strong, nonatomic) NSString *strTradeName;

@end
