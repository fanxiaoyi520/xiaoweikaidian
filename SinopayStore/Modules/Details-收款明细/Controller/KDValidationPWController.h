//
//  KDValidationPWController.h
//  SinopayStore
//
//  Created by 中付支付 on 2017/12/11.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

@interface KDValidationPWController : ZFBaseViewController

///订单id
@property (nonatomic, strong)NSString *orderID;
///商户号
@property (nonatomic, strong)NSString *merCode;
///终端号
//@property (nonatomic, strong)NSString *termCode;
@property (nonatomic ,strong)NSString *payType;
@end
