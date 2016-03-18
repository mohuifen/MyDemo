//
//  MD5.m
//  TestEncryption
//
//  Created by LRF on 16/1/22.
//  Copyright © 2016年 LRF. All rights reserved.
//

#import "MD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation MD5

//md5 32位 加密 （小写）
+ (NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[32];
    CC_MD5( cStr, strlen(cStr), result );
     return [NSString stringWithFormat:
    
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            
            
            
            result[0],result[1],result[2],result[3],
            
            result[4],result[5],result[6],result[7],
            
            result[8],result[9],result[10],result[11],
            
            result[12],result[13],result[14],result[15],
            
            result[16], result[17],result[18], result[19],
            
            result[20], result[21],result[22], result[23],
            
            result[24], result[25],result[26], result[27],
            
            result[28], result[29],result[30], result[31]];
    
}


/*
//md5 16位加密 （大写）

-(NSString *)md5:(NSString *)str {
    
    
    
    constchar *cStr = [str UTF8String];
    
    
    
    unsignedchar result[16];
    
    
    
    CC_MD5( cStr, strlen(cStr), result );
    
    
    
    return [NSStringstringWithFormat:
            
            
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            
            
            
            result[0], result[1], result[2], result[3],
            
            
            
            result[4], result[5], result[6], result[7],
            
            
            
            result[8], result[9], result[10], result[11],
            
            
            
            result[12], result[13], result[14], result[15]
            
            
            
            ]; 
    
    
    
}
*/
@end
