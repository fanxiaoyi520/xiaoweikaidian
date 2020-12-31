//
//  KDRedemptionListCell.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/27.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDRedemptionListCell.h"
#import "KDRedemptionUtil.h"

@interface KDRedemptionListCell ()
@property (weak, nonatomic) IBOutlet UILabel *orderNumL;
@property (weak, nonatomic) IBOutlet UILabel *statuL;
@property (weak, nonatomic) IBOutlet UILabel *withDrawAmtL;
@property (weak, nonatomic) IBOutlet UILabel *serviceAmtL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;

@end

@implementation KDRedemptionListCell

- (void)setModel:(KDRedemptionModel *)model{
    _orderNumL.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"提现单号", nil), model.orderNum];
    _statuL.text = [KDRedemptionUtil getTransStateChineseWith:model.transState];
    _withDrawAmtL.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"提现金额", nil), model.withDarwAmt];
    _serviceAmtL.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"服务费", nil), model.serviceCharge];
    _timeL.text = [NSString stringWithFormat:@"%@", model.applyDate];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
