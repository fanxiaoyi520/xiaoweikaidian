//
//  KDBankNameModel.h
//  SinopayStore
//
//  Created by 中付支付 on 2017/12/11.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDBankNameModel : NSObject

///银行编号
@property (nonatomic, strong)NSString *bankCode;
///城市编号
@property (nonatomic, strong)NSString *countryCode;
///银行名称
@property (nonatomic, strong)NSString *bankName;

@end
