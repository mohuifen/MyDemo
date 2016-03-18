//
//  DMDBOperation.m
//  huobiSystem
//
//  Created by FuckYou on 14-10-14.
//  Copyright (c) 2014年 FuckYou. All rights reserved.
//

#import "DLDBOperation.h"
@interface DLDBOperation()
{

}
@property (nonatomic,assign) BOOL blockExecuting;
@property (nonatomic,assign) BOOL blockFinished;

@end

@implementation DLDBOperation

- (BOOL) finished
{
    return self.blockFinished;
}

- (BOOL) executing
{
    return self.blockExecuting;
}

- (id) initWithTarget:(id)target aSelector:(SEL)aSelector argsObject:(id)argsObject
{
    self = [super init];
    __weak DLDBOperation* weakDBOpAS = self;
    
    self.block = ^(){
        weakDBOpAS.blockExecuting = YES;
        if (!weakDBOpAS.cancelled)
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if ([target respondsToSelector:aSelector])
                weakDBOpAS.resultObject = [target performSelector:aSelector withObject:argsObject];
            //else cont.
#pragma clang diagnostic pop
        }
        //else
        
        weakDBOpAS.blockFinished = YES;
    };
    
    return self;
}

- (void) setBlockWithTarget:(id)target aSelector:(SEL)aSelector argsObject:(id)argsObject
{
    __weak DLDBOperation* weakDBOpAS = self;
    self.block = ^(){
        weakDBOpAS.blockExecuting = YES;
        if (!weakDBOpAS.cancelled)
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if ([target respondsToSelector:aSelector])
                weakDBOpAS.resultObject = [target performSelector:aSelector withObject:argsObject];
            //else cont.
#pragma clang diagnostic pop
        }
        //else
        
        weakDBOpAS.blockFinished = YES;
    };
}
@end
