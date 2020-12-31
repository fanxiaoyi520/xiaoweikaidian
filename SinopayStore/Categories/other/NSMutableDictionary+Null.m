//
//  NSMutableDictionary+Null.m
//  XzfPos
//
//  Created by wd on 2018/1/3.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "NSMutableDictionary+Null.h"

@implementation NSMutableDictionary (Null)

- (void)zf_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (anObject == nil) {
        anObject = @"";
    }
    if (aKey == nil) {
        aKey = @"";
    }
    [self setObject:anObject forKey:aKey];
}

@end
