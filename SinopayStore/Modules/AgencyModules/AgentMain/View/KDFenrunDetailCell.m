//
//  KDFenrunDetailCell.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/2/15.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDFenrunDetailCell.h"

@interface KDFenrunDetailCell ()

@property (weak, nonatomic) IBOutlet UILabel *agentNameL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (weak, nonatomic) IBOutlet UILabel *agentNumL;
@property (weak, nonatomic) IBOutlet UILabel *transAmountL;
@property (weak, nonatomic) IBOutlet UILabel *fenrunAmountL;
@property (weak, nonatomic) IBOutlet UILabel *rateL;
@property (weak, nonatomic) IBOutlet UILabel *bianhaoTypeL;
@property (weak, nonatomic) IBOutlet UILabel *transTypeL;

@end

@implementation KDFenrunDetailCell

- (void)setModel:(KDBenefitDetailModel *)model{
    _model = model;
    if ([model.xiajiType isEqualToString:@"MERCHANTS"]) {
        _bianhaoTypeL.text = NSLocalizedString(@"商户号：", nil);
    }
    _agentNameL.text = model.xiaJiName;
    _timeL.text = model.fenrunDate;
    _agentNumL.text = model.xiajiAccount;
    _transAmountL.text = [NSString stringWithFormat:@"%.2f", [model.transAmount doubleValue]];
    _fenrunAmountL.text = [NSString stringWithFormat:@"%.2f", [model.fenrunAmount doubleValue]];
    _rateL.text = [NSString stringWithFormat:@"%@%%", model.xiajiRate];
    _transTypeL.text = model.transType;
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
