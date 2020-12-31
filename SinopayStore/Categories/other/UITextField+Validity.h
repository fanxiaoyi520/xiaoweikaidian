//
//  UITextField+Validity.h
//  XzfPos
//
//  Created by wd on 2017/11/1.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField(Validity)

/**
 判断输入金额是否符合规则1

 @param range 文本框即将输入字符位置
 @param replacementString 输入的内容
 @return 是否符合规则
 */
- (BOOL)checkMoneyByRuleOneWithRange:(NSRange)range replacementString:(NSString *)replacementString;

- (BOOL)checkMoneyByRuleOneWithRange:(NSRange)range replacementString:(NSString *)replacementString maxMoney:(double)maxCount;

- (BOOL)isSixNumberPassword;

- (BOOL)judgePassWordLegal;

@end
