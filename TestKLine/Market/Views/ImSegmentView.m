//
//  ImSegmentVIew.m
//  huobiSystem
//
//  Created by FuliangYang on 14-8-8.
//  Copyright (c) 2014年 FuliangYang. All rights reserved.
//

#import "ImSegmentView.h"
#import "ImHBLog.h"
#import "UIColor+helper.h"

@interface ImSegmentView()
{
    NSUInteger _currentIndex;
    NSUInteger _buttonIndex;
    NSMutableArray* _buttonArray;
}
@property (nonatomic,assign) id trackTarget;
@property (nonatomic,assign) SEL trackSelector;
@property (nonatomic,retain) NSArray* imageArray;
@end

@implementation ImSegmentView

- (id)initSegmentWithFrame:(CGRect)frame
          withButtonCount:(NSInteger)nCount
                   target:(id)theTarget
                 selector:(SEL)theSelector
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _currentIndex = -1;
        _buttonIndex = -1;
        self.controlIndex = NSNotFound;
        // Initialization code
        self.trackTarget = theTarget;
        self.trackSelector = theSelector;
    
        _buttonArray = [[NSMutableArray alloc] initWithCapacity:2];
        CGFloat nBtnWidth = frame.size.width / nCount;
        for (int nIndex = 0; nIndex < nCount; nIndex++)
        {
            CGRect theButtonRect = CGRectMake(nBtnWidth * nIndex, 0, nBtnWidth, frame.size.height);
            UIButton* button = [[UIButton alloc] initWithFrame:theButtonRect];
            [button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = nIndex;
            [self addSubview:button];
            [_buttonArray addObject:button];
        }//endf
    }
    //else cont.
    return self;
}

- (id)initVerticalSegmentView:(CGRect)frame
          withButtonCount:(NSInteger)nCount
                   target:(id)theTarget
                 selector:(SEL)theSelector
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _currentIndex = -1;
        _buttonIndex = -1;
        self.controlIndex = NSNotFound;
        // Initialization code
        self.trackTarget = theTarget;
        self.trackSelector = theSelector;
        
        _buttonArray = [[NSMutableArray alloc] initWithCapacity:2];
        CGFloat nBtnHeight = frame.size.height / nCount;
        for (int nIndex = 0; nIndex < nCount; nIndex++)
        {
            CGRect theButtonRect = CGRectMake(0, nBtnHeight * nIndex, frame.size.width, nBtnHeight);
            UIButton* button = [[UIButton alloc] initWithFrame:theButtonRect];
            [button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = nIndex;
            
            button.titleLabel.textColor = [UIColor redColor];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitle:@"" forState:UIControlStateNormal];

            
            [self addSubview:button];
            [_buttonArray addObject:button];
        }//endf
    }
    //else cont.
    return self;
}


- (void) setBackgroundImage:(NSArray*)imageArray forState:(UIControlState)state
{
    if (imageArray)
        self.imageArray = imageArray;
    //else cont
    
    for (int nIndex = 0; nIndex < [_buttonArray count]; nIndex++)
    {
        UIButton* button = [_buttonArray objectAtIndex:nIndex];
        if (imageArray && [imageArray count] > (nIndex * 2))
        {
            UIImage* theImageNormal = [imageArray objectAtIndex:nIndex * 2];
            if ([theImageNormal isKindOfClass:[UIImage class]])
            {
                [button setBackgroundImage:theImageNormal forState:UIControlStateNormal];
            }
            else
                HB_LOG(@"error!");
        }
        //else cont.
        
    }//endf
}

- (void) setText:(NSArray*)textArray forState:(UIControlState)state
{
    for (int nIndex = 0; nIndex < [_buttonArray count]; nIndex++)
    {
        UIButton* button = [_buttonArray objectAtIndex:nIndex];
        if ( textArray && [textArray count] > nIndex )
        {
            button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            NSString* strTitle = [textArray objectAtIndex:nIndex];
            if ([strTitle isKindOfClass:[NSString class]])
            {
                [button setTitle:strTitle forState:UIControlStateNormal];
                button.titleLabel.textColor = [UIColor redColor];
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
            else
                HB_LOG(@"error!");
        }
        //else 没有文字
    }//endf
}

- (void) setTextColor:(NSInteger)nIndex
{
    [[_buttonArray objectAtIndex:nIndex] setTitleColor:[UIColor colorWithHexString:@"0x1dc7e6" withAlpha:1.0f] forState:UIControlStateNormal];
}

#pragma mark - action

- (void) onButtonClicked:(id)sender
{
    UIButton* currentButton = (UIButton*)sender;
    if (_currentIndex != currentButton.tag)
    {
        [self setDataItemIndex:currentButton.tag];
        
        if ([self.trackTarget respondsToSelector:self.trackSelector])
        {
            /****************************************************************
             warning:performSelector may cause a leak because its selector
             ****************************************************************/
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.trackTarget performSelector:self.trackSelector withObject: sender];//此处是你调用函数的地方
#pragma clang diagnostic pop
        }
        //else cont.
    }
    //else cont.
}

- (NSUInteger) getButtonIndex
{
    return _buttonIndex;
}

- (NSUInteger) getDataItemIndex
{
    return _currentIndex;
}

- (void) setDataItemIndex:(NSUInteger)nIndex
{
    _buttonIndex = nIndex;
    
    if (nIndex == self.controlIndex)
    {
        //_currentIndex no change
    }
    else
    {
        _currentIndex = nIndex;
        for (UIButton* aButton in _buttonArray)
        {
            if (self.controlIndex == aButton.tag )
            {
                NSUInteger imageIndex = aButton.tag * 2;
                if (imageIndex < [self.imageArray count])
                {
                    UIImage* theNormalImage = [self.imageArray objectAtIndex:imageIndex];
                    [aButton setBackgroundImage:theNormalImage forState:UIControlStateNormal];
                    
                    if (self.normalControlColor)
                    {
                        [aButton setTitleColor:self.normalControlColor forState:UIControlStateNormal];
                    }
                    //else cont.
                }
                
                aButton.userInteractionEnabled = YES;
            }
            else if (_currentIndex == aButton.tag )
            {
                NSUInteger imageIndex = aButton.tag * 2 + 1;
                if (imageIndex < [self.imageArray count])
                {
                    UIImage* theSelectedImage = [self.imageArray objectAtIndex:imageIndex];
                    [aButton setBackgroundImage:theSelectedImage forState:UIControlStateNormal];
                }
                else
                    HB_LOG(@"error!");
                
                if (self.selectedTextColor)
                    [aButton setTitleColor:self.selectedTextColor forState:UIControlStateNormal];
                //else cont.
                
                aButton.userInteractionEnabled = NO;
            }
            else
            {
                NSUInteger imageIndex = aButton.tag * 2;
                if (imageIndex < [self.imageArray count])
                {
                    UIImage* theNormalImage = [self.imageArray objectAtIndex:imageIndex];
                    [aButton setBackgroundImage:theNormalImage forState:UIControlStateNormal];
                    
                    if (self.normalTextColor)
                    {
                        [aButton setTitleColor:self.normalTextColor forState:UIControlStateNormal];
                    }
                    //else cont.
                    
                    aButton.userInteractionEnabled = YES;
                }
                else
                    HB_LOG(@"error!");
            }//endi
        }//endf
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
