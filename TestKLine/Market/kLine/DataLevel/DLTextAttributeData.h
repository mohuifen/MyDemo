//
//  DLTextAttributeData.h
//  huobiSystem
//
//  Created by FuliangYang on 14-8-19.
//  Copyright (c) 2014年 FuliangYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define NOTROUNDING(floatValue,pointCount) [DLTextAttributeData stringNotRounding:(floatValue) afterPoint:(pointCount)]
@interface DLTextAttributeData : NSObject
- (NSDictionary*) getMarketTVCTextAlignmentRight;
- (NSDictionary*) getMarketTVCTextAlignmentLeft;
- (NSDictionary*) getKLineTimeAttributeDict;

+ (CALayer*) getSubLayerOfLayer:(CALayer*)spuerLayer withLayerName:(NSString*)layerName;

+ (CGSize) sizeOfString:(NSString*)stringValue withDict:(NSDictionary*)attrDict;
+ (void) drawString:(NSString*)stringValue atPoint:(CGPoint)point withAttributes:(NSDictionary*)attrDict;

+ (NSString *) stringNotRounding:(double)price afterPoint:(int)position;

+ (NSString*) stringFromPrice:(NSString*)priceNumber;

+ (NSString*) stringFromAmount:(NSString*)priceNumber;

+ (NSString*) stringFromTime:(NSInteger)time withFormat:(NSString*)format;
@end
