//
//  KDMerchantListCell.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/4.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDMerchantListCell.h"

@interface KDMerchantListCell ()
@property (weak, nonatomic) IBOutlet UILabel *merCodeL;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumL;
@property (weak, nonatomic) IBOutlet UILabel *merNameL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;

@end

@implementation KDMerchantListCell

- (void)setModel:(KDAgentMerModel *)model{
    _merCodeL.text = model.merCode;
    _phoneNumL.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"手机号：", nil), model.telephone];
    _merNameL.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"商户名：", nil), model.merName];
    _timeL.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"入网时间：", nil), model.signDate];
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
