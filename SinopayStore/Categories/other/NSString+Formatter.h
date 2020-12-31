//
//  NSString+Formatter.h
//  XzfPos
//
//  Created by wd on 2017/12/19.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (Formatter)


/**
 银行卡号4位一组，空格分隔

 @return 分隔后的卡号
 */
- (NSString *)numberContainSpace;


/**
 不含空格的银行卡号

 @return 卡号不含空格
 */
- (NSString *)numberWithoutSpace;


/**
 银行卡4位一组，第一组和最后一组明文

 @return 中间数字以星号代替的银行卡号
 */
- (NSString *)numberContainStar;

/**
 检查银行卡号是否满足11-19位数字

 @return 是否有效
 */
- (BOOL)isValidityBankNumber;


/**
 检查是否是6位纯数字密码

 @return 是否有效
 */
- (BOOL)isSixNumberPassword;


/**
 检查是否是2-6位中文名

 @return 是否有效
 */
- (BOOL)isValidityChineseName;


/**
 当字符串长度不够,自动填充到一定位数   后补

 @param MainString 被填充的字符串
 @param AddDigit 补充到的位数
 @param AddString 用来填充的字符
 
 @return 返回所需位数的填充字符串
 */
+ (NSString *)characterStringMainString:(NSString*)MainString AddDigit:(int)AddDigit AddString:(NSString*)AddString;


@end
