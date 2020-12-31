//
//  ZFBankCardModel.h
//  newupop
//
//  Created by Jellyfish on 2017/7/25.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFBankCardModel : NSObject

/** 银行名称 */
@property (nonatomic, copy) NSString *bankName;
/** 卡类型 1借记卡 2信用卡 */
@property (nonatomic, copy) NSString *cardType;
/** 卡号 */
@property (nonatomic, copy) NSString *cardNum;
/** 卡唯一编号 */
@property (nonatomic, copy) NSString *cardId;

@end
