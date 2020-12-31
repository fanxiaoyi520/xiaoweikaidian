//
//  KDStoreTypeModel.h
//  SinopayStore
//
//  Created by 中付支付 on 2018/6/7.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDStoreTypeModel : NSObject

///mcc
@property (nonatomic, strong)NSString *mcc;
///中文
@property (nonatomic, strong)NSString *merTypeInChinese;
///繁体
@property (nonatomic, strong)NSString *merTypeInFon;
///简体
@property (nonatomic, strong)NSString *merTypeInEnglish;
///当前显示
@property (nonatomic, strong)NSString *merTypeCurrent;

@end
