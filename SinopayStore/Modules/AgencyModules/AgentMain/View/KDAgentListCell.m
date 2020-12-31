//
//  KDAgentListCell.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/2/14.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDAgentListCell.h"

@implementation KDAgentListCell

- (void)setModel:(KDAgentModel *)model{
    _nameL.text = model.agentName;
    _accountL.text = model.agentAccount;
    _contactL.text = model.agentContact;
    _statusL.text = model.agentAuditStatus;
    _timeL.text = model.createTime;
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
