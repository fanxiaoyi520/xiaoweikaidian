//
//  KDCountryModel.h
//  SinopayStore
//
//  Created by 中付支付 on 2017/12/11.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDCountryModel : NSObject

///城市区号
@property (nonatomic, strong)NSString *countryCode;
///城市编码
@property (nonatomic, strong)NSString *countryLog;
///城市名
@property (nonatomic, strong)NSString *countryDesc;

@end
