//
//  NSString+MD5.m
//  XzfPos
//
//  Created by wd on 2017/10/26.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "NSString+MD5.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString(MD5)

- (NSString *)MD5String
{
    NSMutableString *hash = nil;
    
    int stringlen = (int)[self length];
    
    if (self == nil || stringlen == 0) {
        return hash;
    }
    
    const char *cStr = [self UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    hash = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02x", digest[i]];
    
    return  hash;
}

@end
