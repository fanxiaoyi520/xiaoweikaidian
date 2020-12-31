//
//  KDSettmentSetController.h
//  SinopayStore
//
//  Created by 中付支付 on 2018/4/28.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

///1 按比例   2 按交易金额
typedef void(^MyBlock)(NSInteger settmentType);

@interface KDSettmentSetController : ZFBaseViewController

@property (nonatomic, copy)MyBlock myBlock;

@end
