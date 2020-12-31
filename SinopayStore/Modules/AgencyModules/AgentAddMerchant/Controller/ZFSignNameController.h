//
//  ZFSignNameController.h
//  Agent
//
//  Created by 中付支付 on 2018/10/24.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

typedef void(^SingNameBlock)(UIImage *image);

@interface ZFSignNameController : ZFBaseViewController

@property (nonatomic, copy)SingNameBlock block;

@end
