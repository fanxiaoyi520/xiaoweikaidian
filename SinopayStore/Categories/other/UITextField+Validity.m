//
//  UITextField+Validity.m
//  XzfPos
//
//  Created by wd on 2017/11/1.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "UITextField+Validity.h"
#import "NSString+Formatter.h"

@implementation UITextField(Validity)

- (BOOL)checkMoneyByRuleOneWithRange:(NSRange)range replacementString:(NSString *)replacementString {
   return [self checkMoneyByRuleOneWithRange:range replacementString:replacementString maxMoney:1000.00];
}

- (BOOL)checkMoneyByRuleOneWithRange:(NSRange)range replacementString:(NSString *)replacementString maxMoney:(double)maxCount {
        /*
     * 不能输入.0-9以外的字符。
     * 设置输入框输入的内容格式
     * 只能有一个小数点
     * 小数点后最多能输入两位
     * 如果第一位是.则前面加上0.
     * 如果第一位是0则后面必须输入点，否则不能输入。
     */
    NSString *str = [NSString stringWithFormat:@"%@%@", self.text, replacementString];
    if ([str doubleValue] > maxCount) {
        NSString *message = [NSString stringWithFormat:@"消费金额不能超出%f元", maxCount];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                       message:message
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:@"确定", nil];
        [alert show];
        
        return NO;
    }
    
    // 判断是否有小数点
    BOOL isHaveDot = NO;
    if ([self.text containsString:@"."]) {
        isHaveDot = YES;
    }
    
    if (replacementString.length > 0) {
        //当前输入的字符
        unichar single = [replacementString characterAtIndex:0];
//        LogD(@"single = %c",single);
        
        // 不能输入.0-9以外的字符
        if (!((single >= '0' && single <= '9') || single == '.'))
        {
//            [SVProgressHUD showErrorWithStatus:@"您的输入格式不正确" dismissDelay:1.5];
            return NO;
        }
        
        // 只能有一个小数点
        if (isHaveDot && single == '.') {
//            [SVProgressHUD showErrorWithStatus:@"最多只能输入一个小数点" dismissDelay:1.5];
            return NO;
        }
        
        // 如果第一位是.则前面加上0.
        if ((self.text.length == 0) && (single == '.')) {
            self.text = @"0";
        }
        
        // 如果第一位是0则后面必须输入点，否则不能输入。
        if ([self.text hasPrefix:@"0"]) {
            if (self.text.length > 1) {
                NSString *secondStr = [self.text substringWithRange:NSMakeRange(1, 1)];
                if (![secondStr isEqualToString:@"."]) {
//                    [SVProgressHUD showErrorWithStatus:@"第二个字符需要是小数点" dismissDelay:1.5];
                    return NO;
                }
            }else{
                if (![replacementString isEqualToString:@"."]) {
//                    [SVProgressHUD showErrorWithStatus:@"第二个字符需要是小数点" dismissDelay:1.5];
                    return NO;
                }
            }
        }
        // 小数点后最多能输入两位
        if (isHaveDot) {
            NSRange ran = [self.text rangeOfString:@"."];
            // 由于range.location是NSUInteger类型的，所以这里不能通过(range.location - ran.location)>2来判断
            if (range.location > ran.location) {
                if ([self.text pathExtension].length > 1) {
//                    [SVProgressHUD showErrorWithStatus:@"小数点后最多有两位小数" dismissDelay:1.5];
                    return NO;
                }
            }
        }
    }
    return YES;
}

- (BOOL)isSixNumberPassword {
    if ([self.text length] != 6) {
//        [SVProgressHUD showErrorWithStatus:@"请输入6位密码" dismissDelay:1.5];
        return NO;
    }
    NSString *regular = @"^\\d{6}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular];
    BOOL isMatch = [pred evaluateWithObject:self.text];
    if (!isMatch) {
//        [SVProgressHUD showInfoWithStatus:@"请设置6位数字密码" dismissDelay:1.5];
        return NO;
    }
    regular = @"(?:(?:0(?=1)|1(?=2)|2(?=3)|3(?=4)|4(?=5)|5(?=6)|6(?=7)|7(?=8)|8(?=9)){5}|(?:9(?=8)|8(?=7)|7(?=6)|6(?=5)|5(?=4)|4(?=3)|3(?=2)|2(?=1)|1(?=0)){5})\\d";
    pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular];
    isMatch = [pred evaluateWithObject:self.text];
    if (isMatch) {
//        [SVProgressHUD showErrorWithStatus:@"密码过于简单，请重新输入" dismissDelay:1.5];
        return NO;
    }
    regular = @"([\\d])\\1{5,}";
    pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular];
    isMatch = [pred evaluateWithObject:self.text];
    if (isMatch) {
//        [SVProgressHUD showErrorWithStatus:@"请不要使用6位重复数字密码" dismissDelay:1.5];
        return NO;
    }
    
    return YES;
}

- (BOOL)judgePassWordLegal{
    BOOL result = false;
    if ([self.text length] >= 6){
//        NSString * regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,20}$";//不区分大小写
        NSString * regex = @"(?![0-9A-Z]+$)(?![0-9a-z]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,20}$";//区分大小写
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        result = [pred evaluateWithObject:self.text];
    }
    return result;
}

@end
