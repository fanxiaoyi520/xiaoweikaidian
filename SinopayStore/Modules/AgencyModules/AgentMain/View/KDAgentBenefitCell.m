//
//  KDAgentBenefitCell.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/2/14.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDAgentBenefitCell.h"

@interface KDAgentBenefitCell ()
@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (weak, nonatomic) IBOutlet UILabel *totalTransAmountL;
@property (weak, nonatomic) IBOutlet UILabel *totalFenrunAmountL;
@property (weak, nonatomic) IBOutlet UILabel *agentTransAmtL;
@property (weak, nonatomic) IBOutlet UILabel *agentFenrunAmtL;
@property (weak, nonatomic) IBOutlet UILabel *merchantTransAmtL;
@property (weak, nonatomic) IBOutlet UILabel *merchantFenrunAmtL;

@end

@implementation KDAgentBenefitCell

- (void)setModel:(KDBenefitModel *)model{
    _model = model;
    _timeL.text = model.fenrunDate;
    _totalTransAmountL.text = [NSString stringWithFormat:@"%.2f", [model.transAmount doubleValue]];
    _totalFenrunAmountL.text = [NSString stringWithFormat:@"%.2f", [model.fenrunAmount doubleValue]];
    
    NSDictionary *agentDict = model.agentDict;
    NSDictionary *merDict = model.merchantDict;
    
    _agentTransAmtL.text = [NSString stringWithFormat:@"%.2f", [[agentDict objectForKey:@"transAmount"] doubleValue]];
    _agentFenrunAmtL.text = [NSString stringWithFormat:@"%.2f", [[agentDict objectForKey:@"fenrunAmount"] doubleValue]];
    _merchantTransAmtL.text = [NSString stringWithFormat:@"%.2f", [[merDict objectForKey:@"transAmount"] doubleValue]];
    _merchantFenrunAmtL.text = [NSString stringWithFormat:@"%.2f", [[merDict objectForKey:@"fenrunAmount"] doubleValue]];
}

- (IBAction)agentBtn:(id)sender {
    [self.delegate benefitClickType:@"AGENT" dict:_model.agentDict];
}

- (IBAction)merchantBtn:(id)sender {
    [self.delegate benefitClickType:@"MERCHANTS" dict:_model.merchantDict];
}

@end
