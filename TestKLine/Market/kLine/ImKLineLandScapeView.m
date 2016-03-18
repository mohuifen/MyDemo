//
//  ImKLineLandScapeView.m
//  Kline
//
//  Created by zhaomingxi on 14-2-9.
//  Copyright (c) 2014年 zhaomingxi. All rights reserved.
//

// http://ichart.yahoo.com/table.csv?s=399001.SZ&g=w  d,w,m  返回某个股票的天，星期，月等k线数据

#import "ImKLineLandScapeView.h"
#import "lines.h"
#import "UIColor+helper.h"
#import "ImDrawTask.h"
#import "ImKLineData.h"
#import "colorModel.h"
#import "DLMainManager.h"
#import "DLTextAttributeData.h"
#import "KlineConstant.h"
#import "ImHBLog.h"

#import "DirectionPanGestureRecognizer.h"
#import "ImScreenTouchesAction.h"

//#import "constants.h"

#import "ImKLineInfoView.h"

#define USE_CROSS_LINE 0

#define LANDSCAPE_TOP_SPAN 74/2

#define LANDSCAPE_BOTTOM_SPAN 38/2

#define AMOUNT_DETAIL_OFFSET 15



#define ITEM_INDEX_MACD_DIF 14

#define ITEM_INDEX_MACD_DEA 15

#define KLINE_EDGE_TOP  5.0f

#define KLINE_EDGE_BOTTOM  5.0f



#define TIME_BOX_HEIGHT 11.0f

#define LOWEST_LABEL_HEGIHT 20.0f

#define LOWEST_LABEL_WIDTH 60.0f

#define KLINE_VIEW_HEIGHT 284.0f

#define KLINE_AMOUNT_HEIGHT 55.0f

#define KLINE_MACD_HEIGHT 60.0f

#define KLINE_INFO_HEIGHT 30.0f

#define KLINE_ITEM_WIDTH 5.0f

#define KLINE_ITEM_PADDING 1.0f

#define Origin_X @"OriginX"

@interface ImKLineLandScapeView()
{
#pragma mark - frame
    CGRect _mainBoxFrame; // k线绘制区域
    CGRect _amountBoxFrame; // 成交量绘制区域
    CGRect _macdBoxFrame; // macd绘制区域
    CGRect _timeFrame;
    CGRect _spanFrame;
    
#pragma mark - action
    BOOL isUpdate;
    BOOL isUpdateFinish;
    NSInteger _nUpdateType;
    CGPoint _touchViewPoint;
    //当前总的移动数量
    NSInteger _nTotalOffset;
    BOOL isPinch;
    
    CGFloat _frontAmountMaxValue;
    CGFloat _frontAmountMinValue;
    
    //每次pan操作（begin,end）的移动数量
    NSInteger _nOffsetPerPan;
    
    CGFloat _nOffsetBegin;
#pragma mark - draw kline
    NSMutableArray* _taskArray;
    dispatch_queue_t _drawQueue;
    NSMutableArray *_pointArray; // k线所有坐标数组
    /**************上涨颜色**************/
    CGFloat _riseModalR;
    CGFloat _riseModalG;
    CGFloat _riseModalB;
    
    /**************下跌颜色**************/
    CGFloat _fallModalR;
    CGFloat _fallModalG;
    CGFloat _fallModalB;
    
    /**************均线颜色**************/
    CGFloat _whiteColor[3];
    
    CGFloat _yellowColor[3];
    
    CGFloat _qingColor[3];
    
    CGFloat _ziColor[3];
    
    ImKLineData* _kLineData;
    
#pragma mark - axis
    
    NSDateFormatter* _timeDateFormatter;
    
    NSDateFormatter* _crossDateFormatter;
    
    UILabel *amountMaxValueLab; // 显示成交量最大值
    
    UILabel *amountMiddleValueLab; // 显示成交量最大值
    
    UILabel* _amountMinValueLab;
    
    UILabel *_macdMaxValueLab; // 显示成交量最大值
    
    UILabel *_macdMiddleValueLab; // 显示成交量最大值
    
    UILabel* _macdMinValueLab;
    
#pragma mark - cross line
    
    CALayer* timelineone;
    
    CALayer* pricelinetwo;
    
    CALayer* _amountLastLayer;
    
    CALayer* _priceLastLayer;
    
    CALayer* zuobiaoLayer;
    
    CATextLayer* _amountLayer;
    
    CATextLayer* _amountMA5Layer;
    
    CATextLayer* _amountMA10Layer;
    
    CATextLayer* _titleLayer;
    
    CATextLayer* _macdLayer;
    
    CATextLayer* _difLayer;
    
    CATextLayer* _deaLayer;
    
    CATextLayer* _marketLayer;
    
    UILabel* timelineBottomLable;
    
    UILabel* pricelineLable;
    
    UILabel *_priceHighLab;
    
    UILabel *_priceLowLab;
    
    NSInteger _newScale;
    
    ImKLineInfoView* _infoView;
    
    NSInteger _contextCount;
}
@property (nonatomic,assign) CGFloat dataMaxValue;
@property (nonatomic,assign) CGFloat dataMinValue;
@property (nonatomic,assign) CGFloat frontAmountMaxValue;
@property (nonatomic,assign) CGFloat frontAmountMinValue;
@property (nonatomic,assign) CGFloat frontMACDMaxValue;
@property (nonatomic,assign) CGFloat frontMACDMinValue;
@property (nonatomic,assign) BOOL bFrontTimeLine;

@property (nonatomic,assign) int frontmainchatType;
@property (nonatomic,assign) int frontMACDType;

@property (nonatomic,assign) CGFloat frontKLineWidth;

@property (nonatomic,assign) CGFloat frontKLinePadding;

@end

@interface ImKLineLandScapeView(crossLine)
{
    
}
@end

@implementation ImKLineLandScapeView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        _drawQueue = dispatch_queue_create("drawDetailKLineQueue",DISPATCH_QUEUE_SERIAL);
        _timeDateFormatter = [[NSDateFormatter alloc] init];
        _crossDateFormatter = [[NSDateFormatter alloc] init];

        self.mainchatType = KLINE_TYPE_MA;
        _kLineData = [[ImKLineData alloc] init];
        [_kLineData setKLineView:self];
    
        self.font = [UIFont systemFontOfSize:8];
        isUpdate = NO;
        isUpdateFinish = YES;
        isPinch = NO;
        
        [self initGesture];
        
        [self initColor];
        
        self.finishUpdateBlock = ^(id self){
            [self didFinishUpdate];
        };
        
        self.kLineWidthTemp = KLINE_ITEM_WIDTH;
        self.kLinePaddingTemp = KLINE_ITEM_PADDING;
    }
    //else cont.
    
    return self;
}

- (void) initGesture
{
    //[self addSubview:mainboxView];
    // 添加手指捏合手势，放大或缩小k线图
    UIPinchGestureRecognizer* pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(touchBoxAction:)];
    [self addGestureRecognizer:pinchGesture];
    
    //添加长按手势，显示十字提示信息
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
    [longPressGestureRecognizer addTarget:self action:@selector(gestureRecognizerHandle:)];
    [longPressGestureRecognizer setMinimumPressDuration:0.3f];
    [longPressGestureRecognizer setAllowableMovement:50.0];
    [self addGestureRecognizer:longPressGestureRecognizer];
    
    DirectionPanGestureRecognizer *directPanGesture = [[DirectionPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerHandle:)];
    directPanGesture.direction = DirectionPanGestureRecognizerHorizontal;
    directPanGesture.minimumNumberOfTouches = 1;
    directPanGesture.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:directPanGesture];
    
    //添加tap手势,切换到横屏
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerHandle:)];
    [self addGestureRecognizer:tapGesture];
}

- (CGRect) getActivityIndicatorFrame
{
    return _mainBoxFrame;
}

-(void) initLandScapeSet
{
    self.kLineWidth = KLINE_ITEM_WIDTH;// k线实体的宽度
    self.kLinePadding = KLINE_ITEM_PADDING; // k实体的间隔
    NSInteger amountBoxHeight = self.bounds.size.height * (KLINE_AMOUNT_HEIGHT / KLINE_VIEW_HEIGHT); // 底部成交量图的高度
    if (MACD_TYPE_NONE == self.MACDType)
        self.macdBoxHeight = 0;
    else
        self.macdBoxHeight = self.bounds.size.height * (KLINE_MACD_HEIGHT / KLINE_VIEW_HEIGHT);

    self.mainWidth = self.bounds.size.width - KLINE_LEFT_SPAN - KLINE_RIGHT_SPAN; // k线图宽度
    
    self.mainHeight = self.bounds.size.height - amountBoxHeight - self.macdBoxHeight - TIME_BOX_HEIGHT; // k线图高度
    
    if (self.bFullScreenMode)
        _mainBoxFrame = CGRectMake(3, 0, self.mainWidth, self.mainHeight);
    else
        _mainBoxFrame = CGRectMake(KLINE_LEFT_SPAN, 0, self.mainWidth, self.mainHeight);
    
    _timeFrame = CGRectMake(_mainBoxFrame.origin.x - 1,
                            _mainBoxFrame.origin.y + _mainBoxFrame.size.height,
                            self.mainWidth + 1,
                            TIME_BOX_HEIGHT);
    
    NSInteger amountOriginY = _timeFrame.origin.y + _timeFrame.size.height;
    // 画个成交量的框框
    _amountBoxFrame = CGRectMake(_mainBoxFrame.origin.x,
                                 amountOriginY,
                                 self.mainWidth,
                                 amountBoxHeight);
    
    _spanFrame = CGRectMake(_amountBoxFrame.origin.x - 1,
                            _amountBoxFrame.origin.y + _amountBoxFrame.size.height,
                            self.mainWidth + 1.0f,
                            6.0f);
    
    // 画个成交量的框框
    _macdBoxFrame = CGRectMake(_mainBoxFrame.origin.x,
                               _spanFrame.origin.y + _spanFrame.size.height,
                               self.mainWidth,
                               self.macdBoxHeight - _spanFrame.size.height);
    
    [self resetAmountItem];
    [self resetLastPriceLayer];
    [self initHighAndLowLab];
    [self resetMACDItem];
    
    CGRect frame = self.bounds;
    frame.size.height = KLINE_INFO_HEIGHT;
    if(!_infoView)
    {
        _infoView = [[ImKLineInfoView alloc] initWithFrame:frame];
        _infoView.backgroundColor = [UIColor clearColor];
        [self addSubview:_infoView];
    }
    else
        [_infoView setFrame:frame];
        
    if (pricelinetwo)
    {
        [pricelinetwo removeFromSuperlayer];
        pricelinetwo = nil;
    }
    
    if (timelineone)
    {
        [timelineone removeFromSuperlayer];
        timelineone = nil;
    }
    
    
}

- (void) initHighAndLowLab
{
    if (!_priceHighLab)
    {
        CGFloat originX = _mainBoxFrame.origin.x;
        CGFloat originY = _mainBoxFrame.origin.y;
        
        CGRect theRect = CGRectMake(originX, originY, LOWEST_LABEL_WIDTH, LOWEST_LABEL_HEGIHT);
        _priceHighLab = [[UILabel alloc] initWithFrame:theRect];
        _priceHighLab.textColor = [UIColor colorWithHexString:@"7c7c7c" withAlpha:1.0];
        _priceHighLab.backgroundColor = [UIColor clearColor];
        _priceHighLab.font = [UIFont systemFontOfSize:FONTSIZE7];
        [self addSubview:_priceHighLab];
    }
    //else cont.
    
    _priceHighLab.hidden = self.bTimeLine;
    
    if (!_priceLowLab)
    {
        CGFloat originX = _mainBoxFrame.origin.x;
        CGFloat originY = _mainBoxFrame.origin.y + _mainBoxFrame.size.height - LOWEST_LABEL_HEGIHT;
        CGRect theRect = CGRectMake(originX, originY, LOWEST_LABEL_WIDTH, LOWEST_LABEL_HEGIHT);
        _priceLowLab = [[UILabel alloc] initWithFrame:theRect];
        _priceLowLab.textColor = [UIColor colorWithHexString:@"7c7c7c" withAlpha:1.0];
        _priceLowLab.font = [UIFont systemFontOfSize:FONTSIZE7];
        _priceLowLab.backgroundColor = [UIColor clearColor];
        [self addSubview:_priceLowLab];
    }
    //else cont.
    
    _priceLowLab.hidden = self.bTimeLine;
}

- (void) setRGBColorWithContext:(CGContextRef)context bRise:(BOOL)bRise
{
//    if([commond isChinese])
//    {
        if (bRise)
        {
            CGContextSetRGBStrokeColor(context, _riseModalR, _riseModalG, _riseModalB, self.alpha);

        }
        else
        {
            CGContextSetRGBStrokeColor(context, _fallModalR, _fallModalG, _fallModalB, self.alpha);
        }//endi
    /*
    }
    else
    {
        if (bRise)
        {
            CGContextSetRGBStrokeColor(context, _fallModalR, _fallModalG, _fallModalB, self.alpha);

        }
        else
        {
            CGContextSetRGBStrokeColor(context, _riseModalR, _riseModalG, _riseModalB, self.alpha);

        }//endi
    }//endi
     */
}

- (void) initColor
{
    // 设置默认红色
    ColorModel *redColormodel = [UIColor RGBWithHexString:@"#cd2627" withAlpha:self.alpha];
     _riseModalR = (CGFloat)redColormodel.R/255.0f;
     _riseModalG = (CGFloat)redColormodel.G/255.0f;
     _riseModalB = (CGFloat)redColormodel.B/255.0f;
    
    // 设置为绿色
    ColorModel* greenColormodel = [UIColor RGBWithHexString:@"#05e47a" withAlpha:self.alpha];
     _fallModalR = (CGFloat)greenColormodel.R/255.0f;
     _fallModalG = (CGFloat)greenColormodel.G/255.0f;
     _fallModalB = (CGFloat)greenColormodel.B/255.0f;
    
    // 白色k线
    ColorModel *whitemodel = [UIColor RGBWithHexString:@"#FFFFFF" withAlpha:self.alpha]; // 设置颜色
    _whiteColor[0] = (CGFloat)whitemodel.R/255.0f;
    _whiteColor[1] = (CGFloat)whitemodel.G/255.0f;
    _whiteColor[2] = (CGFloat)whitemodel.B/255.0f;
    
    // 黄色k线
    ColorModel *yellowmodel = [UIColor RGBWithHexString:@"#fffc00" withAlpha:self.alpha]; // 设置颜色
    _yellowColor[0] = (CGFloat)yellowmodel.R/255.0f;
    _yellowColor[1] = (CGFloat)yellowmodel.G/255.0f;
    _yellowColor[2] = (CGFloat)yellowmodel.B/255.0f;
    
    // 黄色k线
    ColorModel *qingmodel = [UIColor RGBWithHexString:@"#1ae405" withAlpha:self.alpha]; // 设置颜色
    _qingColor[0] = (CGFloat)qingmodel.R/255.0f;
    _qingColor[1] = (CGFloat)qingmodel.G/255.0f;
    _qingColor[2] = (CGFloat)qingmodel.B/255.0f;
    
    ColorModel *zimodel = [UIColor RGBWithHexString:@"#ff0095" withAlpha:self.alpha]; // 设置颜色
    _ziColor[0] = (CGFloat)zimodel.R/255.0f;
    _ziColor[1] = (CGFloat)zimodel.G/255.0f;
    _ziColor[2] = (CGFloat)zimodel.B/255.0f;
    
}

-(void)dealloc{
}

#pragma mark - 画框框和平均线
- (void) resetLastPriceLayer
{
    CGFloat fontSize = FONTSIZE8;
    NSDictionary* valueAttribute = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize],
                                     NSForegroundColorAttributeName:[UIColor whiteColor]};
    CGSize valueSize = [DLTextAttributeData sizeOfString:@"2267" withDict:valueAttribute];
    
    CGFloat theOriginX = _mainBoxFrame.origin.x + _mainBoxFrame.size.width;
    CGRect priceFrame = CGRectMake(theOriginX, self.mainHeight / 2, self.frame.size.width - theOriginX, 16);
    if (!_priceLastLayer)
    {
        _priceLastLayer = [CALayer layer];
        [self.layer addSublayer:_priceLastLayer];
        _priceLastLayer.contents = (__bridge id)[UIImage imageNamed:@"market_kline_arrowlabel"].CGImage;
        [_priceLastLayer setFrame:priceFrame];
        

        CGRect valueFrame = CGRectMake(0, (_priceLastLayer.frame.size.height - valueSize.height)/2, _priceLastLayer.frame.size.width, valueSize.height);
        //显示数值
        CATextLayer* priceValueLayer = [CATextLayer layer];
        [_priceLastLayer addSublayer:priceValueLayer];
        priceValueLayer.name = @"priceValue";
        [priceValueLayer setFrame:valueFrame];
        priceValueLayer.foregroundColor = [UIColor whiteColor].CGColor;
        priceValueLayer.font = CGFontCreateWithFontName((CFStringRef)[UIFont boldSystemFontOfSize:7.0f].fontName);
        priceValueLayer.string = @"-";
        priceValueLayer.fontSize = fontSize;
        priceValueLayer.contentsScale = 2.0f;
        priceValueLayer.alignmentMode = kCAAlignmentCenter;
        priceValueLayer.actions = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"contents", nil];
    }
    else
        [_priceLastLayer setFrame:priceFrame];
    
    _priceLastLayer.hidden = NO;
    
    CGFloat theOriginY = _amountBoxFrame.origin.y + _amountBoxFrame.size.height / 2;
    CGRect amountFrame = CGRectMake(theOriginX, theOriginY, self.frame.size.width - theOriginX, 16);
    if (!_amountLastLayer)
    {
        _amountLastLayer = [CALayer layer];
        [self.layer addSublayer:_amountLastLayer];
        _amountLastLayer.contents = (__bridge id)[UIImage imageNamed:@"market_kline_arrowlabel"].CGImage;
        [_amountLastLayer setFrame:amountFrame];
        
        
        CGRect valueFrame = CGRectMake(0, (_amountLastLayer.frame.size.height - valueSize.height)/2, _amountLastLayer.frame.size.width, valueSize.height);
        //显示数值
        CATextLayer* amountValueLayer = [CATextLayer layer];
        [_amountLastLayer addSublayer:amountValueLayer];
        amountValueLayer.name = @"amountValue";
        [amountValueLayer setFrame: valueFrame];
        amountValueLayer.foregroundColor = [UIColor whiteColor].CGColor;

        amountValueLayer.font = CGFontCreateWithFontName((CFStringRef)[UIFont boldSystemFontOfSize:7.0f].fontName);
        amountValueLayer.string = @"-";
        amountValueLayer.fontSize = 7.0f;
        amountValueLayer.contentsScale = 2.0f;
        amountValueLayer.alignmentMode = kCAAlignmentCenter;
        amountValueLayer.actions = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"contents", nil];

    }
    else
        [_amountLastLayer setFrame:amountFrame];
    
    _amountLastLayer.hidden = NO;
}

- (void) resetAmountItem
{
    NSInteger detailOffset = AMOUNT_DETAIL_OFFSET;
    
    // 显示成交量最大值
    if (amountMaxValueLab == nil) {
        CGFloat theLeft = _amountBoxFrame.origin.x + _amountBoxFrame.size.width + SPACE_BETWEEN_KLINE_TAP;
        amountMaxValueLab = [[UILabel alloc] initWithFrame:CGRectMake(theLeft,
                                                                      _amountBoxFrame.origin.y + detailOffset,
                                                                      self.frame.size.width - _amountBoxFrame.size.width - 2,
                                                                      self.font.lineHeight)];
        amountMaxValueLab.font = self.font;
        amountMaxValueLab.text = @"0";
        amountMaxValueLab.textColor = [UIColor colorWithHexString:@"535d6a" withAlpha:1];
        amountMaxValueLab.backgroundColor = [UIColor clearColor];
        amountMaxValueLab.textAlignment = NSTextAlignmentLeft;
        [self addSubview:amountMaxValueLab];
    }
    else
    {

        
        CGFloat theLeft = _amountBoxFrame.origin.x + _amountBoxFrame.size.width + SPACE_BETWEEN_KLINE_TAP;
        [amountMaxValueLab setFrame:CGRectMake(theLeft,
                                               _amountBoxFrame.origin.y + detailOffset,
                                               self.frame.size.width - _amountBoxFrame.size.width - 2,
                                               self.font.lineHeight)];
    }//endi
    
    if (!amountMiddleValueLab)
    {
        amountMiddleValueLab = [[UILabel alloc] initWithFrame:CGRectMake(amountMaxValueLab.frame.origin.x,
                                                                         _amountBoxFrame.origin.y + detailOffset + (_amountBoxFrame.size.height - detailOffset)/2 - self.font.lineHeight/2,
                                                                         self.frame.size.width - _amountBoxFrame.size.width - 2,
                                                                         self.font.lineHeight)];
        amountMiddleValueLab.font = self.font;
        amountMiddleValueLab.text = @"0";
        amountMiddleValueLab.textColor = [UIColor colorWithHexString:@"535d6a" withAlpha:1];
        amountMiddleValueLab.backgroundColor = [UIColor clearColor];
        amountMiddleValueLab.textAlignment = NSTextAlignmentLeft;
        
        [self addSubview:amountMiddleValueLab];
    }
    else
    {
        [amountMiddleValueLab setFrame:CGRectMake(amountMaxValueLab.frame.origin.x,
                                                  _amountBoxFrame.origin.y + detailOffset + (_amountBoxFrame.size.height - detailOffset)/2 - self.font.lineHeight/2,
                                                  self.frame.size.width - _amountBoxFrame.size.width - 2,
                                                  self.font.lineHeight)];
    }
    
    if (!_amountMinValueLab)
    {
        _amountMinValueLab = [[UILabel alloc] initWithFrame:CGRectMake(amountMaxValueLab.frame.origin.x,
                                                                       _amountBoxFrame.origin.y + _amountBoxFrame.size.height - self.font.lineHeight,
                                                                       self.frame.size.width - _amountBoxFrame.size.width - 2,
                                                                       self.font.lineHeight)];
        _amountMinValueLab.font = self.font;
        _amountMinValueLab.text = @"0";
        _amountMinValueLab.textColor = [UIColor colorWithHexString:@"535d6a" withAlpha:1];
        _amountMinValueLab.backgroundColor = [UIColor clearColor];
        _amountMinValueLab.textAlignment = NSTextAlignmentLeft;
        
        [self addSubview:_amountMinValueLab];
    }
    else
    {
        [_amountMinValueLab setFrame:CGRectMake(amountMaxValueLab.frame.origin.x,
                                                _amountBoxFrame.origin.y + _amountBoxFrame.size.height - self.font.lineHeight,
                                                self.frame.size.width - _amountBoxFrame.size.width - 2,
                                                self.font.lineHeight)];
    }//endi
}


- (void) resetMACDItem
{
    CALayer* spanLayer = [DLTextAttributeData getSubLayerOfLayer:self.layer withLayerName:@"SPAN_MACD"];
    if (!spanLayer)
    {
        spanLayer = [CALayer layer];
        [spanLayer setFrame:_spanFrame];
        spanLayer.name = @"SPAN_MACD";
        spanLayer.backgroundColor = [UIColor colorWithHexString:@"#20232b" withAlpha:1].CGColor;
    }
    else
    {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0];
        [spanLayer setFrame:_spanFrame];
        [CATransaction commit];
    }
    
    if (MACD_TYPE_NONE != self.MACDType)
    {
        [self.layer addSublayer:spanLayer];
    }
    else
    {
        [spanLayer removeFromSuperlayer];
    }
    
    
    NSInteger detailOffset = AMOUNT_DETAIL_OFFSET;
    
    // 显示成交量最大值
    if (_macdMaxValueLab == nil) {
        CGFloat theLeft = _macdBoxFrame.origin.x + _macdBoxFrame.size.width + SPACE_BETWEEN_KLINE_TAP;
        _macdMaxValueLab = [[UILabel alloc] initWithFrame:CGRectMake(theLeft,
                                                                      _macdBoxFrame.origin.y + detailOffset,
                                                                      self.frame.size.width - _macdBoxFrame.size.width - 2,
                                                                      self.font.lineHeight)];
        _macdMaxValueLab.font = self.font;
        _macdMaxValueLab.text = @"0";
        _macdMaxValueLab.textColor = [UIColor colorWithHexString:@"535d6a" withAlpha:1];
        _macdMaxValueLab.backgroundColor = [UIColor clearColor];
        _macdMaxValueLab.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_macdMaxValueLab];
    }
    else
    {
        
        
        CGFloat theLeft = _macdBoxFrame.origin.x + _macdBoxFrame.size.width + SPACE_BETWEEN_KLINE_TAP;
        [_macdMaxValueLab setFrame:CGRectMake(theLeft,
                                               _macdBoxFrame.origin.y + detailOffset,
                                               self.frame.size.width - _macdBoxFrame.size.width - 2,
                                               self.font.lineHeight)];
    }//endi
    
    if (!_macdMiddleValueLab)
    {
        _macdMiddleValueLab = [[UILabel alloc] initWithFrame:CGRectMake(_macdMaxValueLab.frame.origin.x,
                                                                         _macdBoxFrame.origin.y + detailOffset + (_macdBoxFrame.size.height - detailOffset)/2 - self.font.lineHeight/2,
                                                                         self.frame.size.width - _macdBoxFrame.size.width - 2,
                                                                         self.font.lineHeight)];
        _macdMiddleValueLab.font = self.font;
        _macdMiddleValueLab.text = @"0";
        _macdMiddleValueLab.textColor = [UIColor colorWithHexString:@"535d6a" withAlpha:1];
        _macdMiddleValueLab.backgroundColor = [UIColor clearColor];
        _macdMiddleValueLab.textAlignment = NSTextAlignmentLeft;
        
        [self addSubview:_macdMiddleValueLab];
    }
    else
    {
        [_macdMiddleValueLab setFrame:CGRectMake(_macdMaxValueLab.frame.origin.x,
                                                  _macdBoxFrame.origin.y + detailOffset + (_macdBoxFrame.size.height - detailOffset)/2 - self.font.lineHeight/2,
                                                  self.frame.size.width - _macdBoxFrame.size.width - 2,
                                                  self.font.lineHeight)];
    }
    
    if (!_macdMinValueLab)
    {
        _macdMinValueLab = [[UILabel alloc] initWithFrame:CGRectMake(_macdMaxValueLab.frame.origin.x,
                                                                       _macdBoxFrame.origin.y + _macdBoxFrame.size.height - self.font.lineHeight,
                                                                       self.frame.size.width - _macdBoxFrame.size.width - 2,
                                                                       self.font.lineHeight)];
        _macdMinValueLab.font = self.font;
        _macdMinValueLab.text = @"0";
        _macdMinValueLab.textColor = [UIColor colorWithHexString:@"535d6a" withAlpha:1];
        _macdMinValueLab.backgroundColor = [UIColor clearColor];
        _macdMinValueLab.textAlignment = NSTextAlignmentLeft;
        
        [self addSubview:_macdMinValueLab];
    }
    else
    {
        [_macdMinValueLab setFrame:CGRectMake(_macdMaxValueLab.frame.origin.x,
                                                _macdBoxFrame.origin.y + _macdBoxFrame.size.height - self.font.lineHeight,
                                                self.frame.size.width - _macdBoxFrame.size.width - 2,
                                                self.font.lineHeight)];
    }//endi
    
}


#pragma mark 更新界面等信息

- (void) createPriceCrossLine
{
    if (pricelinetwo == nil)
    {
        pricelinetwo =  [CALayer layer];
        [pricelinetwo setFrame:CGRectMake(_mainBoxFrame.origin.x,
                                          0,
                                          _mainBoxFrame.size.width,
                                          0.5)];
        
        pricelinetwo.backgroundColor = [UIColor whiteColor].CGColor;
        pricelinetwo.hidden = YES;
        [self.layer addSublayer:pricelinetwo];
        
    }
    //else cont.
    
    if (pricelineLable == nil)
    {
        CGRect twoFrame = pricelinetwo.frame;
        twoFrame.size = CGSizeMake(KLINE_RIGHT_SPAN, 12);
        pricelineLable = [[UILabel alloc] initWithFrame:twoFrame];
        pricelineLable.font = self.font;
        pricelineLable.layer.cornerRadius = 5;
        pricelineLable.backgroundColor = [UIColor whiteColor];
        pricelineLable.textColor = [UIColor colorWithHexString:@"#333333" withAlpha:1];
        pricelineLable.textAlignment = NSTextAlignmentCenter;
        pricelineLable.hidden = YES;
        [self addSubview:pricelineLable];
    }
    //else
}

- (void) createTimeCrossLine
{
    
    if (timelineone == nil) {
        
        timelineone = [CALayer layer];
        CGRect timeFrame = CGRectZero;
        timeFrame.origin.x = 0;
        timeFrame.origin.y = _mainBoxFrame.origin.y + 1;
        timeFrame.size.width = 0.5;
        timeFrame.size.height = _macdBoxFrame.origin.y + _macdBoxFrame.size.height - timeFrame.origin.y;
        timelineone.frame = timeFrame;
        
        timelineone.backgroundColor = [UIColor whiteColor].CGColor;
        [self.layer addSublayer:timelineone];
        timelineone.hidden = YES;
    }
    //else cont.
    
    

    if (timelineBottomLable == nil) {
        
        NSDictionary* timeAttribute = [[DLMainManager sharedTextAttributeData] getKLineTimeAttributeDict];
        CGSize textSize = [DLTextAttributeData sizeOfString:@" YYYY:MM:dd HH:mm:ss " withDict:timeAttribute];
        CGRect oneFrame = CGRectMake(0,
                                     _mainBoxFrame.origin.y,
                                     textSize.width,
                                     self.bounds.size.height - _macdBoxFrame.origin.y - _macdBoxFrame.size.height - 1.0f);
        timelineBottomLable = [[UILabel alloc] initWithFrame:oneFrame];
        timelineBottomLable.font = [UIFont systemFontOfSize:8.0f];
        timelineBottomLable.layer.cornerRadius = 5;
        timelineBottomLable.backgroundColor = [UIColor whiteColor];
        timelineBottomLable.textColor = [UIColor colorWithHexString:@"#333333" withAlpha:1];
        timelineBottomLable.textAlignment = NSTextAlignmentCenter;
        timelineBottomLable.alpha = 0.8;
        timelineBottomLable.hidden = YES;
        [self addSubview:timelineBottomLable];
    }
    //else cont.
}

-(void) didFinishUpdate
{
    [self createPriceCrossLine];
    
    [self createTimeCrossLine];
    
    if (zuobiaoLayer == nil)
    {
        zuobiaoLayer =  [CALayer layer];
        UIImage* zuobiaoImage = [UIImage imageNamed:@"market_coordinate"];
        [zuobiaoLayer setFrame:CGRectMake(_mainBoxFrame.origin.x,
                                          0,
                                          zuobiaoImage.size.width,
                                          zuobiaoImage.size.height)];
        zuobiaoLayer.contents = (__bridge id)zuobiaoImage.CGImage;
        
        zuobiaoLayer.hidden = YES;
        [self.layer addSublayer:zuobiaoLayer];
    }
    //else cont.
    
    if (!timelineone.hidden)
    {
        [self isTapWithPoint:_touchViewPoint bFromTap:NO];
    }
    //else cont.
    
    if (0 == _nTotalOffset)
    {
        _amountLastLayer.hidden = NO;
        _priceLastLayer.hidden = NO;
        NSDictionary* item = [self.data lastObject];
        [self refreshLastPrice:[item objectForKey:PRICELAST] andLastAmount:[item objectForKey:AMOUNT] bOnlyMove:NO];
    }
    else
    {
        NSDictionary* item = [self.data lastObject];
        [self refreshLastPrice:[item objectForKey:PRICELAST] andLastAmount:[item objectForKey:AMOUNT] bOnlyMove:YES];
    }
}

#pragma mark - reload data and refresh view
-(void) start{
    [self appendBackDataToQueue:KLINE_REFRESH_BATCH];
}

#pragma mark - reset view and refresh
- (void) resetKLineViewWithPeriod:(NSString*)strPeriod
{
    _nOffsetBegin = 0;
    _nTotalOffset = 0;
    _nOffsetPerPan = 0;
    self.kLineWidth = 5;// k线实体的宽度
    self.kLinePadding = 1.0f;
    
    _priceHighLab.hidden = YES;
    _priceLowLab.hidden = YES;
    
    self.kCount = self.mainWidth / (self.kLineWidth + self.kLinePadding); // K线中实体的总数
    _kLineData.kCount = self.kCount;
    _kLineData.mainchatType = self.mainchatType;

    _kLineData.MACDType = self.MACDType;
    _kLineData.offsetCount = 0;
    
    CATextLayer* priceValueLayer = (CATextLayer*)[DLTextAttributeData getSubLayerOfLayer:_priceLastLayer withLayerName:@"priceValue"];
    priceValueLayer.string = @"-";
    
    CATextLayer* amountValueLayer = (CATextLayer*)[DLTextAttributeData getSubLayerOfLayer:_amountLastLayer withLayerName:@"amountValue"];
    amountValueLayer.string = @"-";
    
    //MARK: 请求数据
    if ([self.delegate respondsToSelector:@selector(requestKLineWithPeriod:)])
        [self.delegate requestKLineWithPeriod:strPeriod];
    //else cont.
}

- (void) reloadKLineViewWithPeriod:(NSString*)strPeriod
{
    _nOffsetBegin = 0;
    _nTotalOffset = 0;
    _nOffsetPerPan = 0;
    self.kLineWidth = 5;// k线实体的宽度
    self.kLinePadding = 1.0f;
    
    self.kCount = self.mainWidth / (self.kLineWidth+self.kLinePadding); // K线中实体的总数
    _kLineData.kCount = self.kCount;
    _kLineData.mainchatType = self.mainchatType;
    _kLineData.MACDType = self.MACDType;
    _kLineData.offsetCount = 0;
    
    if ([self.delegate respondsToSelector:@selector(reloadKLineWithPeriod:)])
        [self.delegate reloadKLineWithPeriod:strPeriod];
    //else cont.
}

- (CGFloat) getAmountSpan
{
    CGFloat result = 0;
    result = self.frontAmountMaxValue - self.frontAmountMinValue;
    if (result == 0)
    {
        result = -1;
    }
    return result;
}

- (void) refreshLastPrice:(NSNumber*)lastPrice andLastAmount:(NSNumber*)lastAmount bOnlyMove:(BOOL)bOnlyMove
{
    if (lastPrice)
    {
        if([lastPrice doubleValue] != MAXFLOAT)
        {
            CATextLayer* spanLayer = (CATextLayer*)[DLTextAttributeData getSubLayerOfLayer:_priceLastLayer withLayerName:@"priceValue"];
            CGFloat nPriceValue = [lastPrice doubleValue];
            if (!bOnlyMove)
            {
                spanLayer.string = [DLTextAttributeData stringFromPrice:[lastPrice stringValue]];
            }
            else
                nPriceValue = [spanLayer.string doubleValue];
            
            if (self.frontMinValue <= nPriceValue && nPriceValue <= self.frontMaxValue )
            {
                // 换算成实际的坐标
                CGFloat priceY = [self yAxisFromPrice:nPriceValue mainHeight:_mainBoxFrame.size.height];
                CGRect priceFrame = _priceLastLayer.frame;
                priceFrame.origin.y = priceY - _priceLastLayer.frame.size.height / 2;
                [_priceLastLayer setFrame:priceFrame];
                _priceLastLayer.hidden = NO;
            }
            else
            {
                _priceLastLayer.hidden = YES;
            }//endi

        }
        else
            HB_LOG(@"error!");
    }
    else
        HB_LOG(@"error!");
    
    
    if (lastAmount)
    {
        NSInteger nCrollLineHeight = 15.0f;
        
        CGFloat mainHeight = _amountBoxFrame.size.height - nCrollLineHeight - 1.0f;
        CGFloat mainY = _amountBoxFrame.origin.y + _amountBoxFrame.size.height - 1.0f;
        
        CATextLayer* spanLayer = (CATextLayer*)[DLTextAttributeData getSubLayerOfLayer:_amountLastLayer withLayerName:@"amountValue"];
        CGFloat nAmountValue = [lastAmount doubleValue];
        if (!bOnlyMove)
            spanLayer.string = [self changePrice:nAmountValue];
        else
            nAmountValue = [spanLayer.string doubleValue];
        
        if ( nAmountValue >= 0 )
        {
            if (0 <= nAmountValue && nAmountValue <= self.frontAmountMaxValue )
            {
                CGFloat valuePercent = (nAmountValue - self.frontAmountMinValue) / [self getAmountSpan];
                CGFloat currentPointY =  mainY - valuePercent * mainHeight;
                
                CGRect amountFrame = _amountLastLayer.frame;
                amountFrame.origin.y = currentPointY - _amountLastLayer.frame.size.height/2;
                [_amountLastLayer setFrame:amountFrame];
                
                _amountLastLayer.hidden = NO;
            }
            else
            {
                _amountLastLayer.hidden = YES;
            }//endi
        }
        else
        {
            HB_LOG(@"error!");
        }
    }
    else
        HB_LOG(@"error!");
}
// 数值变化
-(NSString*)changePrice:(double)price{
    double newPrice = 0;
    NSString *danwei = @"";
    NSString *newstr = @"0";
    
    if (price > 100000000)
    {
        newPrice = price / 100000000 ;
        danwei = NSLocalizedString(@"SR_AHundredMillion", @"");
        newstr = [[NSString alloc] initWithFormat:@"%.0f%@",newPrice,danwei];
    }
    else if (price > 10000000)
    {
        newPrice = price / 10000000 ;
        danwei = NSLocalizedString(@"SR_MillionsAndMillions", @"");
        newstr = [[NSString alloc] initWithFormat:@"%.0f%@",newPrice,danwei];
    }
    else if (price > 100000)
    {
        newPrice = price / 10000 ;
        danwei = NSLocalizedString(@"SR_TenThousand", @"");
        newstr = [[NSString alloc] initWithFormat:@"%.0f%@",newPrice,danwei];
    }
    else if (price > 10000)
    {
        newPrice = price / 10000 ;
        danwei = NSLocalizedString(@"SR_TenThousand", @"");
        newstr = [[NSString alloc] initWithFormat:@"%.1f%@",newPrice,danwei];
    }
    else
    {
        newPrice = price;
        newstr = [[NSString alloc] initWithFormat:@"%.1f%@",newPrice,danwei];
    }//endi
    
    return newstr;
}

#pragma mark - refresh view
- (void) addRefreshTask:(NSInteger)nUpdateType
{
    if (!_taskArray)
    {
        _taskArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    //else cont.

    if (isUpdateFinish)
    {
        ImDrawTask* newTask = [[ImDrawTask alloc] init];
        newTask.updateType = nUpdateType;
        newTask.bTimeLine = self.bTimeLine;
        if (!_kLineData.backData) {
            newTask.data = nil;
            newTask.frontMaxValue = 0;
            newTask.frontMinValue = 0;
            newTask.frontAmountMaxValue = 0;
            newTask.frontAmountMinValue = 0;
            newTask.mainchatType = KLINE_TYPE_MA;
            newTask.MACDType = MACD_TYPE_MACD;
            newTask.MACDMinValue = 0;
            newTask.MACDMaxValue = 0;
        }
        else
        {
            newTask.data = _kLineData.backData.copy;
            newTask.frontMaxValue = _kLineData.maxValue;
            newTask.frontMinValue = _kLineData.minValue;
            newTask.bollMaxValue = _kLineData.bollMaxValue;
            newTask.bollMinValue = _kLineData.bollMinValue;
            newTask.frontAmountMaxValue = _kLineData.amountMaxValue;
            newTask.frontAmountMinValue = _kLineData.amountMinValue;
            newTask.mainchatType = self.mainchatType;
            newTask.MACDType = self.MACDType;
            newTask.MACDMinValue = _kLineData.MACDMinValue;
            newTask.MACDMaxValue = _kLineData.MACDMaxValue;
            newTask.kLineWidth = self.kLineWidth;
            newTask.kLinePadding = self.kLinePadding;
        }//endi
        
        [_taskArray addObject:newTask];
    }
    else
    {
        [_taskArray removeAllObjects];
    }
    
}

- (void) popRefreshTask:(ImKLineLandScapeView*)weakSelf
{
    if (isUpdateFinish)
    {
        isUpdateFinish = NO;
        
        //重置线程过程中的标识
        if (weakSelf.kLineWidth > 20)
            weakSelf.kLineWidth = 20;
        //else cont.
        
        if (weakSelf.kLineWidth < 1)
            weakSelf.kLineWidth = 1;
        //else cont.
        
        //恢复数据
        ImDrawTask* newTask = [_taskArray firstObject];
        

        isUpdate = YES;
        weakSelf.data = nil;
        weakSelf.clearsContextBeforeDrawing = YES;
        
        _nUpdateType = newTask.updateType;
        if (KLINE_REFRESH_BATCH == _nUpdateType)
            _pointArray = nil;
        //else cont.
        
        weakSelf.bFrontTimeLine = newTask.bTimeLine;
        if (!newTask.data)
        {
            weakSelf.data = nil;
            weakSelf.frontMaxValue = 0;
            weakSelf.frontMinValue = 0;
            weakSelf.dataMaxValue = 0;
            weakSelf.dataMinValue = 0;
            weakSelf.frontAmountMaxValue = 0;
            weakSelf.frontAmountMinValue = 0;
            weakSelf.frontmainchatType = KLINE_TYPE_MA;
            weakSelf.frontMACDType = MACD_TYPE_MACD;
            weakSelf.frontMACDMinValue = 0;
            weakSelf.frontMACDMaxValue = 0;
            weakSelf.frontKLineWidth = 5;
        }
        else
        {
            weakSelf.data = newTask.data;
            if (newTask.bollMaxValue != MAXFLOAT)
            {
                weakSelf.frontMaxValue = newTask.frontMaxValue > newTask.bollMaxValue ? newTask.frontMaxValue : newTask.bollMaxValue;
            }
            else
                weakSelf.frontMaxValue = newTask.frontMaxValue;
            
            weakSelf.frontMinValue = newTask.frontMinValue;
            
            if (newTask.bollMinValue != MAXFLOAT && newTask.bollMinValue != MAXFLOAT)
            {
                weakSelf.frontMinValue = newTask.frontMinValue < newTask.bollMinValue ? newTask.frontMinValue : newTask.bollMinValue;
            }
            else
                weakSelf.frontMinValue = newTask.frontMinValue;
            
            
            weakSelf.dataMaxValue = newTask.frontMaxValue;
            weakSelf.dataMinValue = newTask.frontMinValue;
            weakSelf.frontAmountMaxValue = newTask.frontAmountMaxValue;
            weakSelf.frontAmountMinValue = newTask.frontAmountMinValue;
            weakSelf.frontmainchatType = newTask.mainchatType;
            weakSelf.frontMACDType = newTask.MACDType;
            weakSelf.frontMACDMinValue = newTask.MACDMinValue;
            weakSelf.frontMACDMaxValue = newTask.MACDMaxValue;
            weakSelf.frontKLineWidth = newTask.kLineWidth;
            weakSelf.frontKLinePadding = newTask.kLinePadding;
        }//endi
        
        [_taskArray removeObject:newTask];
    }
    //else cont.
}

-(void) appendBackDataToQueue:(NSInteger)nUpdateType
{
    [self addRefreshTask:nUpdateType];
    __weak ImKLineLandScapeView *weakSelf = self;
    dispatch_sync(_drawQueue, ^(void){
        [weakSelf popRefreshTask:weakSelf];
        [weakSelf setNeedsDisplay];
        amountMaxValueLab.text = [self changePrice:weakSelf.frontAmountMaxValue];
        amountMiddleValueLab.text = [self changePrice:weakSelf.frontAmountMaxValue/2];
        
        [self setMACDLabelText];
        
        isUpdateFinish = YES;
    });
}


- (void) reframeMACDLabel:(UILabel*) macdLabel originY:(CGFloat)originY
{
    // 显示成交量最大值
    if (macdLabel == nil) {
        CGFloat theLeft = _macdBoxFrame.origin.x + _macdBoxFrame.size.width + SPACE_BETWEEN_KLINE_TAP;
        macdLabel = [[UILabel alloc] initWithFrame:CGRectMake(theLeft,
                                                              originY,
                                                              self.frame.size.width - _macdBoxFrame.size.width - 2,
                                                              self.font.lineHeight)];
        macdLabel.font = self.font;
        macdLabel.text = @"0";
        macdLabel.textColor = [UIColor colorWithHexString:@"535d6a" withAlpha:1];
        macdLabel.backgroundColor = [UIColor clearColor];
        macdLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:macdLabel];
    }
    else
    {
        
        
        CGFloat theLeft = _macdBoxFrame.origin.x + _macdBoxFrame.size.width + SPACE_BETWEEN_KLINE_TAP;
        [macdLabel setFrame:CGRectMake(theLeft,
                                       originY,
                                       self.frame.size.width - _macdBoxFrame.size.width - 2,
                                       self.font.lineHeight)];
    }//endi
}

- (void) setMACDLabelText
{
    NSInteger nCrollLineHeight = 15.0f;
    CGFloat boundsHeight = _macdBoxFrame.size.height - nCrollLineHeight;
    
    switch (self.MACDType) {
        case MACD_TYPE_MACD:
        {
            _macdMaxValueLab.text = @"";
            _macdMiddleValueLab.text = @"0";
            _macdMinValueLab.text = @"";
            break;
        }
        case MACD_TYPE_KDJ:
        {
            _macdMaxValueLab.text = @"100";
            _macdMiddleValueLab.text = @"50";
            _macdMinValueLab.text = @"0";
            
            CGFloat maxPointY = [self yAxisFromMACDValue:100 boundsHeight:boundsHeight];
            [self reframeMACDLabel:_macdMaxValueLab originY:maxPointY];
            
            CGFloat middlePointY = [self yAxisFromMACDValue:50 boundsHeight:boundsHeight];
            [self reframeMACDLabel:_macdMiddleValueLab originY:middlePointY];
            
            CGFloat minPointY = [self yAxisFromMACDValue:0 boundsHeight:boundsHeight];
            [self reframeMACDLabel:_macdMinValueLab originY:minPointY];
            break;
        }
        case MACD_TYPE_RSI:
        {
            _macdMaxValueLab.text = @"80";
            _macdMiddleValueLab.text = @"50";
            _macdMinValueLab.text = @"20";
            
            CGFloat maxPointY = [self yAxisFromMACDValue:80 boundsHeight:boundsHeight];
            [self reframeMACDLabel:_macdMaxValueLab originY:maxPointY];
            
            CGFloat middlePointY = [self yAxisFromMACDValue:50 boundsHeight:boundsHeight];
            [self reframeMACDLabel:_macdMiddleValueLab originY:middlePointY];
            
            CGFloat minPointY = [self yAxisFromMACDValue:20 boundsHeight:boundsHeight];
            [self reframeMACDLabel:_macdMinValueLab originY:minPointY];
            break;
        }
        case MACD_TYPE_WR:
        {
            _macdMaxValueLab.text = @"80";
            _macdMiddleValueLab.text = @"50";
            _macdMinValueLab.text = @"20";
            
            CGFloat maxPointY = [self yAxisFromMACDValue:80 boundsHeight:boundsHeight];
            [self reframeMACDLabel:_macdMaxValueLab originY:maxPointY];
            
            CGFloat middlePointY = [self yAxisFromMACDValue:50 boundsHeight:boundsHeight];
            [self reframeMACDLabel:_macdMiddleValueLab originY:middlePointY];
            
            CGFloat minPointY = [self yAxisFromMACDValue:20 boundsHeight:boundsHeight];
            [self reframeMACDLabel:_macdMinValueLab originY:minPointY];
            break;
        }
        case MACD_TYPE_NONE:
        {
            _macdMaxValueLab.text = @"";
            _macdMiddleValueLab.text = @"";
            _macdMinValueLab.text = @"";
            break;
        }
        default:
            break;
    }//ends
}

#pragma mark - 手指动作

- (void) updateKLineWidthOfpGesture:(UIPinchGestureRecognizer*)pGesture
{
    CGFloat kLineWidth = self.kLineWidth;
    CGFloat kLinePadding = self.kLinePadding;
    if (pGesture.scale>1)
    {
        // 放大手势
        kLineWidth++;
    }
    else
    {
        // 缩小手势
        kLineWidth--;
    }
    
    //重置线程过程中的标识
    if (kLineWidth > 20)
        kLineWidth = 20;
    //else cont.
    
    if (kLineWidth < 1)
    {
        kLineWidth = 1;
        kLinePadding = 1;
    }
    else
        kLinePadding = 1;
    
    self.kLineWidth = kLineWidth;
    self.kLinePadding = kLinePadding;
}

/******** 手指捏合动作 ********/
-(void)touchBoxAction:(UIPinchGestureRecognizer*)pGesture{
    isPinch  = NO;
    if (pGesture.state == UIGestureRecognizerStateBegan && isUpdateFinish)
    {
        self.kLineWidthTemp = self.kLineWidth;
        self.kLinePaddingTemp = self.kLinePadding;
    }
    else if (pGesture.state == UIGestureRecognizerStateChanged && isUpdateFinish)
    {
        NSUInteger kLineWidth = self.kLineWidthTemp;
        NSUInteger kLinePadding = self.kLinePaddingTemp;
        
        BOOL bNeedScale = NO;
        CGFloat scale = pGesture.scale;
        if (scale > 1)
        {
            if (kLineWidth < 5)
            {
                NSUInteger kLineWidthTemp =  scale * self.kLineWidthTemp;
                if (kLineWidthTemp < 5)
                {
                    kLineWidth++;
                    self.kLineWidthTemp++;
                }
                else
                    kLineWidth = scale * self.kLineWidthTemp;
            }
            else
            {
                NSUInteger kLineWidthTemp =  scale * self.kLineWidthTemp;
                if (kLineWidthTemp < kLineWidth)
                    self.kLineWidthTemp++;
                else
                    kLineWidth = kLineWidthTemp;
            }
        }
        
        else if (scale < 1)
        {
            if (kLineWidth <= 5)
            {
                if (kLineWidth <= 1)
                {
                    kLineWidth = 1;
                    self.kLineWidthTemp = 1;
                }
                else
                {
                    kLineWidth--;
                    self.kLineWidthTemp--;
                }
            }
            else
            {
                NSUInteger kLineWidthTemp =  scale * self.kLineWidthTemp;
                if (kLineWidthTemp > kLineWidth)
                {
                    self.kLineWidthTemp--;
                }
                else
                    kLineWidth = kLineWidthTemp;
            }
            
        }
        //else cont.
        
        //重置线程过程中的标识
        if (kLineWidth > 20)
            kLineWidth = 20;
        //else cont.
        
        if (kLineWidth < 1)
        {
            kLineWidth = 1;
        }
        //else cont.
        
        if (kLineWidth != self.kLineWidth)
        {
            bNeedScale = YES;
        }
        //else cont.
        
        if (bNeedScale)
        {
            _kLineData.kCount = self.mainWidth / (kLineWidth + kLinePadding); // K线中实体的总数
            if([_kLineData createBackDataWithOffet:_nTotalOffset])
            {
                [_taskArray removeAllObjects];
                self.kLineWidth = kLineWidth;
                self.kLinePadding = kLinePadding;
                self.kCount = self.mainWidth / (kLineWidth + kLinePadding);
                [self appendBackDataToQueue:KLINE_REFRESH_BATCH];
            }
            else
            {
                _kLineData.kCount = self.mainWidth / (self.kLineWidth + self.kLinePadding);
            }//endi
        }
        //else cont.
        
    }
    else if (pGesture.state == UIGestureRecognizerStateEnded && isUpdateFinish)
    {
        self.kLineWidthTemp = self.kLineWidth;
        self.kLinePaddingTemp = self.kLinePadding;
    }
    //else cont.
}

/******** 长按就开始生成十字线 ********/
-(void)gestureRecognizerHandle:(UILongPressGestureRecognizer*)longResture
{

    isPinch = YES;
    // 手指长按开始时更新一般
    if(longResture.state == UIGestureRecognizerStateBegan)
    {
    }
    // 手指移动时候开始显示十字线
    else if (longResture.state == UIGestureRecognizerStateChanged)
    {

    }
    
    // 手指离开的时候移除十字线
    else if (longResture.state == UIGestureRecognizerStateEnded)
    {
        isPinch = NO;
    }
    else
        HB_LOG(@"error!");
}

/******** 手指拖拽动作 ********/
- (void) panGestureRecognizerHandle:(UIPanGestureRecognizer*)pGesture
{
    ImScreenTouchesAction *screenTouchesAction = [ImScreenTouchesAction getInstance];
    [screenTouchesAction setScreenLight];
    
    /********************************************************************************
     函数基本思路：
     _nOffsetPerPan 本次pan操作过程中发生的offset.
     _nTotalOffset  本次pan发生之前的offset。
     1、操作只改变本次_nOffsetPerPan，等操作后将_nOffsetPerPan合并到_nTotalOffset上。
        所以绝对不可以在change中改变_nTotalOffset。
     ********************************************************************************/
    isPinch  = NO;
    if (pGesture.state == UIGestureRecognizerStateBegan && isUpdateFinish)
    {
        CGPoint point = [pGesture translationInView:self];
        _nOffsetBegin = point.x;
    }
    else if (pGesture.state == UIGestureRecognizerStateChanged && isUpdateFinish)
    {
        CGPoint touchPoint = [pGesture translationInView:self];
        NSInteger nCount = (touchPoint.x - _nOffsetBegin) / (self.kLineWidth + self.kLinePadding);
        if (_nTotalOffset + nCount < 0)
        {
            nCount = -_nTotalOffset;
        }
        //else cont.
        
        NSInteger nOffset = _nTotalOffset + nCount;
        NSInteger nMoveType = 0;
        if (nCount > 0)
        {
            nMoveType = 1;
        }
        else if (nCount < 0)
        {
            nMoveType = -1;
        }
        //else cont.
        
        NSInteger movedTotalCount = [_kLineData updateBackDataWithOffet:nOffset
                                                             ofMoveType:nMoveType];
        if (movedTotalCount >= 0)
        {
            if(movedTotalCount != _nTotalOffset)
            {
                _nOffsetPerPan = movedTotalCount - _nTotalOffset;
                _touchViewPoint = [pGesture locationInView:self];
                
            }
            //else cont.
        }
        else
            HB_LOG(@"error!");
    }
    else if (pGesture.state == UIGestureRecognizerStateEnded)
    {
        _nOffsetBegin = 0;
        _nTotalOffset += _nOffsetPerPan;
        _nOffsetPerPan = 0;
        isPinch = YES;
    }
    //else cont.
}

- (void) tapGestureRecognizerHandle:(UITapGestureRecognizer*)pGesture
{
    ImScreenTouchesAction *screenTouchesAction = [ImScreenTouchesAction getInstance];
    [screenTouchesAction setScreenLight];
    
    isPinch  = NO;
    if (pGesture.state == UIGestureRecognizerStateEnded)
    {
        _touchViewPoint = [pGesture locationInView:self];
        [self isTapWithPoint:_touchViewPoint bFromTap:YES];
        isPinch = YES;
    }
    //else cont.
}

#pragma mark - tap action - top label

- (NSString*) getBOLLString:(NSDictionary *)item
{
    NSString* strBOLL = @"BOLL:-";
    NSNumber* bollSummary = [item objectForKey:BOLL_SUMMARY];
    if (bollSummary && [bollSummary doubleValue] != MAXFLOAT )
    {
        NSString* strValue = [DLTextAttributeData stringNotRounding:[bollSummary doubleValue] afterPoint:2];
        strBOLL = [NSString stringWithFormat:@"BOLL:%@", strValue];
    }
    
    return strBOLL;
}

- (NSString*) getUBString:(NSDictionary *)item
{
    NSString* strUB = @"UB:-";
    NSNumber* bollUB = [item objectForKey:BOLL_UB];
    if (bollUB && [bollUB doubleValue] != MAXFLOAT )
    {
        NSString* strValue = [DLTextAttributeData stringNotRounding:[bollUB doubleValue] afterPoint:2];
        strUB = [NSString stringWithFormat:@"UB:%@", strValue];
    }
    
    return strUB;
}

- (NSString*) getLBString:(NSDictionary *)item
{
    NSString* strLB = @"LB:-";
    NSNumber* bollLB = [item objectForKey:BOLL_LB];
    if (bollLB && [bollLB doubleValue] != MAXFLOAT )
    {
        NSString* strValue = [DLTextAttributeData stringNotRounding:[bollLB doubleValue] afterPoint:2];
        strLB = [NSString stringWithFormat:@"LB:%@", strValue];
    }
    
    return strLB;
}

- (NSString*) getMA60String:(NSDictionary *)item
{
    NSString* strMA60 = @"MA60:-";
    NSNumber* ma60 = [item objectForKey:MA_MA60];
    if (ma60 && [ma60 doubleValue] != MAXFLOAT )
    {
        NSString* strValue = [DLTextAttributeData stringNotRounding:[ma60 doubleValue] afterPoint:2];
        strMA60 = [NSString stringWithFormat:@"MA60:%@", strValue];
    }
    //else cont.
    
    return strMA60;
}

- (NSString*) getMA10String:(NSDictionary *)item
{
    NSString* strMA10 = @"MA10:-";
    NSNumber* ma10 = [item objectForKey:MA_MA10];
    if (ma10 && [ma10 doubleValue] != MAXFLOAT )
    {
        NSString* strValue = [DLTextAttributeData stringNotRounding:[ma10 doubleValue] afterPoint:2];
        strMA10 = [NSString stringWithFormat:@"MA10:%@", strValue];
    }
    
    return strMA10;
}

- (NSString*) getMA30String:(NSDictionary *)item
{
    NSString* strMA30 = @"MA30:-";
    NSNumber* ma30 = [item objectForKey:MA_MA10];
    if (ma30 && [ma30 doubleValue] != MAXFLOAT )
    {
        NSString* strValue = [DLTextAttributeData stringNotRounding:[ma30 doubleValue] afterPoint:2];
        strMA30 = [NSString stringWithFormat:@"MA30:%@",strValue];
    }
    
    return strMA30;
}

- (void) updateKLineInfoWithArray:(NSDictionary *)item
{
    NSString* strPriceOpen = [DLTextAttributeData stringNotRounding:[[item objectForKey:PRICEOPEN] doubleValue] afterPoint:2];
    NSString* strPriceHigh = [DLTextAttributeData stringNotRounding:[[item objectForKey:PRICEHIGH] doubleValue] afterPoint:2];
    NSString* strPriceLow = [DLTextAttributeData stringNotRounding:[[item objectForKey:PRICELOW] doubleValue] afterPoint:2];
    NSString* strPriceLast = [DLTextAttributeData stringNotRounding:[[item objectForKey:PRICELAST] doubleValue] afterPoint:2];
    NSArray* argsArray = nil;
    switch (self.frontmainchatType) {
        case KLINE_TYPE_MA:
        {
            if (self.bTimeLine)
            {
                NSString* strMA60 = [self getMA60String:item];
                argsArray = @[strPriceOpen,strPriceHigh,strPriceLow,strPriceLast,strMA60];
            }
            else
            {
                NSString* strMA10 = [self getMA10String:item];
                NSString* strMA30 = [self getMA30String:item];
                NSString* strMA60 = [self getMA60String:item];
                argsArray = @[strPriceOpen,strPriceHigh,strPriceLow,strPriceLast,strMA10,strMA30,strMA60];
            }//endi
            break;
        }
        case KLINE_TYPE_BOLL:
        {
            if (self.bTimeLine)
            {
                NSString* strMA60 = [self getMA60String:item];
                argsArray = @[strPriceOpen,strPriceHigh,strPriceLow,strPriceLast,strMA60];
            }
            else
            {
                NSString* strBOLL = [self getBOLLString:item];
                NSString* strUB = [self getUBString:item];;
                NSString* strLB = [self getLBString:item];;
                argsArray = @[strPriceOpen,strPriceHigh,strPriceLow,strPriceLast,strBOLL,strUB,strLB];
            }//endi
            break;
        }
        case KLINE_TYPE_NONE:
        {
            if(self.bTimeLine)
            {
                NSString* strMA60 = [self getMA60String:item];
                argsArray = @[strPriceOpen,strPriceHigh,strPriceLow,strPriceLast,strMA60];
            }
            else
                argsArray = @[strPriceOpen,strPriceHigh,strPriceLow,strPriceLast];
            
            break;
        }
        default:
            HB_LOG(@"error!");
            break;
    }//ends
    _infoView.timeLine = self.bTimeLine;
    _infoView.macdType = self.MACDType;
    _infoView.mainchatType = self.mainchatType;
    _infoView.bFullScreenMode = self.bFullScreenMode;
    [_infoView updateTopLabel:argsArray];
}

#pragma mark - tap action - Cross Line
- (void) updateCrossLine:(CGFloat)itemPointX touchePoint:(CGPoint)point
{
    timelineone.hidden = NO;
    pricelinetwo.hidden = NO;
    timelineBottomLable.hidden = NO;
    pricelineLable.hidden = NO;
    zuobiaoLayer.hidden = NO;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    
    timelineone.frame = CGRectMake(itemPointX,
                                   timelineone.frame.origin.y,
                                   timelineone.frame.size.width,
                                   timelineone.frame.size.height);
    
    pricelinetwo.frame = CGRectMake(pricelinetwo.frame.origin.x,
                                    _mainBoxFrame.origin.y + point.y,
                                    pricelinetwo.frame.size.width,
                                    pricelinetwo.frame.size.height);
    
    zuobiaoLayer.frame = CGRectMake(itemPointX - zuobiaoLayer.frame.size.width/2,
                                    _mainBoxFrame.origin.y + point.y - zuobiaoLayer.frame.size.height/2,
                                    zuobiaoLayer.frame.size.width,
                                    zuobiaoLayer.frame.size.height);
    [CATransaction commit];
    
    NSDictionary* timeAttribute = [[DLMainManager sharedTextAttributeData] getKLineTimeAttributeDict];
    CGSize textSize = [DLTextAttributeData sizeOfString:timelineBottomLable.text withDict:timeAttribute];
    textSize.width += 10.0f;
    
    // 垂直提示日期控件
    CGFloat oneLableX = 0;
    
    if (itemPointX - _mainBoxFrame.origin.x < textSize.width/2)
    {
        oneLableX = _mainBoxFrame.origin.x;
    }
    else if (textSize.width/2 > (_mainBoxFrame.origin.x + _mainBoxFrame.size.width - itemPointX))
    {
        oneLableX =_mainBoxFrame.origin.x + _mainBoxFrame.size.width - textSize.width;
    }
    else
        oneLableX = itemPointX - textSize.width / 2;
    
    timelineBottomLable.frame = CGRectMake(oneLableX,
                                           _timeFrame.origin.y,
                                           textSize.width,
                                           _timeFrame.size.height);
    

    
    CGFloat twoLableX = pricelinetwo.frame.origin.x + pricelinetwo.frame.size.width + 1.0f;
    pricelineLable.frame = CGRectMake(twoLableX,
                                      point.y - pricelineLable.frame.size.height/2,
                                      pricelineLable.frame.size.width,
                                      pricelineLable.frame.size.height);
}

- (void) updateDIFLayer:(NSString*)strTitle dif:(NSString*)strDIF
{
    int nFontSize = 8.0f;
    CGFontRef cgFont = CGFontCreateWithFontName((CFStringRef)[UIFont boldSystemFontOfSize:nFontSize].fontName);
    NSDictionary* textAttr = @{NSFontAttributeName:[UIFont systemFontOfSize:nFontSize],
                               NSForegroundColorAttributeName:[UIColor whiteColor]};

    CGSize titleSize = [DLTextAttributeData sizeOfString:strTitle withDict:textAttr];
    
    if(!_titleLayer)
    {
        NSDictionary *newActions = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"contents", nil];
        _titleLayer = [[CATextLayer alloc] init];
        _titleLayer.foregroundColor = [UIColor colorWithHexString:@"#5e6c7f" withAlpha:self.alpha].CGColor;
        _titleLayer.actions = newActions;
        _titleLayer.font = cgFont;
        _titleLayer.string = @"       ";
        _titleLayer.fontSize = nFontSize;
        _titleLayer.contentsScale = 2.0f;
        [self.layer addSublayer:_titleLayer];
        _titleLayer.string = @"MACD(12,26,9)";
        [_titleLayer setFrame:CGRectMake(_macdBoxFrame.origin.x + 10.0f,
                                         _macdBoxFrame.origin.y + 5.0f,
                                         titleSize.width,
                                         titleSize.height + 10.0f)];
    }
    else
    {
        [_titleLayer setFrame:CGRectMake(_macdBoxFrame.origin.x + 10.0f,
                                         _macdBoxFrame.origin.y + 5.0f,
                                         titleSize.width,
                                         _titleLayer.frame.size.height)];
    }
    
    CGSize valueSize = [DLTextAttributeData sizeOfString:strDIF withDict:textAttr];
    if (_difLayer == nil)
    {
        NSDictionary *newActions = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"contents", nil];
        _difLayer = [[CATextLayer alloc] init];
        [_difLayer setFrame:CGRectMake(_titleLayer.frame.origin.x + _titleLayer.frame.size.width + 10.0f,
                                       _macdBoxFrame.origin.y + 5.0f,
                                       valueSize.width,
                                       valueSize.height + 10.0f)];
        _difLayer.foregroundColor = [UIColor whiteColor].CGColor;
        _difLayer.actions = newActions;
        _difLayer.font = cgFont;
        _difLayer.string = @"       ";
        _difLayer.fontSize = nFontSize;
        _difLayer.contentsScale = 2.0f;
        [self.layer addSublayer:_difLayer];
    }
    else
    {
        [_difLayer setFrame:CGRectMake(_titleLayer.frame.origin.x + _titleLayer.frame.size.width + 10.0f,
                                       _macdBoxFrame.origin.y + 5.0f,
                                       valueSize.width,
                                       valueSize.height + 10.0f)];
    }
    _titleLayer.hidden = NO;
    _difLayer.hidden = NO;
    
    _titleLayer.string = strTitle;
    _difLayer.string = strDIF;
}

- (void) updateDEALayer:(NSString*)strAmount
{
    int nFontSize = 8.0f;
    CGFontRef cgFont = CGFontCreateWithFontName((CFStringRef)[UIFont boldSystemFontOfSize:nFontSize].fontName);
    NSDictionary* textAttr = @{NSFontAttributeName:[UIFont systemFontOfSize:nFontSize],
                               NSForegroundColorAttributeName:[UIColor whiteColor]};
    CGSize valueSize = [DLTextAttributeData sizeOfString:strAmount withDict:textAttr];
    
    if (_deaLayer == nil)
    {
        
        NSDictionary *newActions = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"contents", nil];
        _deaLayer = [[CATextLayer alloc] init];
        _deaLayer.foregroundColor = [UIColor colorWithHexString:@"#fffc00" withAlpha:self.alpha].CGColor;
        _deaLayer.actions = newActions;
        _deaLayer.font = cgFont;
        _deaLayer.string = @"       ";
        _deaLayer.fontSize = nFontSize;
        _deaLayer.contentsScale = 2.0f;
        [self.layer addSublayer:_deaLayer];
    }
    //else cont.
    
    _deaLayer.hidden = NO;
    
    [_deaLayer setFrame:CGRectMake(_difLayer.frame.origin.x + _difLayer.frame.size.width + 10.0f,
                                    _macdBoxFrame.origin.y + 5.0f,
                                    valueSize.width,
                                    valueSize.height + 10.0f)];
    
    _deaLayer.string = strAmount;
}

- (void) updateMACDLayer:(NSString*)strAmount
{
    strAmount = strAmount ? strAmount : @"";
    int nFontSize = 8.0f;
    CGFontRef cgFont = CGFontCreateWithFontName((CFStringRef)[UIFont boldSystemFontOfSize:nFontSize].fontName);
    NSDictionary* textAttr = @{NSFontAttributeName:[UIFont systemFontOfSize:nFontSize],
                               NSForegroundColorAttributeName:[UIColor whiteColor]};
    CGSize valueSize = [DLTextAttributeData sizeOfString:strAmount withDict:textAttr];
    
    if (_macdLayer == nil)
    {
        
        NSDictionary *newActions = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"contents", nil];
        _macdLayer = [[CATextLayer alloc] init];
        _macdLayer.foregroundColor = [UIColor colorWithHexString:@"#ff0095" withAlpha:self.alpha].CGColor;
        _macdLayer.actions = newActions;
        _macdLayer.font = cgFont;
        _macdLayer.string = @"       ";
        _macdLayer.fontSize = nFontSize;
        _macdLayer.contentsScale = 2.0f;
        [self.layer addSublayer:_macdLayer];
    }
    //else cont.
    
    _macdLayer.hidden = NO;
    
    [_macdLayer setFrame:CGRectMake(_deaLayer.frame.origin.x + _deaLayer.frame.size.width + 10.0f,
                                    _macdBoxFrame.origin.y + 5.0f,
                                    valueSize.width,
                                    valueSize.height + 10.0f)];
    
    _macdLayer.string = strAmount;
}

- (void) updateAmountLayer:(NSString*)strAmount
{
    int nFontSize = 8.0f;
    CGFontRef cgFont = CGFontCreateWithFontName((CFStringRef)[UIFont boldSystemFontOfSize:nFontSize].fontName);
    NSDictionary* textAttr = @{NSFontAttributeName:[UIFont systemFontOfSize:nFontSize],
                               NSForegroundColorAttributeName:[UIColor whiteColor]};
    CGSize valueSize = [DLTextAttributeData sizeOfString:strAmount withDict:textAttr];
    
    if (_amountLayer == nil)
    {
        
        NSDictionary *newActions = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"contents", nil];
        _amountLayer = [[CATextLayer alloc] init];
        _amountLayer.foregroundColor = [UIColor colorWithHexString:@"#5e6c7f" withAlpha:self.alpha].CGColor;
        _amountLayer.actions = newActions;
        _amountLayer.font = cgFont;
        _amountLayer.string = @"       ";
        _amountLayer.fontSize = nFontSize;
        _amountLayer.contentsScale = 2.0f;
        [self.layer addSublayer:_amountLayer];
    }
    //else cont.
    
    _amountLayer.hidden = NO;
    
    [_amountLayer setFrame:CGRectMake(_amountBoxFrame.origin.x + 10.0f,
                                      _amountBoxFrame.origin.y + 5.0f,
                                      valueSize.width,
                                      valueSize.height + 10.0f)];
    
    _amountLayer.string = strAmount;
}



- (void) updateAmountMA5Layer:(NSString*)strAmount
{
    int nFontSize = 8.0f;
    CGFontRef cgFont = CGFontCreateWithFontName((CFStringRef)[UIFont boldSystemFontOfSize:nFontSize].fontName);
    NSDictionary* textAttr = @{NSFontAttributeName:[UIFont systemFontOfSize:nFontSize],
                               NSForegroundColorAttributeName:[UIColor whiteColor]};
    CGSize valueSize = [DLTextAttributeData sizeOfString:strAmount withDict:textAttr];
    
    if (_amountMA5Layer == nil)
    {
        
        NSDictionary *newActions = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"contents", nil];
        _amountMA5Layer = [[CATextLayer alloc] init];
        _amountMA5Layer.foregroundColor = [UIColor whiteColor].CGColor;
        _amountMA5Layer.actions = newActions;
        _amountMA5Layer.font = cgFont;
        _amountMA5Layer.string = @"       ";
        _amountMA5Layer.fontSize = nFontSize;
        _amountMA5Layer.contentsScale = 2.0f;
        [self.layer addSublayer:_amountMA5Layer];
    }
    //else cont.
    
    _amountMA5Layer.hidden = NO;
    
    [_amountMA5Layer setFrame:CGRectMake(_amountLayer.frame.origin.x + _amountLayer.frame.size.width + 10.0f,
                                      _amountBoxFrame.origin.y + 5.0f,
                                      valueSize.width,
                                      valueSize.height + 10.0f)];
    
    _amountMA5Layer.string = strAmount;
}

- (void) updateAmountMA10Layer:(NSString*)strAmount
{
    int nFontSize = 8.0f;
    CGFontRef cgFont = CGFontCreateWithFontName((CFStringRef)[UIFont boldSystemFontOfSize:nFontSize].fontName);
    NSDictionary* textAttr = @{NSFontAttributeName:[UIFont systemFontOfSize:nFontSize],
                               NSForegroundColorAttributeName:[UIColor whiteColor]};
    CGSize valueSize = [DLTextAttributeData sizeOfString:strAmount withDict:textAttr];
    
    if (_amountMA10Layer == nil)
    {
        NSDictionary *newActions = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"contents", nil];
        _amountMA10Layer = [[CATextLayer alloc] init];
        _amountMA10Layer.foregroundColor = [UIColor colorWithHexString:@"#fffc00" withAlpha:self.alpha].CGColor;
        _amountMA10Layer.actions = newActions;
        _amountMA10Layer.font = cgFont;
        _amountMA10Layer.string = @"       ";
        _amountMA10Layer.fontSize = nFontSize;
        _amountMA10Layer.contentsScale = 2.0f;
        [self.layer addSublayer:_amountMA10Layer];
    }
    //else cont.
    
    _amountMA10Layer.hidden = NO;
    
    [_amountMA10Layer setFrame:CGRectMake(_amountMA5Layer.frame.origin.x + _amountMA5Layer.frame.size.width + 10.0f,
                                         _amountBoxFrame.origin.y + 5.0f,
                                         valueSize.width,
                                         valueSize.height + 10.0f)];
    
    _amountMA10Layer.string = strAmount;
}

- (void) updateCrossTimeFormat
{
    NSString* strTimeFormat = @"YYYY-MM-dd HH:mm:ss";
    if ([self.delegate respondsToSelector:@selector(getCurrentPeriod)])
    {
        NSString* strPeriod = [self.delegate getCurrentPeriod];

        if ([strPeriod isEqualToString:KLINE1DAY] || [strPeriod isEqualToString:KLINE1WEEK])
        {
            strTimeFormat = @"YYYY-MM-dd";
        }
        //else cont.
    }
    //else cont.
    
    [_crossDateFormatter setDateFormat:strTimeFormat];
}

- (void) updateAmountValue:(NSDictionary *)item
{
    {
        NSString* strAmount = [NSString stringWithFormat:@"%@:-",NSLocalizedString(@"SR_MarketVolume", @"")];
        
        NSNumber* numValue = [item objectForKey:AMOUNT];
        if (numValue && [numValue doubleValue] != MAXFLOAT)
        {
            NSString* strAmountValue = [DLTextAttributeData stringNotRounding:[numValue doubleValue] afterPoint:4];
            if (strAmount)
            {
                strAmount = [NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"SR_MarketVolume", @""),strAmountValue];
            }
            //else cont.
        }

        [self updateAmountLayer:strAmount];
    }
    
    {
        NSString* strMA5Amount = @"MA5:-";
        NSNumber* numValue = [item objectForKey:AMOUNT_MA5];
        if (numValue && [numValue doubleValue] != MAXFLOAT)
        {
            CGFloat nValue  = [[item objectForKey:AMOUNT_MA5] doubleValue];
            strMA5Amount = [NSString stringWithFormat:@"MA5:%@", [DLTextAttributeData stringNotRounding:nValue afterPoint:2]];
        }
        //else cont.
        
        [self updateAmountMA5Layer:strMA5Amount];
    }
    
    {
        NSString* strMA10Amount = @"MA10:-";
        NSNumber* strValue = [item objectForKey:AMOUNT_MA10];
        if (strValue && [strValue doubleValue] != MAXFLOAT)
        {
            CGFloat nValue  = [[item objectForKey:AMOUNT_MA10] doubleValue];
            strMA10Amount = [NSString stringWithFormat:@"MA10:%@", [DLTextAttributeData stringNotRounding:nValue afterPoint:2]];
        }
        //else cont.
        
        [self updateAmountMA10Layer:strMA10Amount];
    }
}


- (NSString*) getValueWithItem:(NSDictionary*)item key:(NSString*)key
{
    NSString* result = @"-";//[NSString stringWithFormat:@"%@:-", keyValue];
    NSNumber* numValue = [item objectForKey:key];
    if (numValue)
    {
        CGFloat nValue  = [numValue doubleValue];
        if (nValue != MAXFLOAT)
            result = [DLTextAttributeData stringNotRounding:nValue afterPoint:2];
        //else cont.
    }
    else
        HB_LOG(@"error!");
    
    return result;
}

- (void) updateMACDValue:(NSDictionary*)item
{
    NSString* strTitle =  nil;
    NSString* strFirst =  nil;
    NSString* strSecond = nil;
    NSString* strThrid = nil;
    
    switch (self.MACDType) {
        case MACD_TYPE_NONE:
        {
            break;
        }
        case MACD_TYPE_MACD:
        {
            strFirst = [self getValueWithItem:item key:MACD_DIF];

            strSecond = [self getValueWithItem:item key:MACD_DEA];
            strThrid = [self getValueWithItem:item key:MACD_MACD];

            strTitle = @"MACD(12,26,9)";
            strFirst = [NSString stringWithFormat:@"DIF:%@",strFirst];
            strSecond = [NSString stringWithFormat:@"DEA:%@",strSecond];
            strThrid = [NSString stringWithFormat:@"MACD:%@",strThrid];
            break;
        }
        case MACD_TYPE_KDJ:
        {
            strFirst = [self getValueWithItem:item key:KDJ_K];
            strSecond = [self getValueWithItem:item key:KDJ_D];
            strThrid = [self getValueWithItem:item key:KDJ_J];
            
            strTitle = @"KDJ(N:9,M1:3,M2:3)";
            strFirst = [NSString stringWithFormat:@"K:%@",strFirst];
            strSecond = [NSString stringWithFormat:@"D:%@",strSecond];
            strThrid = [NSString stringWithFormat:@"J:%@",strThrid];
            break;
        }
        case MACD_TYPE_RSI:
        {
            strFirst = [self getValueWithItem:item key:RSI_RSI1];
            strSecond = [self getValueWithItem:item key:RSI_RSI2];
            strThrid = [self getValueWithItem:item key:RSI_RSI3];
            
            strTitle = @"RSI(N1:6,N2:12,N3:24)";
            strFirst = [NSString stringWithFormat:@"RSI1:%@",strFirst];
            strSecond = [NSString stringWithFormat:@"RSI2:%@",strSecond];
            strThrid = [NSString stringWithFormat:@"RSI3:%@",strThrid];
            break;
        }
        case MACD_TYPE_WR:
        {
            strFirst = [self getValueWithItem:item key:WR_WR1];
            strSecond = [self getValueWithItem:item key:WR_WR2];
            
            strFirst = [self getValueWithItem:item key:WR_WR1];
            strSecond = [self getValueWithItem:item key:WR_WR2];
            
            strTitle = @"RSI(N:10,N1:6)";
            strFirst = [NSString stringWithFormat:@"WR1:%@",strFirst];
            strSecond = [NSString stringWithFormat:@"WR2:%@",strSecond];
            break;
        }
        default:
            break;
    }
    [self updateDIFLayer:strTitle dif:strFirst];
    [self updateDEALayer:strSecond];
    [self updateMACDLayer:strThrid];

}

-(BOOL)isTapWithPoint:(CGPoint)point bFromTap:(BOOL)bFromTap
{
    BOOL bResult = NO;
    CGFloat itemPointX = 0;
    if (_pointArray)
    {
        if (!bFromTap)
        {
            point.x = timelineone.frame.origin.x;
            point.y = pricelinetwo.frame.origin.y;
        }
        //else cont.
        
        for (NSDictionary *item in _pointArray)
        {
            NSNumber* numPointX = [item objectForKey:Origin_X];
            if (numPointX && [numPointX doubleValue] != MAXFLOAT) {
                itemPointX = [numPointX doubleValue];  // 收盘价的坐标
            }
            else
                HB_LOG(@"error!");
            
            if (fabs(point.x - itemPointX) <= (self.frontKLineWidth + self.frontKLinePadding) / 2)
            {
                // 十字线垂直提示日期控件
                [self updateCrossTimeFormat];
                NSDate* timeDate = [NSDate dateWithTimeIntervalSince1970:[[item objectForKey:TIME] integerValue]];
                NSString *timeString = [_crossDateFormatter stringFromDate:timeDate];
                timelineBottomLable.text = timeString; // 日期
                
                if (point.y > _mainBoxFrame.origin.y + _mainBoxFrame.size.height)
                {
                    point.y = _mainBoxFrame.origin.y + _mainBoxFrame.size.height;
                }
                else if (point.y < _mainBoxFrame.origin.y)
                {
                    point.y = _mainBoxFrame.origin.y;
                }
                //else cont.
                
                // 十字线横向提示价格控件
                float price = self.frontMaxValue - ( (point.y - _mainBoxFrame.origin.y) / _mainBoxFrame.size.height )* (self.frontMaxValue - self.frontMinValue);
                pricelineLable.text = [DLTextAttributeData stringNotRounding:price afterPoint:2]; // 收盘价
                
                //设置十字线的位置
                if (bFromTap)
                {
                    [self updateCrossLine:itemPointX touchePoint:point];
                }
                //else cont.
                
                //更新各种提示
                [self updateKLineInfoWithArray:item];
                [self updateAmountValue:item];
                [self updateMACDValue:item];
                bResult = YES;
                break;
            }
            //else cont.
        }//endf
    }
    else
        HB_LOG(@"error!");
    
    return bResult;
}

- (void) hiddeCrossLine
{
    timelineone.hidden = YES;
    pricelinetwo.hidden = YES;
    timelineBottomLable.hidden = YES;
    pricelineLable.hidden = YES;
    zuobiaoLayer.hidden = YES;
    
    if (_amountLayer)
        _amountLayer.hidden = YES;
    //else cont.
    
    if (_amountMA5Layer)
        _amountMA5Layer.hidden = YES;
    //else cont.
    
    if (_amountMA10Layer)
        _amountMA10Layer.hidden = YES;
    //else cont.
    
    if (_titleLayer)
        _titleLayer.hidden = YES;
    //else cont.
    
    if (_macdLayer)
        _macdLayer.hidden = YES;
    //else cont.
    
    if (_difLayer)
        _difLayer.hidden = YES;
    //else cont.
    
    if (_deaLayer)
        _deaLayer.hidden = YES;
    //else cont.
    
    _infoView.timeLine = self.bTimeLine;
    _infoView.macdType = self.MACDType;
    _infoView.mainchatType = self.mainchatType;
    [_infoView updateTopLabel:nil];
}

#pragma mark - main draw
- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);

    if ([self.delegate respondsToSelector:@selector(getCurrentPeriod)])
    {
        [self changeMaxAndMinValue];
        
        NSString* strPeriod = [self.delegate getCurrentPeriod];
        [self drawYAxis:context strPeriod:strPeriod];
        [self drawXAxis:context];
        if (self.data && [self.data count] > 0)
        {
            // 开始画连K线
            [self drawMainKLine:context data:self.data];
            
            //画均线
            [self drawMainAverageLine:context];
            
            // 开始画K线图
            if (_finishUpdateBlock) {
                _finishUpdateBlock(self);
            }
        }
        //else cont.
    }
    else
        HB_LOG(@"error!");
}

- (void) drawMainAverageLine:(CGContextRef)context
{
    CGContextSetLineWidth(context, 1.0f);
    CGContextSetShouldAntialias(context, YES);
    
    if (self.bTimeLine)
    {
        // MA1
        [self drawLineWithContext:context data:self.data indexKey:PRICELAST andColor:_whiteColor];
        
        // MA60
        [self drawLineWithContext:context data:self.data indexKey:MA_MA60 andColor:_yellowColor];
    }
    else
    {
        switch (self.frontmainchatType)
        {
            case KLINE_TYPE_BOLL:
            {
                // MA10
                [self drawLineWithContext:context data:self.data indexKey:BOLL_SUMMARY andColor:_whiteColor];
                
                // UP
                [self drawLineWithContext:context data:self.data indexKey:BOLL_UB andColor:_yellowColor];
                
                // DOWN
                [self drawLineWithContext:context data:self.data indexKey:BOLL_LB andColor:_ziColor];
                break;
            }
            case KLINE_TYPE_MA:
            {
                // 开始画连接线
                // x轴从0 到 框框的宽度 _mainBoxFrame.size.width 变化  y轴为每个间隔的连线，如，今天的点连接明天的点
                
                // MA10
                [self drawLineWithContext:context data:self.data indexKey:MA_MA10 andColor:_whiteColor];
                
                // MA30
                [self drawLineWithContext:context data:self.data indexKey:MA_MA30 andColor:_yellowColor];
                
                // MA60
                [self drawLineWithContext:context data:self.data indexKey:MA_MA60 andColor:_qingColor];
                
                break;
            }
            default:
                HB_LOG(@"error!");
                break;
        }//ends
    }//endi
    
    
    // MA5
    [self drawAmountLineWithContext:context data:self.data indexKey:AMOUNT_MA5 andColor:_whiteColor];
    
    // MA10
    [self drawAmountLineWithContext:context data:self.data indexKey:AMOUNT_MA10 andColor:_yellowColor];
    
    if (MACD_TYPE_NONE != self.MACDType)
    {
        [self drawMACDLine1WithContext:context];
    }
    //else cont.
}

- (void) drawMACDLine1WithContext:(CGContextRef)context
{
    switch (self.MACDType)
    {
        case MACD_TYPE_NONE:
        {
            
            break;
        }
        case MACD_TYPE_MACD:
        {
            [self drawMACDLineWithContext:context data:self.data indexKey:MACD_DIF andColor:_whiteColor];
            
            [self drawMACDLineWithContext:context data:self.data indexKey:MACD_DEA andColor:_yellowColor];
            
            break;
        }
        case MACD_TYPE_KDJ:
        {
            [self drawMACDLineWithContext:context data:self.data indexKey:KDJ_K andColor:_whiteColor];
            
            [self drawMACDLineWithContext:context data:self.data indexKey:KDJ_D andColor:_yellowColor];
            
            [self drawMACDLineWithContext:context data:self.data indexKey:KDJ_J andColor:_ziColor];
            break;
        }
        case MACD_TYPE_RSI:
        {
            [self drawMACDLineWithContext:context data:self.data indexKey:RSI_RSI1 andColor:_whiteColor];
            
            [self drawMACDLineWithContext:context data:self.data indexKey:RSI_RSI2 andColor:_yellowColor];
            
            [self drawMACDLineWithContext:context data:self.data indexKey:RSI_RSI3 andColor:_ziColor];
            break;
        }
        case MACD_TYPE_WR:
        {
            [self drawMACDLineWithContext:context data:self.data indexKey:WR_WR1 andColor:_whiteColor];
            
            [self drawMACDLineWithContext:context data:self.data indexKey:WR_WR2 andColor:_yellowColor];
            
            break;
        }
        default:
            break;
    }
}

-(void) changeMaxAndMinValue
{
    CGFloat padValue = (self.frontMaxValue - self.frontMinValue) / (KLINE_COUNT + 1);
    self.frontMaxValue = self.frontMaxValue + padValue;
    self.frontMinValue = self.frontMinValue - padValue;
    
    if (self.frontMinValue < 0.0f)
        self.frontMinValue = 0.0f;
    //else cont.

    self.frontAmountMinValue *= 0.99f;
    self.frontAmountMaxValue *= 1.1f;
    
    self.frontMACDMinValue *= 0.99f;
    self.frontMACDMaxValue *= 1.01f;
}

- (void) drawMainKLine:(CGContextRef)context data:(NSArray*)data
{
    CGContextSetShouldAntialias(context, NO);
    NSInteger PointStartX = _mainBoxFrame.origin.x + _mainBoxFrame.size.width - self.kLineWidth/2; // 起始点坐标

    NSInteger kLineCount = self.kCount;
    if ( [data count] < kLineCount)
    {
        kLineCount = [data count];
        PointStartX = _mainBoxFrame.origin.x + [data count] * (self.frontKLineWidth + self.frontKLinePadding);
    }
    //else cont.
    
    NSInteger theEndIndex = [data count] - kLineCount;
    
    if (!_pointArray)
    {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        @autoreleasepool
        {
            NSMutableDictionary* item = nil;
            for (NSInteger nIndex = [data count] - 1; nIndex >= theEndIndex; nIndex--)
            {
                if (PointStartX > _mainBoxFrame.origin.x)
                {
                    item = [data objectAtIndex:nIndex];
                    [self drawKLineItem:item context:context PointStartX:PointStartX tempArray:tempArray nIndex:nIndex];
                    
                    [self drawVolumeItem:item context:context PointStartX:PointStartX];
                    
                    if (MACD_TYPE_NONE != self.MACDType)
                        [self drawMACDItem:item context:context PointStartX:PointStartX];
                    //else cont.
                    
                    PointStartX -= self.frontKLineWidth + self.frontKLinePadding; // 生成下一个点的x轴
                }
                else
                {
                    //计算self.kCount时，可能在取整的时候有偏差，所以最后的一个或两个可能会进入这个分支。
                    break;
                }//endi
            }//endf
        }//end atuo pool
        
        _pointArray = tempArray;
    }
    else
    {
        @autoreleasepool
        {
            NSMutableDictionary* item = nil;
            for (NSInteger nIndex = [data count] - 1; nIndex >= theEndIndex; nIndex--)
            {
                if (PointStartX > _mainBoxFrame.origin.x)
                {
                    item = [data objectAtIndex:nIndex];
                    [self drawKLineItem:item context:context PointStartX:PointStartX tempArray:nil nIndex:nIndex];
                    
                    
                    [self drawVolumeItem:item context:context PointStartX:PointStartX];
                    
                    if (MACD_TYPE_NONE != self.MACDType)
                        [self drawMACDItem:item context:context PointStartX:PointStartX];
                    //else cont.
                    
                    PointStartX -= self.frontKLineWidth + self.frontKLinePadding; // 生成下一个点的x轴
                }
                else
                {
                    //计算self.kCount时，可能在取整的时候有偏差，所以最后的一个或两个可能会进入这个分支。
                    break;
                }//endi
            }//endf
        }//end atuo pool
    }
}

#pragma mark - kline

- (void) drawKLineItem:(NSMutableDictionary*)item
               context:(CGContextRef)context
           PointStartX:(CGFloat)PointStartX
             tempArray:(NSMutableArray *)tempArray
                nIndex:(NSInteger)nIndex
{
    CGFloat heightvalue = [[item objectForKey:PRICEHIGH] doubleValue];// 得到最高价
    CGFloat lowvalue = [[item objectForKey:PRICELOW] doubleValue];// 得到最低价
    CGFloat openvalue = [[item objectForKey:PRICEOPEN] doubleValue];// 得到开盘价
    CGFloat closevalue = [[item objectForKey:PRICELAST] doubleValue];// 得到收盘价
    CGFloat yViewHeight = _mainBoxFrame.size.height ;// y的实际像素高度
    // 换算成实际的坐标
    CGFloat heightPointY =  [self yAxisFromPrice:heightvalue mainHeight:yViewHeight];
    CGPoint heightPoint =  CGPointMake(PointStartX, heightPointY); // 最高价换算为实际坐标值
    
    CGFloat lowPointY = [self yAxisFromPrice:lowvalue mainHeight:yViewHeight];
    CGPoint lowPoint =  CGPointMake(PointStartX, lowPointY); // 最低价换算为实际坐标值
    
    CGFloat openPointY = [self yAxisFromPrice:openvalue mainHeight:yViewHeight];
    CGPoint openPoint =  CGPointMake(PointStartX, openPointY); // 开盘价换算为实际坐标值
    
    CGFloat closePointY = [self yAxisFromPrice:closevalue mainHeight:yViewHeight];
    
    CGPoint closePoint =  CGPointMake(PointStartX, closePointY); // 收盘价换算为实际坐标值
    
    [self drawMaxAndMinPrice:heightvalue
                 PointStartX:PointStartX
                heightPointY:heightPointY
                    lowvalue:lowvalue
                   lowPointY:lowPointY];
    
    // 实际坐标组装为数组
    if (tempArray)
    {
        [item setObject:@(PointStartX) forKey:Origin_X];
        [tempArray addObject:item];
    }
    //else cont.
    
    if (!self.bTimeLine)
    {
        // 首先判断是绿的还是红的，根据开盘价和收盘价的坐标来计算
        // 如果开盘价坐标在收盘价坐标上方 则为绿色 即空
        if (openPoint.y <= closePoint.y)
        {
            if( closePoint.y - openPoint.y < 3.0f )
                closePoint.y = openPoint.y + 3.0f;
            //else cont.
            
            [self setRGBColorWithContext:context bRise:NO];
        }
        else
        {
            if( openPoint.y - closePoint.y < 3.0f )
                openPoint.y = closePoint.y + 3.0f;
            //else cont.
            
            [self setRGBColorWithContext:context bRise:YES];
        }//endi
        
        // 首先画一个垂直的线包含上影线和下影线
        // 定义两个点 画两点连线
        CGContextSetLineWidth(context, 1); // 上下阴影线的宽度
        if (self.frontKLineWidth <= 2)
        {
            CGContextSetLineWidth(context, 0.5); // 上下阴影线的宽度
        }
        
        heightPoint.y += _mainBoxFrame.origin.y;
        lowPoint.y += _mainBoxFrame.origin.y;
        
        const CGPoint points[] = {heightPoint,lowPoint};
        CGContextStrokeLineSegments(context, points, 2);  // 绘制线段（默认不绘制端点）
        
        // 再画中间的实体
        CGContextSetLineWidth(context, self.frontKLineWidth); // 改变线的宽度
        
        // 开始画实体
        openPoint.y += _mainBoxFrame.origin.y;
        closePoint.y += _mainBoxFrame.origin.y;
        const CGPoint point[] = {openPoint,closePoint};
        CGContextStrokeLineSegments(context, point, 2);  // 绘制线段（默认不绘制端点）
    }
}

- (void) drawVolumeItem:(NSMutableDictionary*)item
                context:(CGContextRef)context
            PointStartX:(CGFloat)PointStartX
{
    CGFloat volumevalue = [[item objectForKey:AMOUNT] doubleValue];// 得到成交量
    CGFloat amountSpan = [self getAmountSpan] ; // y的价格高度
    
    NSInteger nCrollLineHeight = 15.0f;
    
    NSInteger yViewHeight = _amountBoxFrame.size.height - nCrollLineHeight - 1.0f;// y的实际像素高度
    NSInteger volumePointY = yViewHeight * (1 - (volumevalue - self.frontAmountMinValue) / amountSpan);
    
    if (volumevalue >= 0)
    {
        if (yViewHeight - volumePointY < 1.0f)
            volumePointY = yViewHeight - 1.0f;
        //else cont.
        CGPoint volumePoint =  CGPointMake(PointStartX, volumePointY); // 成交量换算为实际坐标值
        CGPoint volumePointStart = CGPointMake(PointStartX, yViewHeight);
        
        // 把开盘价收盘价放进去好计算实体的颜色
        CGFloat openvalue = [[item objectForKey:PRICEOPEN] doubleValue];// 得到开盘价
        CGFloat closevalue = [[item objectForKey:PRICELAST] doubleValue];// 得到收盘价
        
        {
            // 首先判断是绿的还是红的，根据开盘价和收盘价的坐标来计算
            // 如果开盘价坐标在收盘价坐标上方 则为绿色 即空
            if (closevalue <= openvalue)
            {
                [self setRGBColorWithContext:context bRise:NO];
            }
            else
            {
                [self setRGBColorWithContext:context bRise:YES];
            }//endi
            
            // 再画中间的实体
            CGContextSetLineWidth(context, self.frontKLineWidth); // 改变线的宽度
            // 纠正实体的中心点为当前坐标
            volumePointStart.y += _amountBoxFrame.origin.y + nCrollLineHeight;
            volumePoint.y += _amountBoxFrame.origin.y + nCrollLineHeight;
            
            // 开始画实体
            const CGPoint point[] = {volumePointStart,volumePoint};
            CGContextStrokeLineSegments(context, point, 2);  // 绘制线段（默认不绘制端点）
        }
    }
    else
        HB_LOG(@"error!");

}

- (void) drawMACDItem:(NSMutableDictionary*)item
                context:(CGContextRef)context
            PointStartX:(CGFloat)PointStartX
{
    CGFloat volumevalue = [[item objectForKey:MACD_MACD] doubleValue];
    if (volumevalue != MAXFLOAT)
    {
        CGFloat yHeight = self.frontMACDMaxValue - self.frontMACDMinValue ; // y的价格高度
        NSInteger nCrollLineHeight = 15.0f;
        CGFloat yViewHeight = self.macdBoxHeight - nCrollLineHeight;// y的实际像素高度
        
        CGFloat yMiddle = yViewHeight * (1 - (0 - self.frontMACDMinValue) / yHeight);
        // 首先判断是绿的还是红的，根据开盘价和收盘价的坐标来计算
        // 如果开盘价坐标在收盘价坐标上方 则为绿色 即空
        if (volumevalue < 0)
        {
            if (yHeight)
            {
                [self setRGBColorWithContext:context bRise:NO];
                
                // 换算成实际的坐标
                NSInteger volumePointY = yViewHeight * (1 - (volumevalue - self.frontMACDMinValue) / yHeight);
                CGPoint volumePoint =  CGPointMake(PointStartX, volumePointY); // 成交量换算为实际坐标值
                CGPoint volumePointStart = CGPointMake(PointStartX, yMiddle);
                
                // 再画中间的实体
                CGContextSetLineWidth(context, self.frontKLineWidth); // 改变线的宽度
                // 纠正实体的中心点为当前坐标
                volumePointStart.y += _macdBoxFrame.origin.y + nCrollLineHeight;
                volumePoint.y += _macdBoxFrame.origin.y + nCrollLineHeight;
                // 开始画实体
                const CGPoint point[] = {volumePointStart,volumePoint};
                CGContextStrokeLineSegments(context, point, 2);  // 绘制线段（默认不绘制端点）
            }
            else
                HB_LOG(@"error!");
        }
        else if (volumevalue > 0)
        {
            
            if (yHeight)
            {
                [self setRGBColorWithContext:context bRise:YES];
                
                // 换算成实际的坐标
                NSInteger volumePointY = yViewHeight * (1 - (volumevalue - self.frontMACDMinValue) / yHeight);
                CGPoint volumePoint =  CGPointMake(PointStartX, volumePointY); // 成交量换算为实际坐标值
                CGPoint volumePointStart = CGPointMake(PointStartX, yMiddle);
                
                // 再画中间的实体
                CGContextSetLineWidth(context, self.frontKLineWidth); // 改变线的宽度
                // 纠正实体的中心点为当前坐标
                volumePointStart.y += _macdBoxFrame.origin.y + nCrollLineHeight;
                volumePoint.y += _macdBoxFrame.origin.y + nCrollLineHeight;
                // 开始画实体
                const CGPoint point[] = {volumePointStart,volumePoint};
                CGContextStrokeLineSegments(context, point, 2);  // 绘制线段（默认不绘制端点）
            }
            else
                HB_LOG(@"error!");
            
        }//endi
    }
    //else 无效值；

}

- (void) drawMaxAndMinPrice:(CGFloat)heightvalue
                PointStartX:(CGFloat)PointStartX
               heightPointY:(CGFloat)heightPointY
                   lowvalue:(CGFloat)lowvalue
                  lowPointY:(CGFloat)lowPointY
{
    if (self.dataMaxValue - heightvalue < 0.001f)
    {
        /*********************************特别说明：***************************************
         由于分时线没有标出每分钟的最高价和最低价，所以_priceHighLab会指向空白区域，显得莫名其妙。
         所以暂时决定：在分时线上不显示最高价和最低价标签
         ********************************************************************************/
        if (!self.bTimeLine)
        {
            _priceHighLab.hidden = NO;
            NSString* strValue = [DLTextAttributeData stringNotRounding:self.dataMaxValue afterPoint:2];
            _priceHighLab.text = [NSString stringWithFormat:@"←%@",strValue];
            //_priceHighLab.text = [NSString stringWithFormat:@"←%.2f",self.dataMaxValue];
            [_priceHighLab sizeToFit];
            
            CGRect highRect = _priceHighLab.frame;
            highRect.origin.x = PointStartX;
            if (highRect.origin.x + highRect.size.width > _mainBoxFrame.size.width)
            {
                highRect.origin.x = PointStartX - highRect.size.width;
                NSString* strMaxValue = [DLTextAttributeData stringNotRounding:self.dataMaxValue afterPoint:2];
                _priceHighLab.text = [NSString stringWithFormat:@"%@→",strMaxValue];
            }
            //else cont.
            highRect.origin.y = heightPointY - _priceHighLab.frame.size.height;
            _priceHighLab.frame = highRect;
        }
        else
            _priceHighLab.hidden = YES;
        
        //@"→",@"←";
    }
    //else cont.
    
    if (-0.00001f < self.dataMinValue - lowvalue && self.dataMinValue - lowvalue < 0.00001f)
    {
        /*********************************特别说明：***************************************
         由于分时线没有标出每分钟的最高价和最低价，所以_priceHighLab会指向空白区域，显得莫名其妙。
         所以暂时决定：在分时线上不显示最高价和最低价标签
         ********************************************************************************/
        
        if (!self.bTimeLine)
        {
            _priceLowLab.hidden = NO;
            _priceLowLab.text = [NSString stringWithFormat:@"←%@",NOTROUNDING(self.dataMinValue,2)];
            [_priceLowLab sizeToFit];
            CGRect lowRect = _priceLowLab.frame;
            lowRect.origin.x = PointStartX;
            if (lowRect.origin.x + lowRect.size.width > _mainBoxFrame.size.width)
            {
                lowRect.origin.x = PointStartX - lowRect.size.width;
                NSString* strMinValue = [DLTextAttributeData stringNotRounding:self.dataMinValue afterPoint:2];
                _priceLowLab.text = [NSString stringWithFormat:@"%@→",strMinValue];
            }
            //else cont.
            
            [_priceLowLab sizeToFit];
            lowRect.origin.y = lowPointY;
             if (lowRect.origin.y + lowRect.size.height > _mainBoxFrame.origin.y + _mainBoxFrame.size.height)
             {
                 HB_LOG(@"error!");
                 lowRect.origin.y = _mainBoxFrame.origin.y + _mainBoxFrame.size.height - lowRect.size.height;
             }
            _priceLowLab.frame = lowRect;
            
        }
        else
            _priceLowLab.hidden = YES;
        
    }
    //else cont.
}

#pragma mark - 平均线

//testTheDemo
- (void) drawLineBreakOffWithContext:(CGContextRef)context
         nPointX:(CGFloat)x
         nPointY:(CGFloat)y
{
    [self closePath:context];
    [self beginPath:context];
    CGContextMoveToPoint(context, x, y);
}

- (CGFloat) yAxisFromPrice:(CGFloat)currentValue mainHeight:(CGFloat)mainHeight
{
    CGFloat result = 0;
    
    CGFloat beginPrice;
    CGFloat endPrice;
    
    CGFloat spanPrice = self.frontMaxValue - self.frontMinValue;
    if (spanPrice > 0.01)
    {
        beginPrice = self.frontMinValue;
        endPrice = self.frontMaxValue;
    }
    else
    {
        beginPrice = self.frontMinValue - 1;
        CGFloat padValue = 1.0f;
        endPrice = padValue * (KLINE_COUNT - 1) + beginPrice;
    }//endi
    
    CGFloat nEndge = KLINE_EDGE_TOP + KLINE_EDGE_BOTTOM;
    CGFloat rate = (currentValue - beginPrice) / (endPrice - beginPrice);
    result = _mainBoxFrame.origin.y + mainHeight - rate * (mainHeight - nEndge) - KLINE_EDGE_BOTTOM;
    
    return result;
}

- (void) drawLineWithContext:(CGContextRef)context
                          data:(NSArray*)data
                       indexKey:(NSString*)indexKey
                      andColor:(CGFloat*)lineColor

{
    CGFloat PointStartX = _mainBoxFrame.origin.x + _mainBoxFrame.size.width -  self.frontKLineWidth / 2;//0.0f; // 起始点坐标
    if ( [data count] < self.kCount)
    {
        PointStartX = _mainBoxFrame.origin.x + [data count] * (self.frontKLineWidth + self.frontKLinePadding);
    }
    
    NSInteger kLineCount = [self getKLineCount];

    CGFloat mainHeight = _mainBoxFrame.size.height;
    CGFloat mainY = _mainBoxFrame.origin.y + mainHeight;
    
    
    NSInteger theEndIndex = [data count] - kLineCount;
    NSInteger nIndex = [data count] - 1;
    
    NSInteger currentPointY;
    for (; nIndex >= theEndIndex; nIndex--)
    {
        if (PointStartX > _mainBoxFrame.origin.x)
        {

            NSDictionary* item = [data objectAtIndex:nIndex];
            NSNumber* theValue = [item objectForKey:indexKey];
            CGFloat currentValue = [theValue doubleValue];
            if (theValue && currentValue != MAXFLOAT)
            {
                // 换算成实际的坐标
                currentPointY =  [self yAxisFromPrice:currentValue mainHeight:mainHeight];
                CGPoint currentPoint =  CGPointMake(PointStartX, currentPointY); // 换算到当前的坐标值
                
                if ([data count] - 1 == nIndex)
                {
                    CGContextSetRGBStrokeColor(context, lineColor[0], lineColor[1], lineColor[2], self.alpha);
                    [self beginPath:context];
                    CGContextMoveToPoint(context, currentPoint.x, currentPoint.y);
                }
                else if (currentPointY > _mainBoxFrame.origin.y )
                {
                    if ( currentPointY <= mainY )
                    {
                        CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y);
                        CGContextStrokePath(context); //开始画线
                        CGContextMoveToPoint(context, currentPoint.x, currentPoint.y);
                    }
                    else
                    {
                        [self drawLineBreakOffWithContext:context nPointX:currentPoint.x nPointY:mainY];
                    }//endi
                }
                else
                {
                    [self drawLineBreakOffWithContext:context nPointX:currentPoint.x nPointY:_mainBoxFrame.origin.y];
                }//endi
                
                PointStartX -= self.frontKLineWidth + self.frontKLinePadding; // 生成下一个点的x轴
            }
            else
            {
                break;
            }
        }
        else
            HB_LOG(@"error!");
    }//endf
    
    [self closePath:context];
}

- (void) beginPath:(CGContextRef)context
{
    if (_contextCount < 0)
    {
        int i = 0;
        i++;
    }
    CGContextBeginPath(context);
    _contextCount++;
}

- (void) closePath:(CGContextRef)context
{
    if (_contextCount <= 0)
    {
        int i = 0;
        i++;
    }
    else
    {
        CGContextClosePath(context);
        _contextCount--;
    }

}

- (CGFloat) yAxisFromAmount:(CGFloat)currentValue mainHeight:(CGFloat)mainHeight
{
    CGFloat result = 0;
    

    
    return result;
}

- (void) drawAmountLineWithContext:(CGContextRef)context
                        data:(NSArray*)data
                     indexKey:(NSString*)indexKey
                    andColor:(CGFloat*)lineColor

{
    CGFloat PointStartX = _amountBoxFrame.origin.x + _amountBoxFrame.size.width -  self.frontKLineWidth / 2;//0.0f; // 起始点坐标
    if ( [data count] < self.kCount)
    {
        PointStartX = _mainBoxFrame.origin.x + [data count] * (self.frontKLineWidth + self.frontKLinePadding);
    }
    //else cont.
    
    NSInteger kLineCount = [self getKLineCount];
    
    NSInteger nCrollLineHeight = 15.0f;

    CGFloat mainHeight = _amountBoxFrame.size.height - nCrollLineHeight;
    
    CGFloat mainY = _amountBoxFrame.origin.y + mainHeight + nCrollLineHeight;
    
    CGFloat currentPointY;
    

    
    NSInteger theEndIndex = [data count] - kLineCount;
    for (NSInteger nIndex = [data count] - 1; nIndex >= theEndIndex; nIndex--)
    {
        if (PointStartX > _amountBoxFrame.origin.x)
        {
            NSDictionary* item = [data objectAtIndex:nIndex];
            CGFloat currentValue = [[item objectForKey:indexKey] doubleValue];
            if (currentValue !=  MAXFLOAT)
            {
                // 换算成实际的坐标
                currentPointY =  mainY - ((currentValue - self.frontAmountMinValue) / [self getAmountSpan] * mainHeight);
                CGPoint currentPoint =  CGPointMake(PointStartX, currentPointY); // 换算到当前的坐标值
                if ([data count] - 1 == nIndex)
                {
                    CGContextSetRGBStrokeColor(context, lineColor[0], lineColor[1], lineColor[2], self.alpha);
                    [self beginPath:context];
                    CGContextMoveToPoint(context, currentPoint.x, currentPoint.y);
                }
                else if (_amountBoxFrame.origin.y < currentPointY)
                {
                    if ( currentPointY <= mainY )
                    {
                        CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y);
                        CGContextStrokePath(context); //开始画线
                        CGContextMoveToPoint(context, currentPoint.x, currentPoint.y);
                    }
                    else
                    {
                        [self drawLineBreakOffWithContext:context nPointX:currentPoint.x nPointY:mainY];
                    }//endi
                }
                else
                {
                    [self drawLineBreakOffWithContext:context nPointX:currentPoint.x nPointY:_amountBoxFrame.origin.y];
                }//endi
            }
            else
            {
                if (nIndex < [data count] - 1)
                    [self closePath:context];
                //else do nothing
            }//endi
            
            PointStartX -= self.frontKLineWidth + self.frontKLinePadding; // 生成下一个点的x轴
        }
        else
            HB_LOG(@"error!");
        
    }//endf
    
    [self closePath:context];
}

#pragma mark - macd line

- (CGFloat) yAxisFromMACDValue:(CGFloat )currentValue boundsHeight:(CGFloat)boundsHeight
{
    CGFloat currentPointY;
    // 换算成实际的坐标
    CGFloat macdSpan = (self.frontMACDMaxValue - self.frontMACDMinValue);
    
    if (macdSpan > 0.00000001)
    {
        CGFloat rate = (currentValue - self.frontMACDMinValue) / macdSpan;
        currentPointY =  _macdBoxFrame.origin.y + _macdBoxFrame.size.height - (rate * boundsHeight) - 1.0f;
    }
    else
        currentPointY = _macdBoxFrame.origin.y + _macdBoxFrame.size.height - boundsHeight / 2  - 1.0f;
    
    return currentPointY;
}

- (void) drawMACDLineWithContext:(CGContextRef)context
                              data:(NSArray*)data
                           indexKey:(NSString*)indexKey
                          andColor:(CGFloat*)lineColor

{
    CGFloat PointStartX = _macdBoxFrame.origin.x + _macdBoxFrame.size.width -  self.frontKLineWidth / 2;//0.0f; // 起始点坐标
    if ( [data count] < self.kCount)
    {
        PointStartX = _mainBoxFrame.origin.x + [data count] * (self.frontKLineWidth + self.frontKLinePadding);
    }
    //else cont.
    
    NSInteger kLineCount = [self getKLineCount];

    NSInteger nCrollLineHeight = 15.0f;
    
    CGFloat boundsHeight = _macdBoxFrame.size.height - nCrollLineHeight;

    NSInteger theEndIndex = [data count] - kLineCount;
    
    for (NSInteger nIndex = [data count] - 1; nIndex >= theEndIndex; nIndex--)
    {
        if (PointStartX > _macdBoxFrame.origin.x)
        {
            NSDictionary* item = [data objectAtIndex:nIndex];
            CGFloat currentValue = [[item objectForKey:indexKey] doubleValue];
            if (currentValue != MAXFLOAT)
            {
                // 换算成实际的坐标
                CGFloat currentPointY = [self yAxisFromMACDValue:currentValue boundsHeight:boundsHeight];
                
                CGPoint currentPoint =  CGPointMake(PointStartX, currentPointY); // 换算到当前的坐标值
                
                if ([data count] - 1 == nIndex)
                {
                    CGContextSetRGBStrokeColor(context, lineColor[0], lineColor[1], lineColor[2], self.alpha);
                    [self beginPath:context];
                    CGContextMoveToPoint(context, currentPoint.x, currentPoint.y);
                }
                else if (currentPoint.y > _macdBoxFrame.origin.y )
                {
                    if ( currentPointY <= _macdBoxFrame.origin.y + _macdBoxFrame.size.height )
                    {
                        CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y);
                        CGContextStrokePath(context); //开始画线
                        CGContextMoveToPoint(context, currentPoint.x, currentPoint.y);
                    }
                    else
                    {
                        [self drawLineBreakOffWithContext:context nPointX:currentPoint.x nPointY:_macdBoxFrame.origin.y + _macdBoxFrame.size.height];
                    }
                }
                else
                {
                    [self drawLineBreakOffWithContext:context nPointX:currentPoint.x nPointY:_macdBoxFrame.origin.y];
                }//endi
            }
            else
            {
                if (nIndex < [data count] - 1)
                {
                    [self closePath:context];
                    break;
                }
                //else do nothing
            }//endi
            
            PointStartX -= self.frontKLineWidth + self.frontKLinePadding; // 生成下一个点的x轴
        }
        else
            HB_LOG(@"error!");
        
    }//endf
    
    [self closePath:context];
}


#pragma mark - draw Axis


- (void) drawTimeBoxWithContext:(CGContextRef)context
{
#if 0 //上边线
    {
        NSInteger originY = _timeFrame.origin.y;
        CGPoint theStart = CGPointMake(_timeFrame.origin.x + _timeFrame.size.width, originY);
        CGPoint theFinish = CGPointMake(_timeFrame.origin.x, originY);
        const CGPoint rectPoints[] = {theStart,  theFinish};
        
        UIColor* landColor = [UIColor colorWithHexString:@"0xffffff" withAlpha:1.0];
        CGContextSetStrokeColorWithColor(context, landColor.CGColor);
        CGContextSetLineWidth(context, 1.0);
        CGContextSetShouldAntialias(context, NO);
        CGContextStrokeLineSegments(context, rectPoints, 2);  // 绘制线段（默认不绘制端点）
    }
#endif
    
    {
        NSInteger originY = _timeFrame.origin.y + _timeFrame.size.height / 2 + 1;
        CGPoint theStart = CGPointMake(_timeFrame.origin.x + _timeFrame.size.width, originY);
        CGPoint theFinish = CGPointMake(_timeFrame.origin.x, originY);
        const CGPoint rectPoints[] = {theStart,  theFinish};
        
        UIColor* landColor = [UIColor colorWithHexString:@"0x20232b" withAlpha:1.0];
        CGContextSetStrokeColorWithColor(context, landColor.CGColor);
        
        CGContextSetLineWidth(context, _timeFrame.size.height);
        CGContextSetShouldAntialias(context, NO);
        CGContextStrokeLineSegments(context, rectPoints, 2);  // 绘制线段（默认不绘制端点）
    }
    
#if 0 //下边线
    {
        NSInteger originY = _timeFrame.origin.y + _timeFrame.size.height;
        CGPoint theStart = CGPointMake(_timeFrame.origin.x + _timeFrame.size.width, originY);
        CGPoint theFinish = CGPointMake(_timeFrame.origin.x, originY);
        const CGPoint rectPoints[] = {theStart,  theFinish};
        
        UIColor* landColor = [UIColor colorWithHexString:@"0xffffff" withAlpha:1.0];
        CGContextSetStrokeColorWithColor(context, landColor.CGColor);
        CGContextSetLineWidth(context, 1.0);
        CGContextSetShouldAntialias(context, NO);
        CGContextStrokeLineSegments(context, rectPoints, 2);  // 绘制线段（默认不绘制端点）
    }
#endif
}

- (CGFloat) getOriginY
{
    CGFloat result = 0;
    if (MACD_TYPE_NONE != self.MACDType)
        result = _macdBoxFrame.origin.y + _macdBoxFrame.size.height;
    else
        result = _amountBoxFrame.origin.y + _amountBoxFrame.size.height;
    
    return result;
}

- (NSInteger) getYAxisMinRemainder:(NSInteger)theKLineCount textWidth:(CGFloat)textWidth
{
    NSInteger mainRemainder = 8;
    NSInteger totoleTextCount = 0;
    for (NSInteger nIndex = 8; nIndex > 3; nIndex--)
    {
        NSInteger tempRemainder = theKLineCount % nIndex;
        if (mainRemainder > tempRemainder)
        {
            mainRemainder = tempRemainder;
            totoleTextCount = nIndex;
        }
        //else cont.
    }//endf
    
    NSInteger maxTextCount = theKLineCount * (self.kLineWidth + self.kLinePadding) / textWidth;
    if (totoleTextCount > maxTextCount)
    {
        totoleTextCount = maxTextCount;
    }
    //else cont.
    
    return totoleTextCount;
}

- (NSInteger) getKLineCount
{
    NSInteger theKLineCount = self.kCount;
    if ( [self.data count] < theKLineCount)
    {
        theKLineCount = [self.data count];
    }
    //else cont.
    
    return theKLineCount;
}

- (void) drawYAxis:(CGContextRef)context strPeriod:(NSString*)strPeriod
{
    if ([self.delegate respondsToSelector:@selector(getTimeFromatByPeriod:)])
    {
        NSDictionary* timeAttribute = [[DLMainManager sharedTextAttributeData] getKLineTimeAttributeDict];
        NSString* strTimeFormat = [self.delegate getTimeFromatByPeriod:strPeriod];
        CGSize textSize = [DLTextAttributeData sizeOfString:strTimeFormat withDict:timeAttribute];
        CGFloat textWidth = textSize.width;
        
        UIColor* lineColor = [UIColor colorWithHexString:@"#333e4b" withAlpha:1.0f]; // 设置颜色
        CGContextSetLineWidth(context, 1.0f);
        CGContextSetShouldAntialias(context, NO);
        CGContextSetStrokeColorWithColor(context, lineColor.CGColor);

        CGFloat originY = [self getOriginY];
        NSInteger theKLineCount = [self getKLineCount];
        
        NSInteger PointStartX = _mainBoxFrame.origin.x + _mainBoxFrame.size.width;// 起始点坐标
        if ( [self.data count] < self.kCount)
        {
            //最右侧的线
            const CGPoint beginPoints[] = {CGPointMake(PointStartX, _mainBoxFrame.origin.y + 1.0f),CGPointMake(PointStartX, originY)};
            CGContextStrokeLineSegments(context, beginPoints, 2);  // 绘制线段（默认不绘制端点）
            PointStartX = _mainBoxFrame.origin.x + theKLineCount * (self.frontKLineWidth + self.frontKLinePadding);
        }
        //else cont.
        
        if ([self.data count] > 0)
        {
            //begin time
            const CGPoint beginPoints[] = {CGPointMake(PointStartX, _mainBoxFrame.origin.y + 1.0f),CGPointMake(PointStartX, originY)};
            CGContextStrokeLineSegments(context, beginPoints, 2);  // 绘制线段（默认不绘制端点）
            
            //中间刻度
            PointStartX -= self.frontKLineWidth/2;
    
            NSInteger totoleTextCount = [self getYAxisMinRemainder:theKLineCount textWidth:textWidth];
            NSInteger timeInterval = theKLineCount / ( totoleTextCount - 1 );
            for (NSInteger nIndex = 1; nIndex < totoleTextCount - 1; nIndex++)
            {
                PointStartX -= timeInterval * (self.frontKLineWidth + self.frontKLinePadding); // 生成下一个点的x轴
                const CGPoint points[] = {CGPointMake(PointStartX, _mainBoxFrame.origin.y + 1.0f), CGPointMake(PointStartX, originY)};
                CGContextStrokeLineSegments(context, points, 2);  // 绘制线段（默认不绘制端点）
            }//endf
            
            const CGPoint endPoints[] = {CGPointMake( _amountBoxFrame.origin.x - 1.0f, _mainBoxFrame.origin.y + 1.0f), CGPointMake( _amountBoxFrame.origin.x - 1.0f, originY)};
            CGContextStrokeLineSegments(context, endPoints, 2);  // 绘制线段（默认不绘制端点）
        }
        else
        {
            const CGPoint endPoints[] = {CGPointMake( _amountBoxFrame.origin.x, _mainBoxFrame.origin.y + 1.0f), CGPointMake( _amountBoxFrame.origin.x, originY)};
            CGContextStrokeLineSegments(context, endPoints, 2);  // 绘制线段（默认不绘制端点）
        }//endi

        [self drawTimeWithContext:context strPeriod:strPeriod];
    }
    //else cont.
}

- (void) drawTimeWithContext:(CGContextRef)context strPeriod:(NSString*)strPeriod
{
    [self drawTimeBoxWithContext:context];
    
    NSInteger theKLineCount = [self getKLineCount];
    NSDictionary* timeAttribute = [[DLMainManager sharedTextAttributeData] getKLineTimeAttributeDict];
    NSString* strTimeFormat = [self.delegate getTimeFromatByPeriod:strPeriod];
    [_timeDateFormatter setDateFormat:strTimeFormat];
    if ([self.delegate respondsToSelector:@selector(getTimeFromatByPeriod:)])
    {
        CGSize textSize = [DLTextAttributeData sizeOfString:strTimeFormat withDict:timeAttribute];
        CGFloat textWidth = textSize.width;
        NSInteger PointStartX = _mainBoxFrame.origin.x + _mainBoxFrame.size.width;// 起始点坐标
        if ([self.data count] > 0)
        {
            CGFloat timeOriginY = 0;
            if (MACD_TYPE_NONE != self.MACDType)
                timeOriginY = _timeFrame.origin.y + (_timeFrame.size.height - textSize.height ) / 2 ;
            else
                timeOriginY = _timeFrame.origin.y + (_timeFrame.size.height - textSize.height ) / 2 ;
            
            NSInteger beginTime = [self getTimeWithIndex:[self.data count] - 1];
            NSDate* beginTimeDate = [NSDate dateWithTimeIntervalSince1970:beginTime];
            NSString *beginTimeString = [_timeDateFormatter stringFromDate:beginTimeDate];
            [DLTextAttributeData drawString:beginTimeString atPoint:CGPointMake(PointStartX - textWidth, timeOriginY) withAttributes:timeAttribute];
            
            //中间刻度
            PointStartX -= self.frontKLineWidth/2;
            
            NSInteger totoleTextCount = [self getYAxisMinRemainder:theKLineCount textWidth:textWidth];
            
            NSInteger timeInterval = theKLineCount / ( totoleTextCount - 1 );
            NSUInteger arrayCount = [self.data count] - 1;
            for (NSInteger nIndex = 1; nIndex < totoleTextCount - 1; nIndex++)
            {
                PointStartX -= timeInterval * (self.frontKLineWidth + self.frontKLinePadding); // 生成下一个点的x轴
                NSInteger currentTime = [self getTimeWithIndex:(arrayCount - nIndex * timeInterval)];
                NSDate* timeDate = [NSDate dateWithTimeIntervalSince1970:currentTime];
                NSString *timeString = [_timeDateFormatter stringFromDate:timeDate];
                [DLTextAttributeData drawString:timeString atPoint:CGPointMake(PointStartX - textWidth / 3, timeOriginY) withAttributes:timeAttribute];
            }//endf
            
            //终点刻度
            NSTimeInterval time = [self getTimeWithIndex:(arrayCount - theKLineCount + 1)];
            NSDate* endTimeDate = [NSDate dateWithTimeIntervalSince1970:time];
            NSString *endTimeString = [_timeDateFormatter stringFromDate:endTimeDate];
            [DLTextAttributeData drawString:endTimeString atPoint:CGPointMake(KLINE_LEFT_SPAN, timeOriginY) withAttributes:timeAttribute];
        }
        else
        {
            
        }
    }

}

- (NSInteger) getTimeWithIndex:(NSInteger)nIndex
{
    NSInteger result;
    if (nIndex < [self.data count])
    {
        NSDictionary* item = [self.data objectAtIndex:nIndex];
        NSNumber* time = [item objectForKey:TIME];
        if (time)
        {
            result = [time integerValue];
        }
        else
            HB_LOG(@"error!");
    }
    else
        HB_LOG(@"error!");
    
    return result;
}

- (void) drawXAxisDetailKLine:(CGContextRef)context
{
#if 0
    //交易量分割线
    {
        CGFloat volumnY = _amountBoxFrame.origin.y + 1.0f;
        CGPoint middleVolumePoint = CGPointMake(_mainBoxFrame.origin.x + _mainBoxFrame.size.width, volumnY);
        const CGPoint points[] = {CGPointMake(_mainBoxFrame.origin.x - 1.0f, volumnY), middleVolumePoint};
        CGContextStrokeLineSegments(context, points, 2);  // 绘制线段（默认不绘制端点）
    }
    
    {
        NSInteger volumnY = _amountBoxFrame.origin.y + _amountBoxFrame.size.height / 2;
        CGPoint middleVolumePoint = CGPointMake(_mainBoxFrame.origin.x + _mainBoxFrame.size.width, volumnY);
        const CGPoint points[] = {CGPointMake(_mainBoxFrame.origin.x - 1.0f, volumnY), middleVolumePoint};
        CGContextStrokeLineSegments(context, points, 2);  // 绘制线段（默认不绘制端点）
    }
    

    {
        NSInteger macdBeginY = _macdBoxFrame.origin.y + 1.0f;
        NSInteger macdBeginRightX = _macdBoxFrame.origin.x + _macdBoxFrame.size.width + 1.0f;
        CGPoint macdPoint = CGPointMake(macdBeginRightX, macdBeginY);
        const CGPoint points[] = {CGPointMake(_macdBoxFrame.origin.x - 1.0f, macdBeginY), macdPoint};
        CGContextStrokeLineSegments(context, points, 2);  // 绘制线段（默认不绘制端点）
    }
    
    {
        NSInteger macdY = _macdBoxFrame.origin.y + _macdBoxFrame.size.height;
        NSInteger macdX = _macdBoxFrame.origin.x + _macdBoxFrame.size.width + 1.0f;
        CGPoint macdPoint = CGPointMake(macdX, macdY);
        const CGPoint points[] = {CGPointMake(_macdBoxFrame.origin.x - 1.0f, macdY), macdPoint};
        CGContextStrokeLineSegments(context, points, 2);  // 绘制线段（默认不绘制端点）
    }
#endif
}

- (void) drawXAxis:(CGContextRef)context
{
    NSDictionary* timeAttribute = [[DLMainManager sharedTextAttributeData] getKLineTimeAttributeDict];
    
    // 价格分割线
    UIColor* lineColor = [UIColor colorWithHexString:@"#333e4b" withAlpha:1.0f]; // 设置颜色
    CGContextSetLineWidth(context, 1.0f);
    CGContextSetShouldAntialias(context, NO);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    
    CGSize textSize = [DLTextAttributeData sizeOfString:@"0000.00" withDict:timeAttribute];
    
    NSInteger originX = _mainBoxFrame.origin.x + _mainBoxFrame.size.width + SPACE_BETWEEN_KLINE_TAP;
    
    CGFloat padValue = 1;
    CGFloat beginPrice = self.frontMinValue;
    CGFloat endPrice = self.frontMaxValue;
    if (self.frontMaxValue - self.frontMinValue > 0.01)
    {
        padValue = (self.frontMaxValue - self.frontMinValue) / (KLINE_COUNT - 1);
    }
    else
    {
        padValue = 1.0f;
        beginPrice = self.frontMinValue - 1;
        endPrice = padValue * (KLINE_COUNT - 1) + beginPrice;
    }
    
    //Begin
    NSInteger originY = _mainBoxFrame.origin.y + _mainBoxFrame.size.height - 1.0f;
    if (MACD_TYPE_NONE != self.MACDType)
    {
//        const CGPoint beginPoints[] = {CGPointMake(_mainBoxFrame.origin.x - 1.0f, originY), CGPointMake(_mainBoxFrame.origin.x + _mainBoxFrame.size.width, originY)};
//        CGContextStrokeLineSegments(context, beginPoints, 2);  // 绘制线段（默认不绘制端点）
    }
    
    NSString* strBeginPrice = [DLTextAttributeData stringNotRounding:beginPrice afterPoint:2];
    NSInteger beginPriceHeight = textSize.height;
    [DLTextAttributeData drawString:strBeginPrice atPoint:CGPointMake(originX, originY - beginPriceHeight) withAttributes:timeAttribute];
    
    //middle
    CGFloat middlePrice;
    for (int nPriceIndex = 1; nPriceIndex < KLINE_COUNT - 1; nPriceIndex++)
    {
        middlePrice = padValue * nPriceIndex + beginPrice;
        originY = [self yAxisFromPrice:middlePrice mainHeight:_mainBoxFrame.size.height];
        const CGPoint points[] = {CGPointMake(_mainBoxFrame.origin.x - 1.0f, originY), CGPointMake(_mainBoxFrame.origin.x + _mainBoxFrame.size.width, originY)};
        CGContextStrokeLineSegments(context, points, 2);  // 绘制线段（默认不绘制端点）
        
        
        NSString* strPrice = [DLTextAttributeData stringNotRounding:middlePrice afterPoint:2];
        [DLTextAttributeData drawString:strPrice atPoint:CGPointMake(originX, originY - textSize.height/3) withAttributes:timeAttribute];
    }//endi
    
    originY = _mainBoxFrame.origin.y + 1.0f;
    const CGPoint endPoints[] = {CGPointMake(_mainBoxFrame.origin.x - 1.0f, originY), CGPointMake(_mainBoxFrame.origin.x + _mainBoxFrame.size.width, originY)};
    CGContextStrokeLineSegments(context, endPoints, 2);  // 绘制线段（默认不绘制端点）
    
    if (self.bFullScreenMode)
        ;
    else
    {
        //end time
        NSString* strEndPrice = [DLTextAttributeData stringNotRounding:endPrice afterPoint:2];
        [DLTextAttributeData drawString:strEndPrice atPoint:CGPointMake(originX, originY) withAttributes:timeAttribute];
    }

    //macd分割线
    if (MACD_TYPE_NONE != self.MACDType)
        [self drawXAxisDetailKLine:context];
    //do nothing
}
@end
