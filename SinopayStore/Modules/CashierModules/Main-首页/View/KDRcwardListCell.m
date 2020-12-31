//
//  KDRcwardListCell.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/3/1.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDRcwardListCell.h"

@implementation KDRcwardListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = GrayBgColor;
    }
    return self;
}

- (void)setModel:(KDRewardListModel *)model{
    //清空之前的子页面
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //底部
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-40, 155)];
    backView.backgroundColor = [UIColor whiteColor];
    backView.layer.cornerRadius = 5;
    [self addSubview:backView];
    
    //
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 35)];
    tipLabel.text = NSLocalizedString(@"奖励详情", nil);
    tipLabel.textColor = MainThemeColor;
    tipLabel.font = [UIFont boldSystemFontOfSize:15];
    [tipLabel sizeToFit];
    tipLabel.size = CGSizeMake(tipLabel.width, 35);
    [backView addSubview:tipLabel];
    
    //领取状态
    UILabel *statusL = [[UILabel alloc] initWithFrame:CGRectMake(tipLabel.right+10, 0, backView.width-tipLabel.right-30, 35)];
    statusL.font = [UIFont systemFontOfSize:14];
    statusL.textAlignment = NSTextAlignmentRight;
    statusL.adjustsFontSizeToFitWidth = YES;
    if (![model.gainMsg isKindOfClass:[NSNull class]] && model.gainMsg.length>0) {
        statusL.text = model.gainMsg;
        if (![model.gainStatus isEqualToString:@"0"]) {
            statusL.textColor = UIColorFromRGB(0xF5A623);
        }
    }
    [backView addSubview:statusL];
    
    //横线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, tipLabel.bottom, backView.width-20, 1)];
    lineView.backgroundColor = GrayBgColor;
    [backView addSubview:lineView];
    
    NSArray *titleArr = @[NSLocalizedString(@"奖励单号", nil), NSLocalizedString(@"交易参考号", nil), NSLocalizedString(@"交易金额", nil), NSLocalizedString(@"奖励金额", nil)];
    
    NSArray *contentArr = [self getContentArr:model];
    
    CGFloat titleY = lineView.bottom+10;
    for (NSInteger i = 0; i < 4; i++) {
        UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(20, 26*i+titleY, 100, 20)];
        titleL.text = titleArr[i];
        titleL.font = [UIFont systemFontOfSize:14];
        [titleL sizeToFit];
        titleL.size = CGSizeMake(titleL.width, 20);
        [backView addSubview:titleL];
        
        UILabel *contentL = [[UILabel alloc] initWithFrame:CGRectMake(titleL.right, titleL.y, backView.width-titleL.width-40, 20)];
        contentL.text = contentArr[i];
        contentL.alpha = 0.6;
        contentL.textAlignment = NSTextAlignmentRight;
        contentL.font = [UIFont systemFontOfSize:14];
        contentL.adjustsFontSizeToFitWidth = YES;
        [backView addSubview:contentL];
        if (i == 3) {
            contentL.textColor = UIColorFromRGB(0xF5A623);
        }
    }
}

- (NSArray *)getContentArr:(KDRewardListModel *)model{
    //    ///奖励编号
    //    @property (nonatomic, strong)NSString *bonusId;
    //    ///参考号
    //    @property (nonatomic, strong)NSString *serialNumber;
    //    ///交易金额
    //    @property (nonatomic, strong)NSString *txnAmt;
    //    ///奖励金额
    //    @property (nonatomic, strong)NSString *bonusAmt;
    //    ///交易币种
    //    @property (nonatomic, strong)NSString *txnCurr;
    
    NSString *bonusId = model.bonusId;
    if (!bonusId || [bonusId isKindOfClass:[NSNull class]]) {
        bonusId = @"";
    }
    NSString *serialNumber = model.serialNumber;
    if (!serialNumber || [serialNumber isKindOfClass:[NSNull class]]) {
        serialNumber = @"";
    }
    NSString *txnAmt = model.txnAmt;
    if (!txnAmt || [txnAmt isKindOfClass:[NSNull class]]) {
        txnAmt = @"";
    }
    NSString *bonusAmt = model.bonusAmt;
    if (!bonusAmt || [bonusAmt isKindOfClass:[NSNull class]]) {
        bonusAmt = @"";
    }
    
    NSArray *arr = @[bonusId, serialNumber, txnAmt, bonusAmt];
    return arr;
}

@end
