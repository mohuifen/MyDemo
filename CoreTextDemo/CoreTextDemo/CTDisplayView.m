//
//  CTDisplayView.m
//  CoreTextDemo
//
//  Created by LRF on 15/11/11.
//  Copyright © 2015年 LRF. All rights reserved.
//

#import "CTDisplayView.h"
#import "CoreText/CoreText.h"
@implementation CTDisplayView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    //获取上下文环境
    CGContextRef content =UIGraphicsGetCurrentContext();
    
    //将坐标系翻转
    CGContextSetTextMatrix(content, CGAffineTransformIdentity);
    CGContextTranslateCTM(content, 0, self.bounds.size.height);
    CGContextScaleCTM(content, 1.0, -1.0);
    
    
    // 创建绘制的区域
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:@"Hello World"];
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attString.length), path, NULL);
    
    CTFrameDraw(frame, content);

    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(frameSetter);
    
}
@end
