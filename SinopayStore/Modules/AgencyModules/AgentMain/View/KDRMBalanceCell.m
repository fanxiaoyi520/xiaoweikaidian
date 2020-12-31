//
//  KDRMBalanceCell.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/25.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDRMBalanceCell.h"
#import "KDRedemptionUtil.h"

@interface KDRMBalanceCell ()
@property (weak, nonatomic) IBOutlet UILabel *stateL;
@property (weak, nonatomic) IBOutlet UILabel *amountL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (weak, nonatomic) IBOutlet UILabel *balanceAmtL;

@end

@implementation KDRMBalanceCell

- (void)setModel:(KDRMBalanceModel *)model{
//    afterAccountAmt = "2828.41";
//    applyDate = 1553570449000;
//    operateType = WITHDARW;
//    orderNum = 20190326112000004777;
//    serviceCharge = "0.11";
//    transState = "WTIHDARW_WAIT_AUDTI";
//    withDarwAmt = "110.25";
    
    NSString *operateType = [KDRedemptionUtil getOperateTypeChineseWith:model.operateType];
    NSString *transState = [KDRedemptionUtil getTransStateChineseWith:model.transState];
    _stateL.text = [NSString stringWithFormat:@"%@-%@", operateType, transState];
    NSString *str = @"+";
    if ([model.operateType isEqualToString:@"WITHDARW"]) {
        str = @"-";
    }
    if ([model.transState isEqualToString:@"WTIHDARW_AUDTI_FAILED"]) {
        str = @"+";
    }
    _amountL.text = [NSString stringWithFormat:@"%@%@", str, model.withDarwAmt];
    _timeL.text = [NSString stringWithFormat:@"%@", model.applyDate];
    _balanceAmtL.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"结余", nil), model.afterAccountAmt];
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
