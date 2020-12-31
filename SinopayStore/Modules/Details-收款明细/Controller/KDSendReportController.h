//
//  KDSendReportController.h
//  SinopayStore
//
//  Created by 中付支付 on 2018/5/15.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

@interface KDSendReportController : ZFBaseViewController

///商户号+时间
@property (nonatomic, strong)NSString *merIdAndTime;
///时间
@property (nonatomic, strong)NSString *nowTime;
///图片
@property (nonatomic, strong)UIImage *webImage;

@end
