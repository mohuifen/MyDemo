//
//  ImSegmentVIew.h
//  huobiSystem
//
//  Created by FuliangYang on 14-8-8.
//  Copyright (c) 2014年 FuliangYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImSegmentView : UIView

//TODO:临时措施，想出一个更好的可以设置该属性的逻辑
@property (nonatomic,retain) UIColor* selectedTextColor;

@property (nonatomic,retain) UIColor* normalTextColor;

//TODO:临时措施，想出一个更好的可以设置该属性的逻辑
@property (nonatomic,assign) BOOL bEndolor;

//TODO:临时措施，想出一个更好的可以设置该属性的逻辑
@property (nonatomic,assign) NSInteger controlIndex;

@property (nonatomic,retain) UIColor* selectedControlColor;

@property (nonatomic,retain) UIColor* normalControlColor;

- (id)initSegmentWithFrame:(CGRect)frame
          withButtonCount:(NSInteger)nCount
                   target:(id)theTarget
                 selector:(SEL)theSelector;

- (id)initVerticalSegmentView:(CGRect)frame
              withButtonCount:(NSInteger)nCount
                       target:(id)theTarget
                     selector:(SEL)theSelector;

- (void) setBackgroundImage:(NSArray*)imageArray forState:(UIControlState)state;

- (void) setText:(NSArray*)textArray forState:(UIControlState)state;

- (NSUInteger) getDataItemIndex;
- (void) setDataItemIndex:(NSUInteger)nIndex;

- (NSUInteger) getButtonIndex;
- (void) setTextColor:(NSInteger)nIndex;
@end
