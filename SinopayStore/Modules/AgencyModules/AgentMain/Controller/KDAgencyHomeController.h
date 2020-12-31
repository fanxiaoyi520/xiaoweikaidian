//
//  KDAgencyHomeController.h
//  SinopayStore
//
//  Created by 中付支付 on 2018/7/31.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

typedef void(^MyBlock)(BOOL isClean);

@interface KDAgencyHomeController : ZFBaseViewController

@property (nonatomic, strong)NSString *areaNum;
@property (nonatomic, strong)NSString *agencyNum;
@property (nonatomic, strong)NSString *password;

@property (nonatomic, copy)MyBlock block;

@end
