//
//  KDCollectionDateModel.h
//  SinopayStore
//
//  Created by Jellyfish on 2017/12/7.
//  Copyright © 2017年 中付支付. All rights reserved.
//  head 日期、总笔数

#import <Foundation/Foundation.h>
#import "KDCollectionDeatilsModel.h"

@class KDCollectionDeatilsModel;



@interface KDCollectionDateModel : NSObject

/** 日期 */
@property(nonatomic, copy) NSString *day;
/** 总笔数 */
@property(nonatomic, copy) NSString *dailyTotals;
/** 总金额 */
@property(nonatomic, copy) NSString *dailyAccount;

/** 交易币种 */
@property(nonatomic, copy) NSString *curr;

/**
 是否展开
 */
@property (nonatomic, assign) BOOL isExpanded;

/**
 cell的模型
 */
@property (nonatomic, strong) NSArray<KDCollectionDeatilsModel *> *dailyList;

@end


