//
//  ImHBLog.h
//  huobiSystem
//
//  Created by FuliangYang on 14-6-30.
//  Copyright (c) 2014年 FuliangYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "Notification.h"
//#import "constants.h"
//#import "CONFIG_CONSTAN.h"


#if TARGET_IPHONE_SIMULATOR
#define HB_LOG(...) if(hb_log(__FUNCTION__,__LINE__,__VA_ARGS__)){asm("int3");}
#elif TARGET_OS_IPHONE
#define HB_LOG(...) if(hb_log(__FUNCTION__,__LINE__,__VA_ARGS__)){raise(SIGINT); }
#endif

#define DEBUGLOG_HB(...) huobi_debuglog(__VA_ARGS__)

BOOL hb_log(const char* function, NSUInteger lines, NSString *format, ...) NS_FORMAT_FUNCTION(3,4);

void huobi_debuglog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

#pragma mark - ImHBLog

@interface ModalAlertDelegate : NSObject <UIAlertViewDelegate>
{
    CFRunLoopRef currentLoop;
    NSUInteger index;
}
@property (readonly) NSUInteger index;
@end

@interface ModalAlert : NSObject
+(NSUInteger) queryWith: (NSString *)question;
@end

@interface ImHBLog : NSObject
+ (id) sharedInstance;
@property (nonatomic,assign) BOOL bIgnoreAll;
@end
