//
//  KDScanResultViewController.h
//  SinopayStore
//
//  Created by Jellyfish on 2018/1/3.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "KDScanResult.h"


@interface KDScanResultViewController : ZFBaseViewController

/** 扫一扫结果模型 */
@property(nonatomic, strong) KDScanResult *scanResult;

@end
