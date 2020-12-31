//
//  KDRMCardListCell.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/25.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDRMCardListCell.h"

@interface KDRMCardListCell ()
@property (weak, nonatomic) IBOutlet UILabel *cardNameL;
@property (weak, nonatomic) IBOutlet UILabel *cardNumL;

@end

@implementation KDRMCardListCell

- (void)setModel:(KDRedemptionCardModel *)model{
    _cardNameL.text = model.settleBankName;
    _cardNumL.text = model.cardNo;
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
