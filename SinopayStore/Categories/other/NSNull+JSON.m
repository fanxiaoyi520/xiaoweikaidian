//
//  NSNull+JSON.m
//  XzfPos
//
//  Created by wd on 2017/12/18.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "NSNull+JSON.h"
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"

@interface NSNull () <MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate>

@end

@implementation NSNull (JSON)

- (NSUInteger)length {
    return 0;
}

- (NSInteger)integerValue {
    return 0;
};

- (float)floatValue {
    return 0;
};

- (NSString *)description {
    return @"0(NSNull)";
}

- (NSArray *)componentsSeparatedByString:(NSString *)separator {
    return @[];
}

- (id)objectForKey:(id)key {
    return nil;
}


- (BOOL)boolValue {
    return NO;
}

- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet *)aSet{
    NSRange nullRange = {NSNotFound, 0};
    return nullRange;
}

@end
