//
//  DLTextAttributeData.m
//  huobiSystem
//
//  Created by FuliangYang on 14-8-19.
//  Copyright (c) 2014年 FuliangYang. All rights reserved.
//

#import "DLTextAttributeData.h"
#import "UIColor+helper.h"
#import "ImHBLog.h"
@interface DLTextAttributeData()
{
    
}
@property (nonatomic, retain)NSDictionary* marketTVCTextAlignmentRight;
@property (nonatomic, retain)NSDictionary* marketTVCTextAlignmentLeft;
@property (nonatomic, retain)NSDictionary* kLineTimeAttributeDict;
@end

@implementation DLTextAttributeData

- (NSDictionary*) getMarketTVCTextAlignmentRight
{
    if (!self.marketTVCTextAlignmentRight)
    {
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSTextAlignmentRight];

        self.marketTVCTextAlignmentRight = @{NSFontAttributeName:[UIFont systemFontOfSize:16.0f],
                                                      NSForegroundColorAttributeName:[UIColor whiteColor],
                                                      NSParagraphStyleAttributeName:style};
    }
    //else cont.
    
    return self.marketTVCTextAlignmentRight;
}

- (NSDictionary*) getMarketTVCTextAlignmentLeft
{
    if (!self.marketTVCTextAlignmentLeft)
    {
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSTextAlignmentLeft];
        
        self.marketTVCTextAlignmentLeft = @{NSFontAttributeName:[UIFont systemFontOfSize:16.0f],
                                                      NSForegroundColorAttributeName:[UIColor whiteColor],
                                                      NSParagraphStyleAttributeName:style};
    }
    //else cont.
    
    return self.marketTVCTextAlignmentLeft;
}

- (NSDictionary*) getKLineTimeAttributeDict
{
    if (!self.kLineTimeAttributeDict)
    {
        self.kLineTimeAttributeDict = @{NSFontAttributeName:
                                            [UIFont systemFontOfSize:8.0f],
                                        NSForegroundColorAttributeName:
                                            [UIColor colorWithHexString:@"0x535d6a" withAlpha:1.0]};
    }
    //else cont.
    
    return self.kLineTimeAttributeDict;
}

+ (CALayer*) getSubLayerOfLayer:(CALayer*)spuerLayer withLayerName:(NSString*)layerName
{
    NSArray* subLayers = [spuerLayer sublayers];
    CALayer* tempItem = nil;
    for (CALayer* item in subLayers)
    {
        if ([item.name isEqualToString:layerName])
        {
            tempItem = item;
            break;
        }
        //else cont.
    }//endf
    
    return tempItem;
}

+ (CGSize) sizeOfString:(NSString*)stringValue withDict:(NSDictionary*)attrDict
{
    CGSize sizeResult = CGSizeZero;
    if (stringValue && attrDict)
    {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
            sizeResult = [stringValue length] > 0 ? [stringValue sizeWithAttributes:attrDict] : CGSizeZero;
        else
        {
            UIFont* font = [attrDict objectForKey:NSFontAttributeName];
            if (font)
            {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
                sizeResult = [stringValue length] > 0 ? [stringValue sizeWithFont:font] : CGSizeZero;
#endif
            }
            //else cont.
        }//endi
    }
    else
        HB_LOG(@"error!");
    
    return sizeResult;
}

+ (void) drawString:(NSString*)stringValue atPoint:(CGPoint)point withAttributes:(NSDictionary*)attrDict
{
    if (stringValue && attrDict)
    {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
            [stringValue drawAtPoint:point withAttributes:attrDict];
        else
        {
            UIColor* foreColor = [attrDict objectForKey:NSForegroundColorAttributeName];
            
            if (foreColor)
                [foreColor set];
            //else cont.
            
            UIFont* font = [attrDict objectForKey:NSFontAttributeName];
            if (font)
            {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
                [stringValue drawAtPoint:point withFont:font];
#endif
            }
            //else cont.
        }//endi
    }
    //else cont.
}

+ (NSString *) stringNotRounding:(double)price afterPoint:(int)position
{
#if 0
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return [NSString stringWithFormat:@"%.2@",roundedOunces];
#else
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMinimumIntegerDigits:1];
    [formatter setMinimumFractionDigits:position];
    [formatter setRoundingMode:NSNumberFormatterRoundDown];  // up / down / half down
    return [formatter stringFromNumber:@(price)];
    
#endif
}

+ (NSString*) stringFromPrice:(NSString*)priceNumber
{
    NSString *strResult = @"0.00";
    if ([priceNumber isKindOfClass:[NSString class]] && ![priceNumber isEqualToString:@""])
    {
        strResult = [priceNumber copy];
        NSRange range = [strResult rangeOfString:@"."];
        if (range.location == NSNotFound)
        {
            strResult = [NSString stringWithFormat:@"%@.00", strResult];
        }
        else
        {
            NSString *below = [strResult substringFromIndex:range.location + 1];
            if ([below length] == 1) {
                strResult = [NSString stringWithFormat:@"%@0", strResult];
            }
            
            else if ([below length] > 2)
            {
                strResult = [strResult substringToIndex:range.location + 1 + 2];
            }
            //else cont.
            
        }//endi
    }
    else
        HB_LOG(@"error!");

    
    return strResult;
}

+ (NSString*) stringFromAmount:(NSString*)priceNumber
{
    NSString *strResult = [priceNumber copy];
    if ([strResult isKindOfClass:[NSString class]] && ![strResult isEqualToString:@""])
    {
        NSRange range = [strResult rangeOfString:@"."];
        if (range.location == NSNotFound)
        {
            strResult = [NSString stringWithFormat:@"%@.0000", strResult];
        }
        else
        {
            NSString *below = [strResult substringFromIndex:range.location + 1];
            if ([below length] == 1) {
                strResult = [NSString stringWithFormat:@"%@000", strResult];
            }
            else if ([below length] == 2)
            {
                strResult = [NSString stringWithFormat:@"%@00", strResult];
            }
            else if ([below length] == 3)
            {
                strResult = [NSString stringWithFormat:@"%@0", strResult];
            }
            
            if ([below length] > 4)
            {
                strResult = [strResult substringToIndex:range.location + 1 + 4];
            }
        }//endi
        
    }
    else
        HB_LOG(@"error!");
    
    
    return strResult;
}

+ (NSString*) stringFromTime:(NSInteger)time withFormat:(NSString*)format
{
    NSDateFormatter* timeDateFormatter = [[NSDateFormatter alloc] init];
    timeDateFormatter.dateFormat = format;
    
    NSDate* timeDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *timeString = [timeDateFormatter stringFromDate:timeDate];
    
    return timeString;
}
@end
