//
//  ImRealTimeView.m
//  huobiSystem
//
//  Created by FuliangYang on 14-8-21.
//  Copyright (c) 2014年 FuliangYang. All rights reserved.
//

#import "ImRealTimeView.h"
#import "DLTextAttributeData.h"
#import "UIColor+helper.h"
#import "ImHBLog.h"
#import <UIKit/UIKit.h>
//#import "commond.h"
@interface ImRealTimeView()
{
    CATextLayer* _amountLayer;
    CATextLayer* _priceHighLayer;
    CATextLayer* _priceLowLayer;
    CATextLayer* _priceNewLayer;
    
    CALayer* _imageLayer;
}
@end

@implementation ImRealTimeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _priceNewLayer = [[CATextLayer alloc] init];
        [_priceNewLayer setFrame:self.bounds];
        _priceNewLayer.foregroundColor = [UIColor colorWithHexString:@"#576578" withAlpha:1.0].CGColor;
        _priceNewLayer.font = CGFontCreateWithFontName((CFStringRef)[UIFont boldSystemFontOfSize:18.0f].fontName);
        _priceNewLayer.string = @"";
        _priceNewLayer.fontSize = 22.0f;
        _priceNewLayer.contentsScale = 4.0f;
        self.margin = @"     ";
        [self.layer addSublayer:_priceNewLayer];
        
        _imageLayer = [[CALayer alloc] init];
        [_imageLayer setFrame:self.bounds];
        [self.layer addSublayer:_imageLayer];
        _imageLayer.contentsScale = 2.0f;
        [self initPriceLayer];
    }
    return self;
}

- (CATextLayer*) addTextLayerWithLayerName:(NSString*)strName string:(NSString*)stringValue color:(NSString*)colorValue originPoint:(CGPoint)originPoint
{
    NSDictionary* nameAttribute = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12.0f],
                                    NSForegroundColorAttributeName:[UIColor colorWithHexString:colorValue withAlpha:1.0]};
    CGSize amountNameSize = [DLTextAttributeData sizeOfString:stringValue withDict:nameAttribute];
    CGRect nameRect = CGRectMake(originPoint.x, originPoint.y, amountNameSize.width, amountNameSize.height);
    
    CGFontRef cgFont = CGFontCreateWithFontName((CFStringRef)[UIFont boldSystemFontOfSize:12.0f].fontName);
    
    NSDictionary *newActions = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"contents", nil];
    
    CATextLayer* textLayer = [[CATextLayer alloc] init];
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    [textLayer setFrame:nameRect];
    [CATransaction commit];
    textLayer.foregroundColor = [UIColor colorWithHexString:colorValue withAlpha:1.0].CGColor;
    textLayer.font = cgFont;
    textLayer.string = stringValue;
    textLayer.fontSize = 12.0f;
    textLayer.contentsScale = 2.0f;
    textLayer.name = strName;
    textLayer.actions = newActions;
    [self.layer addSublayer:textLayer];
    
    return textLayer;
}

- (CALayer*) getSubLayer:(NSString*)strName
{
    CALayer* aLayer = [DLTextAttributeData getSubLayerOfLayer:self.layer withLayerName:strName];
    
    return aLayer;
}

- (void) initPriceLayer
{
    NSDictionary* valueAttribute = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12.0f],
                                     NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    CGSize amountNameSize = [DLTextAttributeData sizeOfString:@"3333.00" withDict:valueAttribute];
    CGRect nameRect = CGRectMake(0, 0, amountNameSize.width, amountNameSize.height);
    
    NSDictionary *newActions = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"contents", nil];
    
    CGFontRef cgFont = CGFontCreateWithFontName((CFStringRef)[UIFont boldSystemFontOfSize:12.0f].fontName);
    _amountLayer = [[CATextLayer alloc] init];
    [_amountLayer setFrame:nameRect];
    _amountLayer.foregroundColor = [UIColor whiteColor].CGColor;
    _amountLayer.font = cgFont;
    _amountLayer.string = @"       ";
    _amountLayer.fontSize = 12.0f;
    _amountLayer.contentsScale = 2.0f;
    _amountLayer.actions = newActions;
    [self.layer addSublayer:_amountLayer];
    
    _priceHighLayer = [[CATextLayer alloc] init];
    [_priceHighLayer setFrame:nameRect];
    _priceHighLayer.foregroundColor = [UIColor whiteColor].CGColor;
    _priceHighLayer.font = cgFont;
    _priceHighLayer.string = @"       ";
    _priceHighLayer.fontSize = 12.0f;
    _priceHighLayer.contentsScale = 2.0f;
    _priceHighLayer.actions = newActions;
    [self.layer addSublayer:_priceHighLayer];
    
    _priceLowLayer = [[CATextLayer alloc] init];
    [_priceLowLayer setFrame:nameRect];
    _priceLowLayer.foregroundColor = [UIColor whiteColor].CGColor;
    _priceLowLayer.font = cgFont;
    _priceLowLayer.string = @"       ";
    _priceLowLayer.fontSize = 12.0f;
    _priceLowLayer.contentsScale = 2.0f;
    _priceLowLayer.actions = newActions;
    [self.layer addSublayer:_priceLowLayer];
}

- (NSString*) getAmountName
{
//    if (self.bSpotGoods)
//        return NSLocalizedString(@"SR_VolumeAbbr", @"");
//    else
//        return NSLocalizedString(@"SR_AmountAbbr", @"");
    return NSLocalizedString(@"SR_MarketAmount", @"");
}

#define STANDARD_WIDTH      320
#define STANDARD_AMOUNT_X   110

#define STANDARD_HIGH_X     206

- (UIColor*) getChangeColor
{
    UIColor* newColor = 0;
    
//MARK: 预留区分中英文
//    if([commond isChinese])
    if (1)
    {
        switch (self.priceChangeType) {
            case -1:
            {
                newColor = [UIColor greenColor];
                break;
            }
            case 0:
            {
                newColor = [UIColor whiteColor];
                break;
            }
            case 1:
            {
                newColor = [UIColor colorWithHexString:@"#eb402c" withAlpha:1.0];
                break;
            }
            default:
                HB_LOG(@"error!");
                break;
        }
    }
    /*
    else
    {
        
        switch (self.priceChangeType) {
            case -1:
            {
                newColor = [UIColor colorWithHexString:@"#eb402c" withAlpha:1.0];
                break;
            }
            case 0:
            {
                newColor = [UIColor whiteColor];
                break;
            }
            case 1:
            {
                newColor = [UIColor greenColor];
                break;
            }
            default:
                HB_LOG(@"error!");
                break;
        }
    }
     */

    
    return newColor;
}
- (UIImage*) getChangeImage
{
    UIImage* image = nil;
    //MARK: 预留区分中英文
    /*
    if([commond isChinese])
    {
     */
        switch (self.priceChangeType) {
            case -1:
            {
                image = [UIImage imageNamed:@"lvse"];
                break;
            }
            case 0:
            {
                image = [UIImage imageNamed:@"lvse"];
                break;
            }
            case 1:
            {
                image = [UIImage imageNamed:@"hongse"];
                break;
            }
            default:
                HB_LOG(@"error!");
                break;
        }
    /*
    }

    else
    {
        switch (self.priceChangeType) {
            case -1:
            {
                image = [UIImage imageNamed:@"kline_red_down"];
                break;
            }
            case 0:
            {
                image = [UIImage imageNamed:@"kline_red_down"];
                break;
            }
            case 1:
            {
                image = [UIImage imageNamed:@"kline_green_up"];
                break;
            }
            default:
                HB_LOG(@"error!");
                break;
        }
    }
    */
    return image;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (self.priceNew)
        ;
    else
        self.priceNew = @"       ";
    
    UIImage* image = [self getChangeImage];
    UIColor* newColor = [self getChangeColor];

    NSInteger originX = 9;
    
    NSDictionary* newAttribute = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:22.0f],
                                   NSForegroundColorAttributeName:newColor};
    
    CGSize newPriceSize = [DLTextAttributeData sizeOfString:self.priceNew withDict:newAttribute];

    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    [_priceNewLayer setFrame:CGRectMake(originX,
                                        (self.frame.size.height - newPriceSize.height)/2,
                                        newPriceSize.width,
                                        newPriceSize.height)];
    [CATransaction commit];
    _priceNewLayer.foregroundColor = newColor.CGColor;
    _priceNewLayer.string = self.priceNew;
    [_priceNewLayer setNeedsDisplay];
    originX += newPriceSize.width + 3.0f;
    
    if (self.priceChangeType)
        _imageLayer.contents = (__bridge id)(image.CGImage);
    else
        _imageLayer.contents = nil;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    [_imageLayer setFrame:CGRectMake(originX,
                                        (self.frame.size.height - image.size.height)/2,
                                        image.size.width,
                                        image.size.height)];
    [CATransaction commit];
    originX += image.size.width + 10.0f;

    NSDictionary* valueAttribute = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12.0f],
                                    NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    originX = self.bounds.size.width * STANDARD_AMOUNT_X/STANDARD_WIDTH;
    //量Name
    CATextLayer* amountNameLayer = (CATextLayer*)[self getSubLayer:@"amountName"];
    if (!amountNameLayer)
    {
        NSDictionary* nameAttribute = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12.0f],
                                        NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#576578" withAlpha:1.0]};
        CGSize amountNameSize = [DLTextAttributeData sizeOfString:[self getAmountName] withDict:nameAttribute];
        
        CGPoint origin = CGPointMake(originX, self.frame.size.height / 2 + (self.frame.size.height/2 - amountNameSize.height)/2);
        amountNameLayer = [self addTextLayerWithLayerName:@"amountName" string:[self getAmountName] color:@"#576578" originPoint:origin];
    }
    else
    {
        CGRect frame = amountNameLayer.frame;
        frame.origin.x = originX;
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:0];
        [amountNameLayer setFrame:frame];
        [CATransaction commit];
    }//endi

    
    originX += amountNameLayer.frame.size.width + 4.0f;
    
    //量VALUE
    CGSize amountSize = _amountLayer.frame.size;
    if (self.amount && ( ![self.amount isEqualToString:_amountLayer.string]))
    {
        amountSize = [DLTextAttributeData sizeOfString:self.amount withDict:valueAttribute];
        [CATransaction begin];
        [CATransaction setAnimationDuration:0];
        [_amountLayer setFrame:CGRectMake(originX,
                                            amountNameLayer.frame.origin.y,
                                            amountSize.width,
                                            amountSize.height)];
        [CATransaction commit];
        _amountLayer.string = self.amount;
        [_amountLayer setNeedsDisplay];
    }
    
    originX += _amountLayer.frame.size.width + 18.0f;//8.0f;
    
    originX = self.bounds.size.width * STANDARD_HIGH_X / STANDARD_WIDTH;
    
    NSString* SR_HighAbbr = NSLocalizedString(@"SR_HighAbbr", @"");
    NSString* SR_LowAbbr = NSLocalizedString(@"SR_LowAbbr", @"");
    NSString* SR_RatioAbbr = NSLocalizedString(@"SR_RatioAbbr", @"");
    
    //高Name
    CATextLayer* priceHighNameLayer = (CATextLayer*)[self getSubLayer:@"priceHighName"];
    if (!priceHighNameLayer)
    {
        CGPoint origin = CGPointMake(originX, amountNameLayer.frame.origin.y);
        priceHighNameLayer = [self addTextLayerWithLayerName:@"priceHighName" string:SR_HighAbbr color:@"#576578" originPoint:origin];
    }
    else
    {
        CGRect frame = priceHighNameLayer.frame;
        frame.origin.x = originX;
        [CATransaction begin];
        [CATransaction setAnimationDuration:0];
        [priceHighNameLayer setFrame:frame];
        [CATransaction commit];
    }//endi
    
    originX += priceHighNameLayer.frame.size.width + 4.0f;
    
    //高
    CGSize priceHighSize = _priceHighLayer.frame.size;
    if (self.priceHigh && ( ![self.priceHigh isEqualToString:_priceHighLayer.string]))
    {
        priceHighSize = [DLTextAttributeData sizeOfString:self.priceHigh withDict:valueAttribute];
        [CATransaction begin];
        [CATransaction setAnimationDuration:0];
        [_priceHighLayer setFrame:CGRectMake(originX,
                                             priceHighNameLayer.frame.origin.y,
                                             priceHighSize.width,
                                             priceHighSize.height)];
        [CATransaction commit];
        _priceHighLayer.string = self.priceHigh;
        [_priceHighLayer setNeedsDisplay];
    }

    
    //低Name
    CATextLayer* priceLowNameLayer = (CATextLayer*)[self getSubLayer:@"priceLowName"];
    if (!priceLowNameLayer)
    {
        NSDictionary* nameAttribute = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12.0f],
                                        NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#576578" withAlpha:1.0]};
        CGSize amountNameSize = [DLTextAttributeData sizeOfString:SR_LowAbbr withDict:nameAttribute];
        
        CGPoint origin = CGPointMake(priceHighNameLayer.frame.origin.x, (self.frame.size.height/2 - amountNameSize.height)/2);
        priceLowNameLayer = [self addTextLayerWithLayerName:@"priceLowName" string:SR_LowAbbr color:@"#576578" originPoint:origin];
    }
    else
    {
        CGRect frame = priceLowNameLayer.frame;
        frame.origin.x = priceHighNameLayer.frame.origin.x;
        [CATransaction begin];
        [CATransaction setAnimationDuration:0];
        [priceLowNameLayer setFrame:frame];
        [CATransaction commit];
    }//endi
    
    //低
    CGSize priceLowSize = _priceLowLayer.frame.size;
    if (self.priceLow && ( ![self.priceLow isEqualToString:_priceLowLayer.string]))
    {
        priceHighSize = [DLTextAttributeData sizeOfString:self.priceLow withDict:valueAttribute];
        [CATransaction begin];
        [CATransaction setAnimationDuration:0];
        [_priceLowLayer setFrame:CGRectMake(_priceHighLayer.frame.origin.x,
                                            priceLowNameLayer.frame.origin.y,
                                            priceLowSize.width,
                                            priceLowSize.height)];
        [CATransaction commit];
        _priceLowLayer.string = self.priceLow;
        [_priceLowLayer setNeedsDisplay];
    }
    
    //幅Name
    CATextLayer* marginNameLayer = (CATextLayer*)[self getSubLayer:@"marginName"];
    if (!marginNameLayer)
    {
        CGPoint origin = CGPointMake(amountNameLayer.frame.origin.x, priceLowNameLayer.frame.origin.y);
        marginNameLayer = [self addTextLayerWithLayerName:@"marginName" string:SR_RatioAbbr color:@"#576578" originPoint:origin];
    }
    else
    {
        CGRect frame = marginNameLayer.frame;
        frame.origin.x = amountNameLayer.frame.origin.x;
        [CATransaction begin];
        [CATransaction setAnimationDuration:0];
        [marginNameLayer setFrame:frame];
        [CATransaction commit];
    }//endi
    
    //幅
    CATextLayer* marginLayer = (CATextLayer*)[self getSubLayer:@"marginValue"];
    CGSize marginSize = [DLTextAttributeData sizeOfString:self.margin withDict:valueAttribute];
    if (!marginLayer)
    {
        CGFontRef cgFont = CGFontCreateWithFontName((CFStringRef)[UIFont boldSystemFontOfSize:12.0f].fontName);
        NSDictionary *newActions = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"contents", nil];
        marginLayer = [[CATextLayer alloc] init];
        [self.layer addSublayer:marginLayer];
        [CATransaction begin];
        [CATransaction setAnimationDuration:0];
        [marginLayer setFrame:CGRectMake(_amountLayer.frame.origin.x,
                                         marginNameLayer.frame.origin.y,
                                         marginSize.width,
                                         marginSize.height)];
        [CATransaction commit];
        
        marginLayer.foregroundColor = [UIColor whiteColor].CGColor;
        marginLayer.font = cgFont;
        marginLayer.fontSize = 12.0f;
        marginLayer.contentsScale = 2.0f;
        marginLayer.name = @"marginValue";
        marginLayer.actions = newActions;
        marginLayer.string = self.margin;

    }
    else
    {
        if (self.margin && ( ![self.margin isEqualToString:marginLayer.string]))
        {
            [CATransaction begin];
            [CATransaction setAnimationDuration:0];
            [marginLayer setFrame:CGRectMake(_amountLayer.frame.origin.x,
                                                marginNameLayer.frame.origin.y,
                                                marginSize.width,
                                                marginSize.height)];
            [CATransaction commit];
            marginLayer.string = self.margin;
            [marginLayer setNeedsDisplay];
        }
        //else cont.
    }//endi
    
    [CATransaction commit];
}
@end
