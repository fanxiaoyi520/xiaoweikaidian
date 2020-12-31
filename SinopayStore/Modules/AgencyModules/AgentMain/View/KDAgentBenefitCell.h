//
//  KDAgentBenefitCell.h
//  SinopayStore
//
//  Created by 中付支付 on 2019/2/14.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDBenefitModel.h"

@protocol KDBenefitCellDelegate <NSObject>

- (void)benefitClickType:(NSString *)type dict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_BEGIN

@interface KDAgentBenefitCell : UITableViewCell

@property (nonatomic, strong)KDBenefitModel *model;

@property (nonatomic, assign)id <KDBenefitCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
