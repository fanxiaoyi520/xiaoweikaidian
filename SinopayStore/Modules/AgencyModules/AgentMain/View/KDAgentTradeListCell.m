//
//  KDAgentTradeListCell.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/4.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDAgentTradeListCell.h"

@interface KDAgentTradeListCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *merCodeL;
@property (weak, nonatomic) IBOutlet UILabel *orderNumL;
@property (weak, nonatomic) IBOutlet UILabel *tradeTypeL;
@property (weak, nonatomic) IBOutlet UILabel *cardNoL;
@property (weak, nonatomic) IBOutlet UILabel *tradeStatuL;
@property (weak, nonatomic) IBOutlet UILabel *transAmtL;
@property (weak, nonatomic) IBOutlet UILabel *transDateL;

@end

@implementation KDAgentTradeListCell


- (void)setModel:(KDAgentTradeModel *)model{
    _nameL.text = model.merName;
    _merCodeL.text = model.merCode;
    _orderNumL.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"订单号:", nil), model.orderNum];
    
    NSString *transTypeStr = NSLocalizedString(@"消费", nil);//PER、01 消费
    if ([model.transCode isEqualToString:@"PVR"] || [model.transCode isEqualToString:@"31"]) {
        transTypeStr = NSLocalizedString(@"撤销", nil);
    }
    if ([model.transCode isEqualToString:@"CTH"]) {
        transTypeStr = NSLocalizedString(@"退货", nil);
    }
    _tradeTypeL.text = transTypeStr;
    
    _cardNoL.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"交易卡号:", nil), model.cardNo];
    
    //EMV-主扫-成功
    NSString *result = NSLocalizedString(@"成功", nil);
    if (![model.respCode isEqualToString:@"00"]) {
        result = NSLocalizedString(@"失败", nil);
    }
    NSString *typeStr = NSLocalizedString(@"主扫", nil);//93、94主扫
    if ([model.srveniryMode hasPrefix:@"03"] || [model.srveniryMode hasPrefix:@"04"]) {
        typeStr = NSLocalizedString(@"被扫", nil);
    }
    NSString *emvStr = @"POS";
    //03、03、93、94是emv 其他是pos
    if ([model.srveniryMode hasPrefix:@"03"] || [model.srveniryMode hasPrefix:@"04"] || [model.srveniryMode hasPrefix:@"93"] || [model.srveniryMode hasPrefix:@"94"]) {
        emvStr = @"EMV";
    }
    _tradeStatuL.text = [NSString stringWithFormat:@"%@-%@-%@", emvStr, typeStr, result];
    
    _transAmtL.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"交易金额:", nil), model.transAmt];
    _transDateL.text = model.transDate;
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
