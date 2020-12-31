//
//  KDAwardRecordCell.m
//  SinopayStore
//
//  Created by Jellyfish on 2018/1/3.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDAwardRecordCell.h"

@interface KDAwardRecordCell ()

/** 状态 */
@property(nonatomic, weak) UILabel *statusLabel;
/** 时间 */
@property(nonatomic, weak) UILabel *timeLabel;
/** 交易金额 */
@property(nonatomic, weak) UILabel *payMoney;
/** 结余金额 */
@property(nonatomic, weak) UILabel *clearMoney;

@end


@implementation KDAwardRecordCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"KDAwardRecordCell";
    KDAwardRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[KDAwardRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createView];
    }
    
    return self;
}

- (void)createView{
    // 状态
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, (SCREEN_WIDTH-40)/2+40, 23)];
    statusLabel.font = [UIFont systemFontOfSize:14];
    statusLabel.textColor = ZFAlpColor(0, 0, 0, 0.8);
    statusLabel.textAlignment = NSTextAlignmentLeft;
    statusLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:statusLabel];
    self.statusLabel = statusLabel;
    
    // 时间
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(statusLabel.x, CGRectGetMaxY(statusLabel.frame), statusLabel.width, statusLabel.height)];
    timeLabel.textColor = ZFAlpColor(0, 0, 0, 0.6);
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:timeLabel];
    self.timeLabel = timeLabel;
    
    // 交易金额
    UILabel *payMoney = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(statusLabel.frame), statusLabel.y, statusLabel.width-80, statusLabel.height)];
    payMoney.textColor = ZFAlpColor(0, 0, 0, 0.8);
    payMoney.font = [UIFont boldSystemFontOfSize:14];
    payMoney.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:payMoney];
    self.payMoney = payMoney;
    
    // 结余金额
    UILabel *clearMoney = [[UILabel alloc] initWithFrame:CGRectMake(payMoney.x, CGRectGetMaxY(payMoney.frame), payMoney.width, payMoney.height)];
    clearMoney.textColor = ZFAlpColor(0, 0, 0, 0.6);
    clearMoney.font = [UIFont systemFontOfSize:12];
    clearMoney.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:clearMoney];
    self.clearMoney = clearMoney;
}


- (void)setRecord:(KDAwardRecord *)record
{
    self.statusLabel.text = record.transType;
    self.timeLabel.text = record.transDate;
    if ([record.transAmt hasPrefix:@"+"]) {
        self.payMoney.textColor = ZFColor(245, 183, 89);
    } else {
        self.payMoney.textColor = ZFAlpColor(0, 0, 0, 0.8);
    }
    self.payMoney.text = record.transAmt;
    self.clearMoney.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"结余", nil), record.rewardbalAmt];;
}

@end
