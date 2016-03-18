//
//  KlineConstant.h
//  TestKLine
//
//  Created by LRF on 15/9/15.
//  Copyright (c) 2015年 LRF. All rights reserved.
//

#ifndef TestKLine_KlineConstant_h
#define TestKLine_KlineConstant_h




/********************************************************************
 消息类型常量定义开始
 ********************************************************************/
#define MARKETDETAIL        /*marketDetail*/        @"marketDetail"         // 盘口
#define TRADEDETAIL         /*tradeDetail*/         @"tradeDetail"          // 交易明细
#define MARKETDEPTHTOPSHORT /*marketDepthTopShort*/ @"marketDepthTopShort"       // top行情深度
#define MARKETDEPTHTOP      /*marketDepthTop*/      @"marketDepthTop"       // top行情深度
#define MARKETDEPTH         /*marketDepth*/         @"marketDepth"          // 行情深度

#define REQTRADEDETAIL      /*reqTradeDetail*/      @"reqTradeDetail"       // 请求交易明细

#define MARKETDEPTHTOPDIFF  /*marketDepthTopDiff*/  @"marketDepthTopDiff"   // top行情深度差量
#define MARKETDEPTHDIFF     /*marketDepthDiff*/     @"marketDepthDiff"      // 行情深度差量

#define LASTKLINE           /*lastKLine*/           @"lastKLine"            // 最后一个k线
#define LASTTIMELINE        /*lastTimeLine*/        @"lastTimeLine"         // 最后一个分时

#define MARKETOVERVIEW      /*marketOverview*/      @"marketOverview"       // 市场概况
#define MARKETSTATIC        /*marketStatic*/        @"marketStatic"         // 市场统计信息

#define REQSYMBOLLIST       /*reqSymbolList*/       @"reqSymbolList"        // 请求交易代码列表
#define REQSYMBOLDETAIL     /*reqSymbolDetail*/     @"reqSymbolDetail"      // 请求交易代码详细信息
#define REQMSGSUBSCRIBLE    /*reqMsgSubscribe*/     @"reqMsgSubscribe"      // 推送消息订阅
#define REQMSGUNSUBSCRIBE   /*reqMsgUnsubscribe*/   @"reqMsgUnsubscribe"    // 推送消息取消订阅

#define REQTIMELINE         /*reqTimeLine*/         @"reqTimeLine"          // 请求分时线
#define REQKLINE            /*reqKLine*/            @"reqKLine"             // 请求k线
#define REQMARKETDEPTHTOP   /*reqMarketDepthTop*/   @"reqMarketDepthTop"    // 请求top行情深度
#define REQMERKETDEPTH      /*reqMarketDepth*/      @"reqMarketDepth"       // 请求行情深度
#define REQTRADEDETAILTOP   /*reqTradeDetailTop*/   @"reqTradeDetailTop"    // 请求top交易明细
#define REQMARKETDETAIL     /*reqMarketDetail*/     @"reqMarketDetail"      // 请求盘口信息

#define REQUEST             /*request*/             @"request"              // socket.io请求消息事件名称
#define MESSAGE             /*message*/             @"message"              // socket.io推送消息事件名称
/********************************************************************
 消息类型常量定义结束
 ********************************************************************/



// 推送策略常量定义
#define PUSHLONG    /*pushLong*/        @"pushLong"     // 长推送
#define PUSHSHORT    /*pushShort*/      @"pushShort"    // 短推送

// k线周期类型
#define  KLINE1MIN  /*kline1Min*/       @"1min"         // 1分钟k线
#define  KLINE5MIN  /*kline5Min*/       @"5min"         // 5分钟k线
#define  KLINE15MIN  /*kline15Min*/     @"15min"        // 15分钟k线
#define  KLINE30MIN  /*kline30Min*/     @"30min"        // 30分钟k线
#define  KLINE60MIN  /*kline60Min*/     @"60min"        // 60分钟k线
#define  KLINE1DAY  /*kline1Day*/       @"1day"         // 日k线
#define  KLINE1WEEK  /*kline1Week*/     @"1week"        // 周k线
#define  KLINE1MON  /*kline1Mon*/       @"1mon"         // 月k线
#define  KLINE1YEAR  /*kline1Year*/     @"1year"        // 年k线

#define  KLINETIMELINE /*klineTimeline*/ @"tl"          // 分时线




//#define SERVER_HUOBI_MARKET_IP        @"hq.huobi.com" //@"10.0.0.158"
//#define SERVER_HUOBI_MARKET_IP_SLOW   @"hq.huobi.com/slow" //@"10.0.0.158"
#define SERVER_MARKET_PORT 80


/********************************************************************
 json数据的字段名称定义，有需要新增字段请在后面添加
 ********************************************************************/
#define SYMBOLID                        @"symbolId"          // 交易代码
#define BINDS       /*bids:*/           @"bids"           // 10买单
#define ASKS        /*asks:*/           @"asks"           // 10卖单
#define TRADES      /*trades:*/         @"trades"           // 10交易单
#define PRICENEW    /*priceNew:*/       @"priceNew"           // 最新成交价
#define LEVEL       /*level:*/          @"level"            // ？
#define VOLUME      /*volume:*/         @"volume"            // 成交额
#define AMOUNT      /*amount:*/         @"amount"          // 成交量
#define TOTALAMOUNT /*totalAmount:*/    @"totalAmount"         // 成交总量
#define TOTALVOLUME /*totalVolume:*/    @"totalVolume"           // 成交额
#define AMP         /*amp:*/            @"amp"          // 振幅？
#define PRICEOPEN   /*priceOpen:*/      @"priceOpen"           // 开盘价
#define PRICEHIGH   /*priceHigh:*/      @"priceHigh"           // 最高价
#define PRICELOW    /*priceLow:*/       @"priceLow"           // 最低价
#define PRICELAST   /*priceLast:*/      @"priceLast"          // 收盘价
#define PRICENOW    /*priceNow:*/       @"priceNow"           // 当前价
#define PRICE        /*price:*/          @"price"            // 价格
#define PRICEBID    /*priceBid:*/       @"priceBid"           // 买入价
#define PRICEASK    /*priceAsk:*/       @"priceAsk"           // 卖出价
#define TOPBIDS     /*topBids:*/        @"topBids"          // 5买单
#define TOPASKS     /*topAsks:*/        @"topAsks"          // 5卖单
#define TRADEID     /*tradeId:*/        @"tradeId"          // 交易id
#define TIME        /*time:*/           @"time"            // 时间
#define TIMEMIN     /*timeMin:*/        @"timeMin"           // 最小时间
#define TIMEMAX     /*timeMax:*/        @"timeMax"           // 最大时间
#define BINDID      /*bidId:*/          @"bidId"          // 买单委托id
#define ASKID       /*askId:*/          @"askId"          // 卖单委托id
#define DIRECTION   /*direction:*/      @"direction"           // 交易方向：买入和卖出
#define VERSION     /*version:*/        @"version"          // 协议版本号
#define VERSIONOLD  /*versionOld:*/     @"versionOld"         // 旧版本号
#define BIDNAME     /*bidName:*/        @"bidName"           // 买单名称
#define BIDPRICE    /*bidPrice:*/       @"bidPrice"           // 买单价格
#define BIDAMOUNT   /*bidAmount:*/      @"bidAmount"         // 买单量
#define BIDTOTAL    /*bidTotal:*/       @"bidTotal"           // 买单累计量
#define ASKNAME     /*askName:*/        @"askName"           // 卖单名称 ?卖单名称是啥
#define ASKPRICE    /*askPrice:*/       @"askPrice"           // 卖单价格
#define ASKAMOUNT   /*askAmount:*/      @"askAmount"         // 卖单量
#define ASKTOTAL    /*askTotal:*/       @"askTotal"           // 买单累计量
#define PERIOD      /*period:*/         @"period"           // k线周期
#define DATE        /*date:*/           @"date"            // 日期
#define COUNT       /*count:*/          @"count"            // 交易次数
#define SYMBOLNAME  /*symbolName:*/         @"symbolName"     // 交易代码名称
#define EXCHANGEID  /*exchangeId:*/         @"exchangeId"     // 交易所id
#define EXCHANGENAME    /*exchangeName:*/   @"exchangeName"      // 交易所名称
#define CURRENCYID      /*currencyId:*/     @"currencyId"      // 现金id
#define CURRENCYNAME    /*currencyName:*/   @"currencyName"       // 现金名称
#define CRYPTOID        /*cryptoId:*/       @"cryptoId"     // 数字货币id
#define CRYPTONAME      /*cryptoName:*/     @"cryptoName"      // 数字货币名称
#define CRYPTONAMEZH    /*cryptoNameZh:*/   @"cryptoNameZh"    // 数字货币中文名称
#define TOTAL           /*total:*/          @"total"       // 总量
#define SUPLY           /*suply:*/          @"suply"       // 流通量
#define INTRODUCTION    /*introduction:*/   @"introduction"    // 介绍
#define MSGTYPE         /*msgType:*/        @"msgType"      // 消息类型
#define UNIQUEID        /*uniqueId:*/       @"uniqueId"      // 唯一id
#define IDCUR           /*idCur:*/          @"idCur"      // 当前数据包id
#define IDPREV          /*idPrev:*/         @"idPrev"      // 前一个数据包的id
#define PAYLOAD         /*payload:*/        @"payload"      // 有效数据字段
#define FROM            /*from:*/           @"from"       // 区间开始
#define TO              /*to:*/             @"to"       // 区间结束
#define REQUESTINDEX    /*requestIndex:*/   @"requestIndex"      // 请求序列号
#define PUSHTYPE        /*pushType:*/       @"pushType"       // 推送类型：长推，短推
#define SYMBOLLIST      /*symbolList:*/     @"symbolList"     // 交易代码列表
#define SYMBOLIDLIST    /*symbolIdList:*/   @"symbolIdList"   // 交易代码id列表
#define RETCODE         /*retCode:*/        @"retCode"       // 返回代码
#define RETMSG          /*retMsg:*/         @"retMsg"       // 返回消息
#define BIDINSERT       /*bidInsert:*/      @"bidInsert"       // 买单添加记录
#define BIDDELETE       /*bidDelete:*/      @"bidDelete"       // 买单删除记录
#define BIDUPDATE       /*bidUpdate:*/      @"bidUpdate"       // 买单更新记录
#define ASKINSERT       /*askInsert:*/      @"askInsert"       // 卖单添加记录
#define ASKDELETE       /*askDelete:*/      @"askDelete"       // 卖单删除记录
#define ASKUPDATE       /*askUpdate:*/      @"askUpdate"       // 卖单更新记录
#define COMMISSIONRATIO /*commissionRatio:*/@"commissionRatio"       // 委比
#define POOR            /*poor:*/           @"poor"       // 委差
#define UPDOWNVOLUME    /*updownVolume:*/   @"updownVolume"      // 涨跌量
#define UPDOWNRATION    /*updownRatio:*/    @"updownRatio"      // 涨跌幅
#define PRICEAVERAGE    /*priceAverage:*/   @"priceAverage"       // 均价
#define VOLUMERATION    /*volumeRatio:*/    @"volumeRatio"       // ？
#define AMOUNTRATIO     /*amountRatio:*/    @"amountRatio"       // 量比
#define TURNVALUME      /*turnVolume:*/     @"turnVolume"     // 金额？
#define TURNVOERRATE    /*turnoverRate:*/   @"turnoverRate"       // 换手
#define OUTERDISC       /*outerDisc:*/      @"outerDisc"       // 外盘
#define INNERDISC       /*innerDisc:*/      @"innerDisc"       // 内盘
#define PERCENT         /*percent:*/        @"percent"       // 百分比：主要用于行情深度
#define ACCUAMOUNT      /*accuAmount:*/     @"accuAmount"       // 累计委单量
#define KLINETYPE       /*klineType:*/      @"klineType"       // k线类型
#define INDEX           /*index:*/          @"index"        // 下角标
#define ROW             /*row:*/            @"row"        // 行数
#define INSERTLIST      /*insertList:*/     @"insertList"      // 添加
#define DELETELIST      /*deleteList:*/     @"deleteList"      // 删除
#define UPDATELIST      /*updateList:*/     @"updateList"      // 更新
#define TIMESTART       /*timeStart:*/      @"timeStart"      // 开始时间
#define TIMEEND         /*timeEnd:*/        @"timeEnd"      // 结束时间
#define TIMESERVER      /*timeServer:*/     @"timeServer"      // 生产服务器的时间
#define ISTEMP          /*isTemp:*/         @"isTemp"       // 临时k线
/********************************************************************
 json字段常量定义结束
 ********************************************************************/


#pragma mark - market notification
/************************************************************************************
 行情模块用到的notification
 ************************************************************************************/
#define NOTIFICATON_MARKET_DETAIL_UPDATE        @"NOTIFICATON_MARKET_DETAIL_UPDATE"

#define NOTIFICATON_MARKET_OVERVIEW_UPDATE      @"NOTIFICATON_MARKET_OVERVIEW_UPDATE"

#define NOTIFICATON_LSAT_KLINE_UPDATE           @"NOTIFICATON_LSAT_KLINE_UPDATE"

#define NOTIFICATON_LSAT_KLINE_VIEW_UPDATE      @"NOTIFICATON_LSAT_KLINE_VIEW_UPDATE"

#define NOTIFICATON_KLINE_UPDATE                @"NOTIFICATON_KLINE_UPDATE"

#define NOTIFICATON_KLINE_UPDATE_LOCAL          @"NOTIFICATON_KLINE_UPDATE_LOCAL"

#define NOTIFICATON_LSAT_TIMELINE_UPDATE        @"NOTIFICATON_LSAT_TIMELINE_UPDATE"

#define NOTIFICATON_TIMEKLINE_UPDATE            @"NOTIFICATON_TIMEKLINE_UPDATE"

#define NOTIFICATON_MARKETDEPTHTOPSHORT_UPDATE  @"NOTIFICATON_MARKETDEPTHTOPSHORT_UPDATE"

#define NOTIFICATON_KLINE_VIEW_UPDATE           @"NOTIFICATON_KLINE_VIEW_UPDATE"

#define NOTIFICATON_SOCKET_DIDCONNECTED         @"NOTIFICATON_SOCKET_DIDCONNECTED"

#define NOTIFICATON_REACHABLE_DIDCONNECTED      @"NOTIFICATON_REACHABLE_DIDCONNECTED"

#define NOTIFICATON_RELOAD_SYMBOLID             @"NOTIFICATON_RELOAD_SYMBOLID"

#define NOTIFICATON_REQUEST_SYMBOLID            @"NOTIFICATON_REQUEST_SYMBOLID"

#define NOTIFICATON_SERVER_DIDCONNECTED         @"NOTIFICATON_SERVER_DIDCONNECTED"

#define NOTIFICATON_TAB_SWITCH_MARKET           @"NOTIFICATON_TAB_SWITCH_MARKET"

#define NOTIFICATION_LAUNCH_FINISH              @"NOTIFICATION_LAUNCH_FINISH"

#define NOTIFICATION_STATUSBAR_UPDATE           @"NOTIFICATION_STATUSBAR_UPDATE"




#pragma mark - request index

#define REQUEST_INDEX_MARKET_OVERVIEW_BTC           @"103038520"

/******************************begin******************************/

#define REQUEST_INDEX_LAST_KLINE_BTC                @"103038521"

#define REQUEST_INDEX_LAST_KLINE_BTC_1MIN           @"1030385211"

#define REQUEST_INDEX_LAST_KLINE_BTC_5MIN           @"1030385212"

#define REQUEST_INDEX_LAST_KLINE_BTC_15MIN          @"1030385213"

#define REQUEST_INDEX_LAST_KLINE_BTC_30MIN          @"1030385214"

#define REQUEST_INDEX_LAST_KLINE_BTC_60MIN          @"1030385215"

#define REQUEST_INDEX_LAST_KLINE_BTC_1DAY           @"1030385216"

#define REQUEST_INDEX_LAST_KLINE_BTC_1WEEK          @"1030385217"

#define REQUEST_INDEX_LAST_KLINE_BTC_1MON           @"1030385218"

#define REQUEST_INDEX_LAST_KLINE_BTC_1YEAR          @"1030385219"

/******************************end******************************/

#define REQUEST_INDEX_REQ_KLINE_BTC                 @"103038522"

#define REQUEST_INDEX_TIME_LINE_BTC                 @"103038523"

#define REQUEST_INDEX_SYMBOLLIST_BTC                @"103038524"

#define REQUEST_INDEX_REQ_MARKETDEPTHTOPSHORT_BTC   @"103038525"



#define UNREQUEST_INDEX_MARKET_OVERVIEW_BTC           @"103038620"

#define UNREQUEST_INDEX_LAST_KLINE_BTC                @"103038621"

#define UNREQUEST_INDEX_REQ_KLINE_BTC                 @"103038622"

#define UNREQUEST_INDEX_TIME_LINE_BTC                 @"103038623"

#define UNREQUEST_INDEX_SYMBOLLIST_BTC                @"103038624"

#define UNREQUEST_INDEX_REQ_MARKETDEPTHTOPSHORT_BTC   @"103038625"

#define UNREQUEST_INDEX_MARKET_DETAIL_BTC             @"103038626"

#pragma mark - ltc

#define REQUEST_INDEX_MARKET_OVERVIEW_LTC           @"203038520"

/******************************begin******************************/

#define REQUEST_INDEX_LAST_KLINE_LTC                @"203038521"

#define REQUEST_INDEX_LAST_KLINE_LTC_1MIN           @"2030385211"

#define REQUEST_INDEX_LAST_KLINE_LTC_5MIN           @"2030385212"

#define REQUEST_INDEX_LAST_KLINE_LTC_15MIN          @"2030385213"

#define REQUEST_INDEX_LAST_KLINE_LTC_30MIN          @"2030385214"

#define REQUEST_INDEX_LAST_KLINE_LTC_60MIN          @"2030385215"

#define REQUEST_INDEX_LAST_KLINE_LTC_1DAY           @"2030385216"

#define REQUEST_INDEX_LAST_KLINE_LTC_1WEEK          @"2030385217"

#define REQUEST_INDEX_LAST_KLINE_LTC_1MON           @"2030385218"

#define REQUEST_INDEX_LAST_KLINE_LTC_1YEAR          @"2030385219"

/******************************end******************************/

#define REQUEST_INDEX_REQ_KLINE_LTC                 @"203038522"

#define REQUEST_INDEX_TIME_LINE_LTC                 @"203038523"

#define REQUEST_INDEX_SYMBOLLIST_LTC                @"203038524"

#define REQUEST_INDEX_REQ_MARKETDEPTHTOPSHORT_LTC   @"203038525"


#define UNREQUEST_INDEX_MARKET_OVERVIEW_LTC           @"203038620"

#define UNREQUEST_INDEX_LAST_KLINE_LTC                @"203038621"

#define UNREQUEST_INDEX_REQ_KLINE_LTC                 @"203038622"

#define UNREQUEST_INDEX_TIME_LINE_LTC                 @"203038623"

#define UNREQUEST_INDEX_SYMBOLLIST_LTC                @"203038624"

#define UNREQUEST_INDEX_REQ_MARKETDEPTHTOPSHORT_LTC   @"203038625"

#define UNREQUEST_INDEX_MARKET_DETAIL_LTC             @"203038626"





#pragma mark - constant define

#define KLINE_REFRESH_BATCH 0

#define KLINE_REFRESH_LASTKLINE 1

#define KLINE_LINEVIEW @"kline"

#define VOLUM_LINEVIEW @"VOLUM_LINEVIEW"

#define KLINE_COUNT 5

/************************************************************************************
 1日均线
 ************************************************************************************/
#define CONSTANT_MA1     1


/************************************************************************************
 5日均线
 ************************************************************************************/
#define CONSTANT_MA5     5

/************************************************************************************
 10日均线
 ************************************************************************************/
#define CONSTANT_MA10    10

/************************************************************************************
 20日均线
 ************************************************************************************/
#define CONSTANT_MA30    30

/************************************************************************************
 60日均线
 ************************************************************************************/
#define CONSTANT_MA60    60

#define SPACE_BETWEEN_KLINE_TAP 2

#define KLINE_LEFT_SPAN 10.0f

#define KLINE_RIGHT_SPAN 40.0f

#define MACD_MAX_VALUE MAXFLOAT



#define KLINE_TYPE_NONE 0

#define KLINE_TYPE_MA   1

#define KLINE_TYPE_BOLL 2

#define MACD_TYPE_NONE  0

#define MACD_TYPE_MACD  1

#define MACD_TYPE_KDJ   2

#define MACD_TYPE_RSI   3

#define MACD_TYPE_WR    4



#define FONTSIZE1             1.0f
#define FONTSIZE2             2.0f
#define FONTSIZE3             3.0f
#define FONTSIZE4             4.0f
#define FONTSIZE5             5.0f
#define FONTSIZE6             6.0f
#define FONTSIZE7             7.0f
#define FONTSIZE8             8.0f
#define FONTSIZE9             9.0f
#define FONTSIZE10            10.0f
#define FONTSIZE11            11.0f
#define FONTSIZE12            12.0f
#define FONTSIZE13            13.0f
#define FONTSIZE14            14.0f
#define FONTSIZE15            15.0f
#define FONTSIZE16            16.0f
#define FONTSIZE17            17.0f
#define FONTSIZE18            18.0f
#define FONTSIZE19            19.0f
#define FONTSIZE20            20.0f
#define FONTSIZE21            21.0f
#define FONTSIZE22            22.0f
#define FONTSIZE23            23.0f
#define FONTSIZE24            24.0f
#define FONTSIZE25            25.0f
#define FONTSIZE26            26.0f
#define FONTSIZE27            27.0f
#define FONTSIZE28            28.0f
#define FONTSIZE29            29.0f


#endif
