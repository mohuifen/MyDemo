//
//  DMDBOperation.h
//  huobiSystem
//
//  Created by FuckYou on 14-10-14.
//  Copyright (c) 2014年 FuckYou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLDBOperation : NSObject
{
}
@property (nonatomic,assign) BOOL cancelled;
@property (readonly,nonatomic,assign) BOOL excuting;
@property (readonly,nonatomic,assign) BOOL finished;
@property (nonatomic,retain) id resultObject;
@property (nonatomic,copy) dispatch_block_t block;
- (id) initWithTarget:(id)target aSelector:(SEL)aSelector argsObject:(id)argsObject;

- (void) setBlockWithTarget:(id)target aSelector:(SEL)aSelector argsObject:(id)argsObject;
@end
