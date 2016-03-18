//
//  ImHBLog.m
//  huobiSystem
//
//  Created by FuliangYang on 14-6-30.
//  Copyright (c) 2014年 FuliangYang. All rights reserved.
//

#import "ImHBLog.h"

#pragma mark - functions

void debugAction()
{
#if TARGET_IPHONE_SIMULATOR
    asm("int3");
#elif TARGET_OS_IPHONE
    raise(SIGINT);
    /*
     [NSException raise:@"" format:@"error!"]; 毛反应都没有
     __builtin_trap();          没反应
     raise(SIGTRAP);            貌似可以，但是会出现一段可疑的过程。
     raise(SIGINT);             正确
     asm volatile("bkpt 1");    毛反应都没有
     
     asm("trap");               直接将程序终止了。
     __asm__("trap");
     asm("swi 3");              直接将程序终止了。
     kill( getpid(), SIGINT ) ; //ok
     */
    
#endif
}


BOOL hb_log(const char* function,NSUInteger lines,NSString *format, ...)
{
    BOOL bResult = NO;
#ifdef DEBUG
    if ([[ImHBLog sharedInstance] bIgnoreAll])
        ;
    else
    {
#if 0
        va_list args;
        va_start(args, format);
        NSString* strLog = [NSString stringWithFormat:format,args];
        va_end(args);
        NSString* strInfo = [NSString stringWithFormat:@"%s_%lu:%@",function,(unsigned long)lines,strLog];
        switch ([ModalAlert queryWith:strInfo]) {
            case 0:
                break;
            case 1:
            {
                bResult = YES;
                break;
            }
            case 2:
            {
                [[ImHBLog sharedInstance] setBIgnoreAll:YES];
                break;
            }
            default:
                debugAction();
                break;
        }//ends
#endif
        
    }
#else
    ;
#endif
    
    return bResult;
}


void huobi_debuglog(NSString *format, ...)
{

}

/****************************************************
 ImHBLog：log对外的总接口
 ****************************************************/
#pragma mark - ImHBLog
@implementation ImHBLog
+ (ImHBLog*) sharedInstance
{
    static ImHBLog *sharedLogInstance = nil;
    
    static dispatch_once_t predicate; dispatch_once(&predicate, ^{
        sharedLogInstance = [[self alloc] init];
    });
    
    return sharedLogInstance;
}
@end

/****************************************************
 模态alert的delegate
 ****************************************************/
@implementation ModalAlertDelegate
@synthesize index;
// Initialize with the supplied run loop
-(id) initWithRunLoop: (CFRunLoopRef)runLoop
{
    if (self = [super init]) currentLoop = runLoop;
    return self;
}
// User pressed button. Retrieve results
-(void) alertView: (UIAlertView*)aView clickedButtonAtIndex: (NSInteger)anIndex
{
    index = anIndex;
    CFRunLoopStop(currentLoop);
}
@end

/****************************************************
 模态alert
 ****************************************************/
@implementation ModalAlert

+(NSUInteger) queryWith: (NSString *)question
{
    BOOL bViewLoaded = [UIApplication sharedApplication].keyWindow.rootViewController.isViewLoaded;
    NSUInteger answer = 0;
    // Wait for response
    if(bViewLoaded)
    {
        CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
        // Create Alert
        ModalAlertDelegate *madelegate = [[ModalAlertDelegate alloc]
                                          initWithRunLoop:currentLoop];
        
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告"
                                                            message:question
                                                           delegate:madelegate
                                                  cancelButtonTitle:@"Ignore All"
                                                  otherButtonTitles:@"Debug", @"Ignore",nil];
        [alertView show];
        
        CFRunLoopRun();
        
        // Retrieve answer
        answer = madelegate.index;
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告"
                                                            message:question
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
    }

    return answer;
}
@end
