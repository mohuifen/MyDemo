//
//  ImKLineData.m
//  Kline
//
//  Created by zhaomingxi on 14-2-10.
//  Copyright (c) 2014年 zhaomingxi. All rights reserved.
//

#import "ImKLineData.h"
//#import "commond.h"
#import "DLMainManager.h"
//#import "CONFIG_CONSTAN.h"
#import "ImKLineLandScapeView.h"
#import "DLDataBaseManager.h"
#import "DLNetWorkManager.h"
#import "KlineConstant.h"
#import "ImHBLog.h"
#import "ImKDJObject.h"
#import "ImRSIObject.h"
#import "ImWRObject.h"
@interface ImKLineData ()
{
    NSInteger _nCurrentBegin;
    NSInteger _nCurrentEnd;
    NSInteger _nAverageCount;
    BOOL _bRequestingNextKLine;
    BOOL _bTimeLine;
    NSDateFormatter* _timeDateFormatter;
}

@property (nonatomic,retain) NSString* keyPeriod;
@property (nonatomic,retain) NSString* keySymbolid;
@end

@implementation ImKLineData

-(id)init{
    self = [super init];
    if (self){
        
        [self resetMaxAndMinValue];
        
        _nCurrentBegin = -1;
        _nCurrentEnd = -1;
        _bRequestingNextKLine = YES;
    
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(onKLineViewUpdated:) name:NOTIFICATON_KLINE_VIEW_UPDATE object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(onLastKLineUpdated:) name:NOTIFICATON_LSAT_KLINE_VIEW_UPDATE object:nil];
        
        _timeDateFormatter = [[NSDateFormatter alloc] init];
        [_timeDateFormatter setDateFormat:@"HH:mm"];
        
    }
    return  self;
}

- (void) resetMaxAndMinValue
{
    self.maxValue = 0;
    self.minValue = CGFLOAT_MAX;
    self.amountMaxValue = 0;
    self.amountMinValue = CGFLOAT_MAX;
    self.MACDMaxValue = 0;
    self.MACDMinValue = CGFLOAT_MAX;
    
    self.bollMaxValue = 0;
    self.bollMinValue = CGFLOAT_MAX;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATON_KLINE_VIEW_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATON_LSAT_KLINE_VIEW_UPDATE object:nil];
}


- (BOOL) initKLineDataWithBeginTime:(NSInteger)nBeginTime updatePeriod:(NSString*)updatePeriod symbolid:(NSString*)updateSymbolid
{
    BOOL bResult = NO;
    _bRequestingNextKLine = NO;
    
    NSString* strTable = [NSString stringWithFormat:@"%@%@",updateSymbolid,updatePeriod];
    NSDictionary* dataDiction = nil;
    //生成请求参数
    if (nBeginTime < 0)
    {
        NSString *strBeginTime = [@(-1) stringValue];
        NSString *strEndTime = [@0 stringValue];
        NSString *strDataCount = [@(self.kCount + _nAverageCount) stringValue];
        NSDictionary* argsDict = @{PERIOD:self.keyPeriod,SYMBOLID:self.keySymbolid,FROM:strBeginTime, TO:strEndTime,@"dataCount":strDataCount};
        dataDiction = [[DLMainManager sharedDBManager] queryLastKLineArrayWithDictionary:argsDict ofTableName:strTable];
        
        NSInteger dataCount = _nAverageCount > self.kCount ? _nAverageCount : self.kCount;
        //解析数据
        NSArray* timeArray = [dataDiction objectForKey:TIME];
        NSInteger nBeginIndex = 0;
        
        if (timeArray && [timeArray count] > 0)
        {
            //将开始的index定位在能够显示的第一个Index上
            nBeginIndex = [timeArray count] - dataCount;
            
            BOOL bTimeLine = [self isTimeLine];
            if (bTimeLine)
                bResult = [self updateTimeLineWithDict:dataDiction fromIndex:nBeginIndex];
            else
                bResult = [self updateKLineWithDict:dataDiction fromIndex:nBeginIndex];
        }
        //else 第一次启动没有数据
    }
    else
    {
        NSString *strBeginTime = [@(nBeginTime) stringValue];
        NSInteger endTime = nBeginTime + (self.kCount) * [self getIntervalOfPeriod:self.keyPeriod];
        
        NSString *strEndTime = [@(endTime) stringValue];
        NSDictionary* argsDict = @{PERIOD:self.keyPeriod,SYMBOLID:self.keySymbolid,FROM:strBeginTime, TO:strEndTime};
        dataDiction = [[DLMainManager sharedDBManager] queryLastKLineArrayWithDictionary:argsDict ofTableName:strTable];
        
        //解析数据
        NSArray* timeArray = [dataDiction objectForKey:TIME];
        if (timeArray)
        {
            NSInteger nBeginIndex = 0;
            nBeginIndex = [timeArray indexOfObject:@(nBeginTime)];
            if (nBeginIndex != NSNotFound)
            {
                //将开始的index定位在能够显示的第一个Index上
                NSInteger dataCount = _nAverageCount < self.kCount ? _nAverageCount : self.kCount;
                nBeginIndex += dataCount;
                BOOL bTimeLine = [self isTimeLine];
                if (bTimeLine)
                    bResult = [self updateTimeLineWithDict:dataDiction fromIndex:nBeginIndex];
                else
                    bResult = [self updateKLineWithDict:dataDiction fromIndex:nBeginIndex];
            }
            else
                HB_LOG(@"error!");
        }
        else
            HB_LOG(@"error!");
    }//endi

    return bResult;
}
#pragma mark - summmary

-(CGFloat)sumArrayWithData:(NSArray*)data andRange:(NSRange)range{
    CGFloat value = 0;
    if (data.count - range.location >= range.length) {
        NSArray *newArray = [data objectsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:range]];
        for (NSString *item in newArray) {
            value += [item doubleValue];
        }
        if (value>0) {
            value = value / newArray.count;
        }
    }
    else
        HB_LOG(@"error!");
    return value;
}

- (CGFloat) getSTDWithData:(NSArray*)data andRange:(NSRange)range
{
    CGFloat summary = [self sumArrayWithData:data andRange:range];
    CGFloat value = 0;
    if (data.count - range.location >= range.length) {
        NSArray *newArray = [data objectsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:range]];
        for (NSString *item in newArray)
        {
            CGFloat value1 = [item doubleValue] - summary;
            value += powf(value1,2);
        }
        if (value > 0) {
            value = value / range.length;
            value = sqrt(value);
        }
    }
    else
        HB_LOG(@"error!");
    return value;
}

- (CGFloat) emaWithData:(NSArray*)data nLargeBegin:(NSUInteger)nLargeBegin nCount:(NSUInteger)nCount
{
    CGFloat bResult = 0;
    if (nLargeBegin < [data count])
    {
        CGFloat x = [[data objectAtIndex:nLargeBegin] doubleValue];
        if (nCount > 0)
        {
            CGFloat preY = 0;
            if (nLargeBegin > 0)
                preY = [self emaWithData:data nLargeBegin:nLargeBegin - 1 nCount:nCount - 1];
            //else 递归结束，递归到最里层了。

            bResult = (2 * x + ( nCount - 1 ) * preY)/(nCount + 1);
        }
        //else 递归结束，递归到最里层了。
    }
    else
        HB_LOG(@"error!");
    
    return bResult;
}

- (CGFloat) DIFWithData:(NSArray*)data nBegin:(NSUInteger)nBegin
{
    CGFloat bResult = MACD_MAX_VALUE;
    
    if (nBegin + 1 >= 26)
    {
        CGFloat ema12 = [self emaWithData:data nLargeBegin:nBegin nCount:12];
        CGFloat ema26 = [self emaWithData:data nLargeBegin:nBegin nCount:26];
        bResult = ema12 - ema26;
    }
    //else 此kline以前不足26个数据；
    return bResult;
}

- (CGFloat) DEAWithData:(NSArray*)data nBegin:(NSUInteger)nBegin
{
    CGFloat bResult = MACD_MAX_VALUE;
    if (nBegin + 1 >= 9)
    {
        NSMutableArray* difData = [NSMutableArray arrayWithCapacity:9];
        CGFloat total = 0.0f;
        for (int nIndex = 0; nIndex < 9; nIndex++)
        {
            CGFloat dif = [self DIFWithData:data nBegin:nBegin - 8 + nIndex];
            total += dif;
            if (dif == MACD_MAX_VALUE)
            {
                return bResult;
            }
            [difData addObject:@(dif)];
        }//endf
        
        
        bResult = [self emaWithData:difData nLargeBegin:8 nCount:9];
    }
    //esle cont.
    
    return bResult;
}

#pragma mark - all notification

- (void) onLastKLineUpdated:(NSNotification*)aNotification
{
    if (!self.offsetCount)
    {
        NSDictionary* pldDict = aNotification.object;
        if (pldDict)
        {
            NSString* strPeriod = [pldDict objectForKey:PERIOD];
            NSString* strSmb = [pldDict objectForKey:SYMBOLID];
            
            if ([strPeriod isEqualToString:self.keyPeriod] && [strSmb isEqualToString:self.keySymbolid])
            {
                [self updateBackDataWithLastKLine:pldDict];
            }
            //else other kline
        }
        else
            HB_LOG(@"error!");
    }
    //else 已经发生拖拽，看不到最后一根k线，不需要更新它。
}

- (void) onKLineViewUpdated:(NSNotification*)aNotification
{
    /************************************************************************
     如果在请求的时候数据尚未从服务器返回，那么就需要设置观察，等待服务器返回。
     ************************************************************************/
    NSDictionary* pldDict = aNotification.object;
    if (pldDict)
    {
        self.backData = nil;
        self.category = nil;
        
        self.keySymbolid = [pldDict objectForKey:SYMBOLID];
        self.keyPeriod = [pldDict objectForKey:PERIOD];
        [self resetMaxAndMinValue];
        
        _bTimeLine = [self isTimeLine];
        if(_bTimeLine)
            _nAverageCount = CONSTANT_MA60;
        else
            _nAverageCount = CONSTANT_MA60;
        
        BOOL bDataInited = NO;
        NSArray* valueArray = [pldDict objectForKey:TIME];
        if (valueArray)
        {
            NSInteger dataCount = _nAverageCount > self.kCount ? _nAverageCount : self.kCount;
            NSInteger theBeginIndex = [valueArray count] - dataCount;
            if (_bTimeLine)
                bDataInited = [self updateTimeLineWithDict:pldDict fromIndex:theBeginIndex];
            else
                bDataInited = [self updateKLineWithDict:pldDict fromIndex:theBeginIndex];
        }
        else
            bDataInited = [self initKLineDataWithBeginTime:_nCurrentBegin updatePeriod:self.keyPeriod symbolid:self.keySymbolid];
        
        [self refreshDisplay:KLINE_REFRESH_BATCH];
    }
    else
        HB_LOG(@"error!");
}

#pragma mark - update last kline
- (void) updateBackDataWithLastKLine:(NSDictionary*)pldDict
{
    NSNumber* valueAmount       = [pldDict objectForKey:AMOUNT];
    NSNumber* valuePriceHigh    = [pldDict objectForKey:PRICEHIGH];
    NSNumber* valuePriceLow     = [pldDict objectForKey:PRICELOW];
    NSNumber* valuePriceLast    = [pldDict objectForKey:PRICELAST];
    NSNumber* valuePriceOpen    = [pldDict objectForKey:PRICEOPEN];
    NSNumber* valueTime         = [pldDict objectForKey:TIME];
    
    NSMutableDictionary* item = [[NSMutableDictionary alloc] initWithCapacity:8];
    [item setObject:valuePriceOpen forKey:PRICEOPEN];
    [item setObject:valuePriceHigh forKey:PRICEHIGH];
    [item setObject:valuePriceLow forKey:PRICELOW];
    [item setObject:valuePriceLast forKey:PRICELAST];
    [item setObject:valueAmount forKey:AMOUNT];
    
    BOOL bChange = [self updateBackDataItem:item valueTime:valueTime];
    [self updateLastKLineSpace];
    if (bChange)
    {
        [self refreshDisplay:KLINE_REFRESH_BATCH];
    }
    else
    {
        [self refreshDisplay:KLINE_REFRESH_BATCH];
    }
    
    if(self.kLineView && self.offsetCount)
        [self.kLineView refreshLastPrice:valuePriceLast andLastAmount:valueAmount bOnlyMove:NO];
    //else 这种情况下：利用k线的位置来更新实时价格和实时成交量的位置，会使得他们两个总是在相同位置上。
}

- (void) updateLastKLineSpace
{
    [self resetMaxAndMinValue];
    
    if (self.backData)
    {
        NSInteger theEndIndex = [self.backData count] - self.kCount;
        if ([self.backData count] > 0 && theEndIndex >= 0)
        {
            for (NSInteger nIndex = [self.backData count] - 1; nIndex >= theEndIndex; nIndex--)
            {
                NSMutableDictionary* item = [self.backData objectAtIndex:nIndex];
                
                NSNumber* itemPriceHigh = [item objectForKey:PRICEHIGH];//high
                if (itemPriceHigh && [itemPriceHigh doubleValue] != MAXFLOAT)
                {
                    if ([itemPriceHigh doubleValue] > self.maxValue)
                        self.maxValue = [itemPriceHigh doubleValue];
                    //else cont.
                }
                else
                    HB_LOG(@"error");
                
                
                NSNumber* itemPriceLow = [item objectForKey:PRICELOW];//low
                if (itemPriceLow && [itemPriceLow doubleValue] != MAXFLOAT)
                {
                    if ([itemPriceLow doubleValue] < self.minValue)
                    {
                        self.minValue = [itemPriceLow doubleValue];
                    }
                    //else cont.
                }
                else
                    HB_LOG(@"error");
                
                NSNumber* itemMA60 = [item objectForKey:MA_MA60];//low
                if (itemMA60 && [itemMA60 doubleValue] != MAXFLOAT)
                {
                    if ([itemMA60 doubleValue] < self.minValue)
                    {
                        self.minValue = [itemMA60 doubleValue];
                    }
                    //else cont.
                    
                    if ([itemMA60 doubleValue] > self.maxValue)
                        self.maxValue = [itemMA60 doubleValue];
                    //else cont.
                }
                //else cont.
                
                NSNumber* itemVolume= [item objectForKey:AMOUNT];
                // 成交量的最大值最小值
                if ([itemVolume doubleValue] > self.amountMaxValue) {
                    self.amountMaxValue = [itemVolume doubleValue];
                }
                //else cont.
                
                if ([itemVolume doubleValue] < self.amountMinValue) {
                    self.amountMinValue = [itemVolume doubleValue];
                }
                //else cont.
                
                [self updateBOLLSpace:item];
                
                [self updateMACDSpace:item];
                
                if (self.minValue == 0)
                {
                    int i = 0;
                    i++;
                }
                
            }//endf
        }
        else
            HB_LOG(@"error!");
    }
    else
        HB_LOG(@"error!");
}

- (void) updateBOLLSpace:(NSMutableDictionary*)item
{
    
    if ( KLINE_TYPE_BOLL == self.mainchatType && ![self isTimeLine])
    {
        NSNumber* bollUp = [item objectForKey:BOLL_UB];
        if ( bollUp && [bollUp doubleValue] != 0.0f && [bollUp doubleValue] > self.bollMaxValue)
        {
            self.bollMaxValue = [bollUp doubleValue];
        }
        //else cont.
        
        NSNumber* bollDown = [item objectForKey:BOLL_LB];//low
        if (bollUp && [bollDown doubleValue] != 0.0f && [bollDown doubleValue] < self.bollMinValue)
        {
            self.bollMinValue = [bollDown doubleValue];
        }
        //else cont.
    }
    else if( KLINE_TYPE_MA == self.mainchatType)
    {
        NSNumber* ma60 = [item objectForKey:MA_MA60];
        if (ma60 && [ma60 doubleValue] != 0.0f)
        {
            if ( [ma60 doubleValue] > self.bollMaxValue)
            {
                self.bollMaxValue = [ma60 doubleValue];
            }
            //else cont.
            
            if ( [ma60 doubleValue] < self.bollMinValue)
            {
                self.bollMinValue = [ma60 doubleValue];
            }
            //else cont.
        }
        //else 最左边的就不足60个数据，没有60均线
    }
    else if( KLINE_TYPE_NONE == self.mainchatType)
    {
        NSNumber* ma60 = [item objectForKey:MA_MA60];
        if (ma60 && [ma60 doubleValue] != 0.0f)
        {
            if ( [ma60 doubleValue] > self.bollMaxValue)
            {
                self.bollMaxValue = [ma60 doubleValue];
            }
            //else cont.
            
            if ( [ma60 doubleValue] < self.bollMinValue)
            {
                self.bollMinValue = [ma60 doubleValue];
            }
            //else cont.
        }
        //else 最左边的就不足60个数据，没有60均线
    }
    else
        HB_LOG(@"error!");
}

- (void) updateMACDSpanWithItem:(NSNumber*)itemMACD
{
    // macd max量的最大值最小值
    if ([itemMACD doubleValue] < MACD_MAX_VALUE && [itemMACD doubleValue] > self.MACDMaxValue) {
        self.MACDMaxValue = [itemMACD doubleValue];
    }
    //else cont.
    
    
    if ([itemMACD doubleValue] < MACD_MAX_VALUE && [itemMACD doubleValue] < self.MACDMinValue) {
        self.MACDMinValue = [itemMACD doubleValue];
    }
    //else cont.
}

- (void) updateMACDSpace:(NSMutableDictionary*)item
{
    switch (self.MACDType) {
        case MACD_TYPE_MACD:
        {
            [self updateMACDSpanWithItem:[item objectForKey:MACD_MACD]];
            [self updateMACDSpanWithItem:[item objectForKey:MACD_DIF]];
            [self updateMACDSpanWithItem:[item objectForKey:MACD_DEA]];
            break;
        }
        case MACD_TYPE_KDJ:
        {
            [self updateMACDSpanWithItem:[item objectForKey:KDJ_K]];
            [self updateMACDSpanWithItem:[item objectForKey:KDJ_D]];
            [self updateMACDSpanWithItem:[item objectForKey:KDJ_J]];
            
            break;
        }
            
        case MACD_TYPE_RSI:
        {
            [self updateMACDSpanWithItem:[item objectForKey:RSI_RSI1]];
            [self updateMACDSpanWithItem:[item objectForKey:RSI_RSI2]];
            [self updateMACDSpanWithItem:[item objectForKey:RSI_RSI3]];
            
            break;
        }
        case MACD_TYPE_WR:
        {
            [self updateMACDSpanWithItem:[item objectForKey:WR_WR1]];
            [self updateMACDSpanWithItem:[item objectForKey:WR_WR2]];
            break;
        }
        default:
            break;
    }
}

- (void) updateAmountOfItem:(NSMutableDictionary*)item amountArray:(NSArray*)amountArray nIndex:(NSInteger)nIndex
{
    if (nIndex + 1 >= CONSTANT_MA5)
    {
        // amount MA5
        CGFloat MA5 = [self sumArrayWithData:amountArray andRange:NSMakeRange(nIndex - CONSTANT_MA5 + 1, CONSTANT_MA5)];
        [item setObject:@(MA5) forKey:AMOUNT_MA5];
    }
    //else cont.
    
    if (nIndex + 1 >= CONSTANT_MA10)
    {
        // amount MA10
        CGFloat MA10 = [self sumArrayWithData:amountArray andRange:NSMakeRange(nIndex - CONSTANT_MA10 + 1, CONSTANT_MA10)];
        [item setObject:@(MA10) forKey:AMOUNT_MA10];
    }
    //else cont.
}

- (void) updateBOLLOrMA:(NSMutableDictionary*)item pricelastArray:(NSArray*)dataArray nIndex:(NSInteger)nIndex
{
    if (KLINE_TYPE_BOLL == self.mainchatType)
    {
        //BOLL
        if (nIndex + 1 >= 20)
        {
            NSRange averageRange = NSMakeRange(nIndex - 20 + 1, 20);
            //BOLL 线
            CGFloat summaryBoll = [self sumArrayWithData:dataArray andRange:averageRange];
            [item setObject:@(summaryBoll) forKey:BOLL_SUMMARY];
            
            CGFloat UB = summaryBoll + 2 * [self getSTDWithData:dataArray andRange:averageRange];
            [item setObject:@(UB) forKey:BOLL_UB];
            
            CGFloat LB = summaryBoll - 2 * [self getSTDWithData:dataArray andRange:averageRange];
            [item setObject:@(LB) forKey:BOLL_LB];
        }
        //else cont.
    }
    else if (KLINE_TYPE_MA == self.mainchatType)
    {
        //MA10
        if (nIndex + 1 >= CONSTANT_MA10)
        {
            CGFloat MA10 = [self sumArrayWithData:dataArray andRange:NSMakeRange(nIndex - CONSTANT_MA10 + 1, CONSTANT_MA10)];
            [item setObject:@(MA10) forKey:MA_MA10];
        }
        else
            [item setObject:@(MACD_MAX_VALUE) forKey:MA_MA10];

        // MA30
        if (nIndex + 1 >= CONSTANT_MA30)
        {
            CGFloat MA30 = [self sumArrayWithData:dataArray andRange:NSMakeRange(nIndex - CONSTANT_MA30 + 1, CONSTANT_MA30)];
            [item setObject:@(MA30) forKey:MA_MA30];
        }
        else
            [item setObject:@(MACD_MAX_VALUE) forKey:MA_MA30];
        
        // MA60
        if (nIndex + 1 >= CONSTANT_MA60)
        {
            CGFloat MA60 = [self sumArrayWithData:dataArray andRange:NSMakeRange(nIndex - CONSTANT_MA60 + 1, CONSTANT_MA60)];
            [item setObject:@(MA60) forKey:MA_MA60];
        }
        else
            [item setObject:@(MACD_MAX_VALUE) forKey:MA_MA60];
    }
    else if( KLINE_TYPE_NONE == self.mainchatType)
    {
        
    }
    else
        HB_LOG(@"error!");
}

- (void) updateKDJOfItem:(NSMutableDictionary*)item dataDiction:(NSDictionary*)dataDiction nIndex:(NSInteger)nIndex
{
//    NSArray* timeArray = [dataDiction objectForKey:TIME];
//    NSInteger beginTime = [[timeArray objectAtIndex:nIndex] integerValue];
//    NSDate* beginTimeDate = [NSDate dateWithTimeIntervalSince1970:beginTime];
//    NSString *beginTimeString = [_timeDateFormatter stringFromDate:beginTimeDate];
    
    CGFloat valueK = [ImKDJObject entryK:dataDiction kIndex:nIndex];
    [item setObject:@(valueK) forKey:KDJ_K];
    
    CGFloat valueD = [ImKDJObject entryD:dataDiction dIndex:nIndex];
    [item setObject:@(valueD) forKey:KDJ_D];
    
    CGFloat valueJ =  3 * valueK - 2* valueD;
    [item setObject:@(valueJ) forKey:KDJ_J];
}

- (BOOL) updateBackDataItem:(NSMutableDictionary*)item valueTime:(NSNumber*)valueTime
{
    BOOL bResult = NO;

    NSString *strBeginTime = [@(-1) stringValue];
    NSString *strEndTime = [@0 stringValue];
    
    NSString *strDataCount = [@(self.kCount + CONSTANT_MA60) stringValue];
    NSDictionary* argsDict = @{PERIOD:self.keyPeriod,SYMBOLID:self.keySymbolid,FROM:strBeginTime, TO:strEndTime,@"dataCount":strDataCount};
    
    NSString* strTableName = [NSString stringWithFormat:@"%@%@",self.keySymbolid,self.keyPeriod];
    NSDictionary* dictValue = [[DLMainManager sharedDBManager] queryLastKLineValue:PRICELAST withDictionary:argsDict ofTableName:strTableName];
    
    NSArray* pricelastArray = [dictValue objectForKey:PRICELAST];
    NSArray* amountArray = [dictValue objectForKey:AMOUNT];

    
    if (pricelastArray && amountArray)
    {
        NSInteger nIndex = [pricelastArray count] - 1;
        
        if (_bTimeLine)
        {

            // MA60
            if (nIndex + 1 >= CONSTANT_MA60)
            {
                CGFloat MA60 = [self sumArrayWithData:pricelastArray andRange:NSMakeRange(nIndex - CONSTANT_MA60 + 1, CONSTANT_MA60)];
                [item setObject:@(MA60) forKey:MA_MA60];
            }
            else
                [item setObject:@(MACD_MAX_VALUE) forKey:MA_MA60];
        }
        else
            [self updateBOLLOrMA:item pricelastArray:pricelastArray nIndex:nIndex];
        
        [self updateAmountOfItem:item amountArray:amountArray nIndex:nIndex];
        
        [self updateMACDOfItem:item pricelastArray:dictValue nIndex:nIndex];
        
        [item setObject:valueTime forKey:TIME];
        
        NSUInteger nFoundIndex = [self.category indexOfObject:valueTime];
        if (nFoundIndex == NSNotFound)
        {
            [self.backData addObject:item];
            [self.category addObject:valueTime]; // date
            bResult = YES;
        }
        else
        {
            [self.backData replaceObjectAtIndex:nFoundIndex withObject:item];
        }//endi
    }
    else
        HB_LOG(@"error!");
    
    return bResult;
}

#pragma mark - macd

- (void) updateMACDOfItem:(NSMutableDictionary*)item pricelastArray:(NSDictionary*)dataDiction nIndex:(NSInteger)nIndex
{
    switch (self.MACDType) {
        case MACD_TYPE_NONE:
        {
            break;
        }
        case MACD_TYPE_MACD:
        {
            //MACD
            NSArray* pricelastArray = [dataDiction objectForKey:PRICELAST];
            CGFloat difValue = [self DIFWithData:pricelastArray nBegin:nIndex];
            CGFloat deaValue = [self DEAWithData:pricelastArray nBegin:nIndex];
            if (difValue != MAXFLOAT && deaValue != MAXFLOAT)
            {
                [item setObject:@((difValue - deaValue) * 2) forKey:MACD_MACD];
            }
            else
                [item setObject:@(MAXFLOAT) forKey:MACD_MACD];

            [item setObject:@(difValue) forKey:MACD_DIF];
            [item setObject:@(deaValue) forKey:MACD_DEA];
             break;
        }
        case MACD_TYPE_KDJ:
        {
            CGFloat valueK = [ImKDJObject entryK:dataDiction kIndex:nIndex];
            [item setObject:@(valueK) forKey:KDJ_K];
            
            CGFloat valueD = [ImKDJObject entryD:dataDiction dIndex:nIndex];
            [item setObject:@(valueD) forKey:KDJ_D];
            
             if (valueK != MAXFLOAT && valueD != MAXFLOAT)
             {
                 CGFloat valueJ =  3 * valueK - 2* valueD;
                 [item setObject:@(valueJ) forKey:KDJ_J];
             }
             else
                 [item setObject:@(MAXFLOAT) forKey:KDJ_J];
            
            break;
        }
        case MACD_TYPE_RSI:
        {
            NSArray* pricelastArray = [dataDiction objectForKey:PRICELAST];
            
            CGFloat value1 = [ImRSIObject entryRSI1:pricelastArray fromIndex:nIndex];
            [item setObject:@(value1) forKey:RSI_RSI1];
            
            CGFloat value2 = [ImRSIObject entryRSI2:pricelastArray fromIndex:nIndex];
            [item setObject:@(value2) forKey:RSI_RSI2];
            
            CGFloat value3 = [ImRSIObject entryRSI3:pricelastArray fromIndex:nIndex];
            [item setObject:@(value3) forKey:RSI_RSI3];
            break;
        }
        case MACD_TYPE_WR:
        {
            CGFloat value1 = [ImWRObject entryWR1:dataDiction nIndex:nIndex];
            [item setObject:@(value1) forKey:WR_WR1];
            
            CGFloat value2 = [ImWRObject entryWR2:dataDiction nIndex:nIndex];
            [item setObject:@(value2) forKey:WR_WR2];
            break;
        }
        default:
            break;
    }
}

#pragma mark - KLine Data




- (BOOL) updateKLineWithDictOffset:(NSDictionary*)dataDiction fromIndex:(NSInteger)nBeginIndex1
{
    BOOL bResult = NO;
    
    //解析数据
    NSArray* timeArray = [dataDiction objectForKey:TIME];
    
    //从数据层获取数据
    NSMutableArray *data =[[NSMutableArray alloc] init];
    NSMutableArray *category =[[NSMutableArray alloc] init];
    
    if (self.kCount > [timeArray count])
    {
        self.kCount = [timeArray count];
    }
    //else cont.
    
    BOOL bReuse = NO;
    NSNumber* valueTime  = [timeArray objectAtIndex:[timeArray count] - self.kCount];
    NSUInteger indexInData = [[self category] indexOfObject:valueTime];
    if (indexInData != NSNotFound)
    {
        bReuse = YES;
    }
    //else cont.
    
    self.kCount = MIN(self.kCount, [timeArray count]);
    for (NSInteger nIndex = [timeArray count] - self.kCount; nIndex < [timeArray count]; nIndex++)
    {
        NSNumber* valueTime = [timeArray objectAtIndex:nIndex];
        NSMutableDictionary* item = nil;
        if ([[[self category] firstObject] unsignedIntegerValue] <= [valueTime unsignedIntegerValue] &&
            [[[self category] lastObject] unsignedIntegerValue] >= [valueTime unsignedIntegerValue])
        {
            NSInteger indexInData = [[self category] indexOfObject:valueTime];
            item = [self.backData objectAtIndex:indexInData];
        }
        else
        {
            item = [self allocKLineDataItem:dataDiction ofIndex:nIndex];
        }
        
        [item setObject:valueTime forKey:TIME];
        [data addObject:item];
        [category addObject:valueTime]; // date
        
    }//endf
    
    if(data.count != 0)
    {
        self.backData = data; // Open,High,Low,Close,Adj Close,Volume
        self.category = category; // Date
        
        bResult = YES;
    }//endi
    else
        HB_LOG(@"error!");
    
    [self updateLastKLineSpace];
    
    return bResult;
}

- (BOOL) updateKLineWithDict:(NSDictionary*)dataDiction fromIndex:(NSInteger)nBeginIndex1
{
    BOOL bResult = NO;
    
    //解析数据
    NSArray* amountArray = [dataDiction objectForKey:AMOUNT];
    NSArray* pricehighArray = [dataDiction objectForKey:PRICEHIGH];
    NSArray* pricelowArray = [dataDiction objectForKey:PRICELOW];
    NSArray* pricelastArray = [dataDiction objectForKey:PRICELAST];
    NSArray* priceOpenArray = [dataDiction objectForKey:PRICEOPEN];
    NSArray* timeArray = [dataDiction objectForKey:TIME];
    
    //从数据层获取数据
    NSMutableArray *data =[[NSMutableArray alloc] init];
    NSMutableArray *category =[[NSMutableArray alloc] init];
    
    if (self.kCount > [timeArray count])
    {
        self.kCount = [timeArray count];
    }
    //else cont.
    
    for (NSInteger nIndex = [timeArray count] - self.kCount; nIndex < [timeArray count]; nIndex++)
    {
        NSNumber* valueAmount       = [amountArray objectAtIndex:nIndex];
        NSNumber* valuePriceHigh    = [pricehighArray objectAtIndex:nIndex];
        NSNumber* valuePriceLow     = [pricelowArray objectAtIndex:nIndex];
        NSNumber* valuePriceLast    = [pricelastArray objectAtIndex:nIndex];
        NSNumber* valuePriceOpen    = [priceOpenArray objectAtIndex:nIndex];
        NSNumber* valueTime         = [timeArray objectAtIndex:nIndex];
        
        NSMutableDictionary* item = [[NSMutableDictionary alloc] initWithCapacity:8];
        [item setObject:valuePriceOpen forKey:PRICEOPEN];  //open
        [item setObject:valuePriceHigh forKey:PRICEHIGH];
        [item setObject:valuePriceLow forKey:PRICELOW];  //open
        [item setObject:valuePriceLast forKey:PRICELAST];
        [item setObject:valueAmount forKey:AMOUNT];
        
        [self updateBOLLOrMA:item pricelastArray:pricelastArray nIndex:nIndex];
        [self updateAmountOfItem:item amountArray:amountArray nIndex:nIndex];
        [self updateMACDOfItem:item pricelastArray:dataDiction nIndex:nIndex];
        
        [item setObject:valueTime forKey:TIME];
        
        [category addObject:valueTime]; // date
        [data addObject:item];
        
    }//endf
    
    if(data.count != 0)
    {
        self.backData = data; // Open,High,Low,Close,Adj Close,Volume
        self.category = category; // Date
        
        bResult = YES;
    }//endi
    else
        HB_LOG(@"error!");
    
    [self updateLastKLineSpace];
    
    return bResult;
}

- (BOOL) updateTimeLineWithDictOffset:(NSDictionary*)dataDiction fromIndex:(NSInteger)nBeginIndex1
{
    BOOL bResult = NO;
    
    //解析数据
    NSArray* timeArray = [dataDiction objectForKey:TIME];
    
    //从数据层获取数据
    NSMutableArray *data =[[NSMutableArray alloc] init];
    NSMutableArray *category =[[NSMutableArray alloc] init];
    
    if (self.kCount > [timeArray count])
    {
        self.kCount = [timeArray count];
    }
    //else cont.
    
    BOOL bReuse = NO;
    NSNumber* valueTime  = [timeArray objectAtIndex:[timeArray count] - self.kCount];
    NSUInteger indexInData = [[self category] indexOfObject:valueTime];
    if (indexInData != NSNotFound)
    {
        bReuse = YES;
    }
    //else cont.
    
    for (NSInteger nIndex = [timeArray count] - self.kCount; nIndex < [timeArray count]; nIndex++)
    {
        NSNumber* valueTime  = [timeArray objectAtIndex:nIndex];
        NSMutableDictionary* item = nil;
        if (bReuse)
        {
            if (indexInData < [self.backData count])
            {
                item = [self.backData objectAtIndex:indexInData];
                indexInData++;
            }
            else
            {
                bReuse = NO;
                item = [self allocKLineDataItem:dataDiction ofIndex:nIndex];
            }
        }
        else
            item = [self allocKLineDataItem:dataDiction ofIndex:nIndex];
        
        [item setObject:valueTime forKey:TIME];
        [data addObject:item];
        [category addObject:valueTime]; // date
    }//endf
    
    if(data.count!=0)
    {
        self.backData = data; // Open,High,Low,Close,Adj Close,Volume
        self.category = category; // Date
        bResult = YES;
    }
    else
        HB_LOG(@"error!");
    
    [self updateLastKLineSpace];
    
    return bResult;
}

- (NSMutableDictionary*) allocKLineDataItem:(NSDictionary*)dataDiction ofIndex:(NSInteger)nIndex
{
    NSMutableDictionary* item = [[NSMutableDictionary alloc] initWithCapacity:8];
    NSArray* amountArray = [dataDiction objectForKey:AMOUNT];
    /**********************************************************************
     amountArray pricehighArray pricelowArray pricelastArray priceOpenArray
     这几个数组的count是相同的。
     **********************************************************************/
    if ([amountArray count] > nIndex)
    {
        NSArray* pricehighArray = [dataDiction objectForKey:PRICEHIGH];
        NSArray* pricelowArray = [dataDiction objectForKey:PRICELOW];
        NSArray* pricelastArray = [dataDiction objectForKey:PRICELAST];
        NSArray* priceOpenArray = [dataDiction objectForKey:PRICEOPEN];
        
        NSNumber* valueAmount       = [amountArray objectAtIndex:nIndex];
        NSNumber* valuePriceHigh    = [pricehighArray objectAtIndex:nIndex];
        NSNumber* valuePriceLow     = [pricelowArray objectAtIndex:nIndex];
        NSNumber* valuePriceLast    = [pricelastArray objectAtIndex:nIndex];
        NSNumber* valuePriceOpen    = [priceOpenArray objectAtIndex:nIndex];
        
        [item setObject:valuePriceOpen forKey:PRICEOPEN];
        [item setObject:valuePriceHigh forKey:PRICEHIGH];
        [item setObject:valuePriceLow forKey:PRICELOW];
        [item setObject:valuePriceLast forKey:PRICELAST];
        [item setObject:valueAmount forKey:AMOUNT];
        
        //BOLL 线
        [self updateBOLLOrMA:item pricelastArray:pricelastArray nIndex:nIndex];
        [self updateAmountOfItem:item amountArray:amountArray nIndex:nIndex];
        [self updateMACDOfItem:item pricelastArray:dataDiction nIndex:nIndex];
    }
    else
        HB_LOG(@"error!");
    return item;
}

- (BOOL) updateTimeLineWithDict:(NSDictionary*)dataDiction fromIndex:(NSInteger)nBeginIndex1
{
    BOOL bResult = NO;
    
    //解析数据
    NSArray* amountArray = [dataDiction objectForKey:AMOUNT];
    NSArray* pricehighArray = [dataDiction objectForKey:PRICEHIGH];
    NSArray* pricelowArray = [dataDiction objectForKey:PRICELOW];
    NSArray* pricelastArray = [dataDiction objectForKey:PRICELAST];
    NSArray* priceOpenArray = [dataDiction objectForKey:PRICEOPEN];
    NSArray* timeArray = [dataDiction objectForKey:TIME];
    
    //从数据层获取数据
    NSMutableArray *data =[[NSMutableArray alloc] init];
    NSMutableArray *category =[[NSMutableArray alloc] init];
    
    if (self.kCount > [timeArray count])
    {
        self.kCount = [timeArray count];
    }
    //else cont.
    
    for (NSInteger nIndex = [timeArray count] - self.kCount; nIndex < [timeArray count]; nIndex++)
    {
        NSNumber* valueAmount       = [amountArray objectAtIndex:nIndex];
        NSNumber* valuePriceHigh    = [pricehighArray objectAtIndex:nIndex];
        NSNumber* valuePriceLow     = [pricelowArray objectAtIndex:nIndex];
        NSNumber* valuePriceLast    = [pricelastArray objectAtIndex:nIndex];
        NSNumber* valuePriceOpen    = [priceOpenArray objectAtIndex:nIndex];
        NSNumber* valueTime         = [timeArray objectAtIndex:nIndex];
        
        NSMutableDictionary* item = [[NSMutableDictionary alloc] initWithCapacity:8];
        [item setObject:valuePriceOpen forKey:PRICEOPEN];
        [item setObject:valuePriceHigh forKey:PRICEHIGH];
        [item setObject:valuePriceLow forKey:PRICELOW];
        [item setObject:valuePriceLast forKey:PRICELAST];
        [item setObject:valueAmount forKey:AMOUNT];
        
        {
            if (nIndex + 1 >= CONSTANT_MA60)
            {
                CGFloat MA60 = [self sumArrayWithData:pricelastArray andRange:NSMakeRange(nIndex - CONSTANT_MA60 + 1, CONSTANT_MA60)];
                [item setObject:@(MA60) forKey:MA_MA60];
            }
            else
                [item setObject:@(MACD_MAX_VALUE) forKey:MA_MA60];
            
            [self updateAmountOfItem:item amountArray:amountArray nIndex:nIndex];
            
            //MACD
            [self updateMACDOfItem:item pricelastArray:dataDiction nIndex:nIndex];
            
            //[self updateKDJOfItem:item dataDiction:dataDiction nIndex:nIndex];
        }
        
        // 前面二十个数据不要了，因为只是用来画均线的
        [category addObject:valueTime]; // date
        [item setObject:valueTime forKey:TIME];
        [data addObject:item];
    }//endf

    
    if(data.count!=0)
    {
        self.backData = data; // Open,High,Low,Close,Adj Close,Volume
        self.category = category; // Date
        bResult = YES;
    }
    else
        HB_LOG(@"error!");

    
    [self updateLastKLineSpace];
    
    return bResult;
}

- (NSInteger) getIntervalOfPeriod:(NSString*)keyPeriod
{
    NSInteger nResult = 0;
    if ([keyPeriod isEqualToString:KLINE1MIN])
    {
        nResult = 60;
    }
    else if ([keyPeriod isEqualToString:KLINE5MIN])
    {
        nResult = 60 * 5;
    }
    else if ([keyPeriod isEqualToString:KLINE15MIN])
    {
        nResult = 60 * 15;
    }
    else if ([keyPeriod isEqualToString:KLINE30MIN])
    {
        nResult = 60 * 30;
    }
    else if ([keyPeriod isEqualToString:KLINE60MIN])
    {
        nResult = 60 * 60;
    }
    else if ([keyPeriod isEqualToString:KLINE1DAY])
    {
        nResult = 60 * 60 * 24;
    }
    else if ([keyPeriod isEqualToString:KLINE1WEEK])
    {
        nResult = 7 * 60 * 60 * 24;
    }
    else
        HB_LOG(@"error!");
    
    return nResult;
}

- (BOOL)  createKLineDataWithBeginTime:(NSInteger)nBeginTime withEndTime:(NSInteger)nEndTime updatePeriod:(NSString*)updatePeriod symbolid:(NSString*)updateSymbolid
{
    BOOL bResult = NO;
    _bRequestingNextKLine = NO;
    
    NSString* strTable = [NSString stringWithFormat:@"%@%@",updateSymbolid,updatePeriod];
    NSDictionary* dataDiction = nil;
    
    //生成请求参数
    NSString *strBeginTime = [@(nBeginTime) stringValue];

    NSString *strEndTime = [@(nEndTime) stringValue];
    NSDictionary* argsDict = @{PERIOD:self.keyPeriod,SYMBOLID:self.keySymbolid,FROM:strBeginTime, TO:strEndTime};
    dataDiction = [[DLMainManager sharedDBManager] queryLastKLineArrayWithDictionary:argsDict ofTableName:strTable];
    
    //解析数据
    NSArray* timeArray = [dataDiction objectForKey:TIME];
    if (timeArray)
    {
        NSInteger nBeginIndex = 0;
        nBeginIndex = [timeArray indexOfObject:@(nBeginTime)];
        if (nBeginIndex != NSNotFound)
        {
            //将开始的index定位在能够显示的第一个Index上
            NSInteger dataCount = _nAverageCount < self.kCount ? _nAverageCount : self.kCount;
            nBeginIndex += dataCount;
            BOOL bTimeLine = [self isTimeLine];
            if (bTimeLine)
                bResult = [self updateTimeLineWithDictOffset:dataDiction fromIndex:nBeginIndex];
            else
                bResult = [self updateKLineWithDictOffset:dataDiction fromIndex:nBeginIndex];
        }
        else
            HB_LOG(@"error!");
    }
    else HB_LOG(@"error!");
    
    return bResult;
}

#pragma mark - 拖拽
/*****************************************************************************************
 手指从左向右滑动
 *****************************************************************************************/
- (NSInteger) moveMouseToRightWithOffet:(NSInteger)nOffset
{
    
    NSInteger intervalPerItem = [self getIntervalOfPeriod:self.keyPeriod];
    NSString* strTable = [NSString stringWithFormat:@"%@%@",self.keySymbolid,self.keyPeriod];
    NSInteger nEndInDB = [[DLMainManager sharedDBManager] queryMaxValueWithKey:TIME ofTableName:strTable];
    
    /**当前DB中最早的时间,如果nBeginInNeed在nBeginInDB之后，就继续计算**/
    NSInteger nBeginInDB = [[DLMainManager sharedDBManager] queryMinValueWithKey:TIME ofTableName:strTable];
    
    //
    NSInteger nIntervalFromBeginToEnd = self.kCount -  1;
    NSInteger nMaxOffset = (nEndInDB - nBeginInDB)/intervalPerItem - nIntervalFromBeginToEnd;
    
    nMaxOffset = nMaxOffset < 0 ? 0 : nMaxOffset;
    if (self.offsetCount < nMaxOffset)
    {
        nOffset = ( nOffset > nMaxOffset) ? nMaxOffset : nOffset;
        
        /**由于向右移动了count个item，所以应该从firstObject向前追朔nCount个时间单位**/
        NSInteger nEndInNeed = nEndInDB - nOffset * intervalPerItem;
        NSInteger nBeginInNeed = nEndInNeed - (nIntervalFromBeginToEnd + CONSTANT_MA60) * intervalPerItem;
        if (nBeginInNeed >= nBeginInDB)
            ;
        else
            nBeginInNeed = nBeginInDB;
        
        [self resetMaxAndMinValue];
        //更新界面
        BOOL bInited = [self createKLineDataWithBeginTime:nBeginInNeed
                                              withEndTime:nEndInNeed
                                             updatePeriod:self.keyPeriod
                                                 symbolid:self.keySymbolid];
        if (bInited)
        {
            self.offsetCount = nOffset >= 0 ?  nOffset : 0;
            [self refreshDisplay:KLINE_REFRESH_BATCH];
        }
        else
            HB_LOG(@"error!");
    }
    else
        nOffset = nMaxOffset;
    
    return nOffset;
}

/*****************************************************************************************
 手指从右向左滑动
 *****************************************************************************************/
- (NSInteger) moveMouseToLeftWithOffet:(NSInteger)nOffset
{
    if (nOffset < 0)
        nOffset = 0;
    //else cont.
    
    if (self.offsetCount <= 0)
    {
        self.offsetCount = 0;
    }
    else
    {
        NSInteger intervalPerItem = [self getIntervalOfPeriod:self.keyPeriod];
        NSString* strTable = [NSString stringWithFormat:@"%@%@",self.keySymbolid,self.keyPeriod];
        NSInteger nEndInDB = [[DLMainManager sharedDBManager] queryMaxValueWithKey:TIME ofTableName:strTable];
        NSInteger nBeginInDB = [[DLMainManager sharedDBManager] queryMinValueWithKey:TIME ofTableName:strTable];
        
        //向左拖拽
        /**由于向左移动了count个item，所以应该从firstObject向前追朔nCount个时间单位**/
        NSInteger nEndInNeed = nEndInDB - nOffset * intervalPerItem;
        NSInteger nBeginInNeed = 0;         //nEndInNeed - (self.kCount )* intervalPerItem;
        if (nEndInNeed <= nEndInDB)
        {
            nBeginInNeed = nEndInNeed - (self.kCount + CONSTANT_MA60) * intervalPerItem;
            if (nBeginInNeed < nBeginInDB)
            {
                
                nBeginInNeed = nBeginInDB;
                NSInteger tempEnd = nBeginInNeed + (self.kCount ) * intervalPerItem;
                if (tempEnd > nEndInNeed)
                {
                    int i = 0;
                    i++;
                }
            }
            //else ok
        }
        //else cont.
            
        //更新界面
        [self resetMaxAndMinValue];
        BOOL bInited = [self createKLineDataWithBeginTime:nBeginInNeed
                                              withEndTime:nEndInNeed
                                             updatePeriod:self.keyPeriod
                                                 symbolid:self.keySymbolid];
        if (bInited)
        {
            self.offsetCount = nOffset >= 0 ?  nOffset : 0;
            [self refreshDisplay:KLINE_REFRESH_LASTKLINE];
        }
        else
            HB_LOG(@"error!");
    }//endi

    return nOffset;
}

- (NSInteger) updateBackDataWithOffet:(NSInteger)nOffset ofMoveType:(NSInteger)nMoveType
{
    if (self.keySymbolid && self.keyPeriod)
    {
        if (nMoveType > 0)
        {
            nOffset = [self moveMouseToRightWithOffet:nOffset];
        }
        else
        {
            nOffset = [self moveMouseToLeftWithOffet:nOffset];
            
        }//endi
    }
    else
    {
        nOffset = -10;
        HB_LOG(@"error!");
    }
    
    return nOffset;
}

//由于缩放操作而产生新的backdata
- (BOOL) createBackDataWithOffet:(NSInteger)nOffsetCount
{
    BOOL bResult = NO;
    if (self.keySymbolid && self.keyPeriod)
    {
        NSString* strTable = [NSString stringWithFormat:@"%@%@",self.keySymbolid,self.keyPeriod];
        NSInteger nBeginInDB = [[DLMainManager sharedDBManager] queryMinValueWithKey:TIME ofTableName:strTable];
        NSInteger nEndInDB = [[DLMainManager sharedDBManager] queryMaxValueWithKey:TIME ofTableName:strTable];
        
        NSInteger intervalPerItem = [self getIntervalOfPeriod:self.keyPeriod];
        
        if (nOffsetCount == 0)
        {
            NSInteger nBeginInNeed = nEndInDB - (self.kCount + _nAverageCount) * intervalPerItem;
            NSInteger nEndInNeed = 0;
            if (nBeginInNeed >= nBeginInDB)
                nEndInNeed = nEndInDB;
            else
            {
                nBeginInNeed = nBeginInDB;
                nEndInNeed = nEndInDB;
            }//endi
            
            //更新界面
            [self resetMaxAndMinValue];
            bResult = [self createKLineDataWithBeginTime:nBeginInNeed
                                             withEndTime:nEndInNeed
                                            updatePeriod:self.keyPeriod
                                                symbolid:self.keySymbolid];
        }
        else
        {
            NSInteger nBeginInNeed = nEndInDB - (self.kCount + nOffsetCount + _nAverageCount) * intervalPerItem;
            NSInteger nEndInNeed = 0;
            if (nBeginInNeed >= nBeginInDB)
            {
                nEndInNeed = nBeginInNeed + (self.kCount + _nAverageCount) * intervalPerItem;
            }
            else
            {
                nBeginInNeed = nBeginInDB;
                nEndInNeed = nBeginInNeed + (self.kCount + _nAverageCount) * intervalPerItem;
                
                if (nEndInNeed > nEndInDB)
                {
                    nEndInNeed = nEndInDB;
                }
                //else cont.
            }//endi
            
            //更新界面
            [self resetMaxAndMinValue];
            bResult = [self createKLineDataWithBeginTime:nBeginInNeed
                                             withEndTime:nEndInNeed
                                            updatePeriod:self.keyPeriod
                                                symbolid:self.keySymbolid];
        }//endi
    }
    else
        HB_LOG(@"error!");
    
    return bResult;
}

///******************************************************************************
// 这个函数没有被使用，原因是服务器有一个bug：
// 只能获取当前的300条数据，其他的数据一概获取失败，这就导致向服务器请求功能失去意义。
// 但暂时不会去掉它，等待服务器改正之后再切换回来。
// ******************************************************************************/
//- (BOOL) updateWithOffet_nouse:(NSInteger)nCount withTotalCount:(NSInteger)nTotalCount
//{
//    BOOL bResult = 0;
//    
//    if (!self.keySymbolid && !self.keyPeriod)
//    {
//        return NO;
//    }
//    //else cont.
//    
//    NSInteger intervalPerItem = [self getIntervalOfPeriod:self.keyPeriod];
//    NSString* strTable = [NSString stringWithFormat:@"%@%@",self.keySymbolid,self.keyPeriod];
//    NSInteger nEndInDB = [[DLMainManager sharedDBManager] queryMaxValueWithKey:TIME ofTableName:strTable];
//    
//    if (nCount >= 0)
//    {
//        /**由于向右移动了count个item，所以应该从firstObject向前追朔nCount个时间单位**/
//        NSInteger nBeginInNeed = nEndInDB - (self.kCount + nTotalCount + _nAverageCount) * intervalPerItem;
//        
//        /**当前DB中最早的时间,如果nBeginInNeed在nBeginInDB之后，就继续计算**/
//        NSInteger nBeginInDB = [[DLMainManager sharedDBManager] queryMinValueWithKey:TIME ofTableName:strTable];
//        if (nBeginInNeed >= nBeginInDB)
//        {
//            [self resetMaxAndMinValue];
//            
//            //更新界面
//            BOOL bInited = [self initKLineDataWithBeginTime:nBeginInNeed updatePeriod:self.keyPeriod symbolid:self.keySymbolid];
//            if (bInited)
//            {
//                bResult = YES;
//                _nOffsetCount = nTotalCount >= 0 ?  nTotalCount : 0;
//                [self refreshDisplay:KLINE_TYPE__LASTKLINE];
//            }
//            else
//                HB_LOG(@"error!");
//        }
//        else
//        {
//            if (!_bRequestingNextKLine)
//            {
//                _bRequestingNextKLine = YES;
//                //发送请求
//                _nCurrentEnd = nBeginInDB -  intervalPerItem;
//                _nCurrentBegin = _nCurrentEnd - 300 * intervalPerItem;
//                
//                NSString* strRequestIndex = [self.keySymbolid isEqualToString:@"btccny"] ? REQUEST_INDEX_MARKET_OVERVIEW_BTC : REQUEST_INDEX_MARKET_OVERVIEW_LTC;
//                NSDictionary* jsonDict= @{
//                                          VERSION        :@1,
//                                          MSGTYPE        :REQKLINE,
//                                          REQUESTINDEX   :strRequestIndex,
//                                          SYMBOLID       :self.keySymbolid,
//                                          PERIOD         :self.keyPeriod,
//                                          FROM           :@(_nCurrentBegin),
//                                          TO             :@(_nCurrentEnd)
//                                          };
//                
//                [[DLMainManager sharedNetWorkManager] localRequestKLineWithJSON:jsonDict];
//            }
//            
//        }//endi
//    }
//    else
//    {
//        //向左拖拽
//        /**由于向右移动了count个item，所以应该从firstObject向前追朔nCount个时间单位**/
//        NSInteger nEndInNeed = nEndInDB - (nTotalCount) * intervalPerItem;
//        if (nEndInNeed <= nEndInDB)
//        {
//            //更新界面
//            NSInteger nBeginInNeed = nEndInNeed - (self.kCount + _nAverageCount )* intervalPerItem;
//            [self resetMaxAndMinValue];
//            BOOL bInited = [self initKLineDataWithBeginTime:nBeginInNeed updatePeriod:self.keyPeriod symbolid:self.keySymbolid];
//            if (bInited)
//            {
//                bResult = YES;
//                _nOffsetCount = nTotalCount >= 0 ?  nTotalCount : 0;
//                [self refreshDisplay:KLINE_TYPE__LASTKLINE];
//            }
//            //else cont.
//        }
//        else
//        {
//#if 0
//            if (!_bRequestingNextKLine)
//            {
//                //发送请求
//                _nCurrentBegin = nEndInDB +  intervalPerItem;
//                _nCurrentEnd = _nCurrentBegin + 300 * intervalPerItem;
//                NSDictionary* jsonDict= @{
//                                          VERSION        :@1,
//                                          MSGTYPE        :REQKLINE,
//                                          REQUESTINDEX   :REQUEST_INDEX_REQ_KLINE,
//                                          SYMBOLID       :self.keySymbolid,
//                                          PERIOD         :self.keyPeriod,
//                                          FROM           :@(_nCurrentBegin),
//                                          TO             :@(_nCurrentEnd)
//                                          };
//                [[DLMainManager sharedNetWorkManager] localRequestKLineWithJSON:jsonDict];
//            }
//#endif
//        }//endi
//    }//endi
//    
//    return bResult;
//}


#pragma mark - update view

- (void) refreshDisplay:(NSInteger)nUpdateType
{
    if (self.kLineView)
    {
        [self.kLineView appendBackDataToQueue:nUpdateType];
    }
    else
        HB_LOG(@"error!");
}

- (BOOL) isTimeLine
{
    BOOL bResult = NO;
    if (self.kLineView)
    {
        bResult = self.kLineView.bTimeLine;
    }
    else
        HB_LOG(@"error!");
    
    return bResult;
}
@end
