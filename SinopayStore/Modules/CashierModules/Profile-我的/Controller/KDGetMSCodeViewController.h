//
//  KDGetMSCodeViewController.h
//  SinopayStore
//
//  Created by Jellyfish on 2018/3/5.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

@interface KDGetMSCodeViewController : ZFBaseViewController

- (instancetype)initWithParams:(NSDictionary *)params;


@property (nonatomic, copy)NSString *orderId;

@property (nonatomic, copy)NSString *cardNum;

@end
