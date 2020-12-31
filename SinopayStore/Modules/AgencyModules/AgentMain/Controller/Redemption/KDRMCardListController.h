//
//  KDRMCardListController.h
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/25.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDRedemptionCardModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^CardListBlock)(KDRedemptionCardModel *model);

@interface KDRMCardListController : ZFBaseViewController

@property (nonatomic, assign)BOOL isChoose;
@property (nonatomic, copy)CardListBlock block;

@end

NS_ASSUME_NONNULL_END
