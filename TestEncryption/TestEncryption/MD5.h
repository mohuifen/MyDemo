//
//  MD5.h
//  TestEncryption
//
//  Created by LRF on 16/1/22.
//  Copyright © 2016年 LRF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MD5 : NSObject
+ (NSString *)md5WithStr:(NSString *)str;
+ (NSString *)md5:(NSString *)str;
@end
