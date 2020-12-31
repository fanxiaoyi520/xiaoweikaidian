//
//  NSString+Formatter.m
//  XzfPos
//
//  Created by wd on 2017/12/19.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "NSString+Formatter.h"

@implementation NSString (Formatter)

- (NSString *)numberContainSpace {
    NSString *baseString = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([baseString length] > 4) {
        NSMutableString *resultString = [NSMutableString string];
        for (NSInteger index = 0; index < [baseString length]; index += 4) {
            NSInteger length = MIN([baseString length] - index, 4);
            if (index > 0) {
                [resultString appendString:@" "];
            }
            [resultString appendString:[baseString substringWithRange:NSMakeRange(index, length)]];
        }
        return resultString;
    }
    return baseString;
}

- (NSString *)numberWithoutSpace {
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (NSString *)numberContainStar {
    NSString *spaceString = [self numberContainSpace];
    NSArray *numberArray = [spaceString componentsSeparatedByString:@" "];
    NSMutableString *starString = [NSMutableString string];
    if ([numberArray count] > 1) {
        for (NSInteger i = 0; i < [numberArray count]; i++) {
            if (i == 0) {
                [starString appendString:numberArray[i]];
            }
            else if (i == [numberArray count] - 1) {
                [starString appendString:@" "];
                [starString appendString:numberArray[i]];
            }
            else {
                [starString appendString:@" ****"];
            }
        }
    }
    else {
        return spaceString;
    }
    return starString;
}

- (BOOL)isValidityBankNumber {
    NSString *number = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([number length] < 11 || [number length] > 19) {
//        [SVProgressHUD showErrorWithStatus:@"请提供正确的银行卡号" dismissDelay:1.5];
        return NO;
    }
    NSString *regular = @"^[0-9]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular];
    BOOL isMatch = [pred evaluateWithObject:number];
    if (!isMatch) {
//        [SVProgressHUD showInfoWithStatus:@"请提供正确的银行卡号" dismissDelay:1.5];
        return NO;
    }

    return YES;
}

- (BOOL)isSixNumberPassword {
    if ([self length] != 6) {
//        [SVProgressHUD showErrorWithStatus:@"请输入6位密码" dismissDelay:1.5];
        return NO;
    }
    NSString *regular = @"^\\d{6}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular];
    BOOL isMatch = [pred evaluateWithObject:self];
    if (!isMatch) {
//        [SVProgressHUD showInfoWithStatus:@"请设置6位数字密码" dismissDelay:1.5];
        return NO;
    }
    regular = @"(?:(?:0(?=1)|1(?=2)|2(?=3)|3(?=4)|4(?=5)|5(?=6)|6(?=7)|7(?=8)|8(?=9)){5}|(?:9(?=8)|8(?=7)|7(?=6)|6(?=5)|5(?=4)|4(?=3)|3(?=2)|2(?=1)|1(?=0)){5})\\d";
    pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular];
    isMatch = [pred evaluateWithObject:self];
    if (isMatch) {
//        [SVProgressHUD showErrorWithStatus:@"密码过于简单，请重新输入" dismissDelay:1.5];
        return NO;
    }
    regular = @"([\\d])\\1{5,}";
    pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular];
    isMatch = [pred evaluateWithObject:self];
    if (isMatch) {
//        [SVProgressHUD showErrorWithStatus:@"请不要使用6位重复数字密码" dismissDelay:1.5];
        return NO;
    }
    
    return YES;
}

- (BOOL)isValidityChineseName {
    NSString *regular = @"[\u4E00-\u9FA5]{2,6}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular];
    return [pred evaluateWithObject:self];
}

+ (NSString *)characterStringMainString:(NSString*)MainString AddDigit:(int)AddDigit AddString:(NSString*)AddString
{
    NSString *ret = [[NSString alloc]init];
    ret = MainString;
    for(int y = 0; y < (AddDigit - MainString.length); y++){
        ret = [NSString stringWithFormat:@"%@%@",ret,AddString];
    }
    return ret;
    
}

@end
