//
//  KDSearchBBNViewController.h
//  SinopayStore
//
//  Created by Jellyfish on 2017/12/11.
//  Copyright © 2017年 中付支付. All rights reserved.
//


#import "ZFBaseViewController.h"
#import "KDBranchBankModel.h"

typedef void(^myBlock)(KDBranchBankModel *model);

@interface KDSearchBBNViewController : ZFBaseViewController

///银行代码
@property (nonatomic, strong)NSString *bankCode;
@property (nonatomic, copy)myBlock block;

@end
