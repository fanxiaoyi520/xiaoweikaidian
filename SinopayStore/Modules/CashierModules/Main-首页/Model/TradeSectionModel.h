//
//  TradeSectionModel.h
//  newupop
//
//  Created by Jellyfish on 2017/12/27.
//  Copyright © 2017年 中付支付. All rights reserved.
//  奖励记录头部模型

#import <Foundation/Foundation.h>
#import "KDAwardRecord.h"

@interface TradeSectionModel : NSObject

/** 当前月份 */
@property(nonatomic, copy) NSString *month;
/** 月奖励金额 */
@property(nonatomic, copy) NSString *bousAct;
/** 月提现金额 */
@property(nonatomic, copy) NSString *drawAct;
/** monthList */
@property (nonatomic, strong) NSMutableArray<KDAwardRecord *> *monthList;

@end
