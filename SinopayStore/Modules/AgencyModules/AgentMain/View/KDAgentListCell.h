//
//  KDAgentListCell.h
//  SinopayStore
//
//  Created by 中付支付 on 2019/2/14.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDAgentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDAgentListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *accountL;
@property (weak, nonatomic) IBOutlet UILabel *contactL;
@property (weak, nonatomic) IBOutlet UILabel *statusL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;

@property (nonatomic, strong)KDAgentModel *model;

@end

NS_ASSUME_NONNULL_END
