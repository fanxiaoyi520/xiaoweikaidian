//
//  ZFBankCardCell.m
//  newupop
//
//  Created by Jellyfish on 2017/7/25.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBankCardCell.h"

@interface ZFBankCardCell ()

/** logo */
@property (nonatomic, weak) UIImageView *logoIV;
/** 银行名称 */
@property (nonatomic, weak) UILabel *bankNameLabel;
/** 卡类型 */
@property (nonatomic, weak) UILabel *cardTypeLabel;
/** 卡号 */
@property (nonatomic, weak) UILabel *cardNoLabel;
///城市
@property (nonatomic, weak) UILabel *cityLabel;

@end

@implementation ZFBankCardCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"ZFBankCardCell";
    ZFBankCardCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
//    if (!cell) {
        cell = [[ZFBankCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
//    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupSubviews];
    }
    return self;
}

/** 添加子控件 */
- (void)setupSubviews {
    // 银行logo
    UIImageView *logoIV = [[UIImageView alloc] init];
    logoIV.frame = CGRectMake(20, 22, 36, 36);
    logoIV.image = [UIImage imageNamed:@"pic_sinopay_card"];
    [self addSubview:logoIV];
    self.logoIV = logoIV;
    
    // 银行名称
    UILabel *bankNameLabel = [[UILabel alloc] init];
    bankNameLabel.frame = CGRectMake(CGRectGetMaxX(logoIV.frame)+10, logoIV.y, SCREEN_WIDTH*0.4, 15);
    bankNameLabel.text = @"SINOPAY";
    bankNameLabel.textColor = UIColorFromRGB(0x313131);
    bankNameLabel.textAlignment = NSTextAlignmentLeft;
    bankNameLabel.font = [UIFont systemFontOfSize:14.0];
    [self addSubview:bankNameLabel];
    self.bankNameLabel = bankNameLabel;
    
    // 卡类型
    UILabel *cardTypeLabel = [[UILabel alloc] init];
    cardTypeLabel.frame = CGRectMake(bankNameLabel.x, CGRectGetMaxY(logoIV.frame)-13, SCREEN_WIDTH*0.2, 13);
    cardTypeLabel.text = @"预付卡";
    cardTypeLabel.textColor = UIColorFromRGB(0x313131);
    cardTypeLabel.textAlignment = NSTextAlignmentLeft;
    cardTypeLabel.font = [UIFont systemFontOfSize:12.0];
    [self addSubview:cardTypeLabel];
    self.cardTypeLabel = cardTypeLabel;
    
    // 卡号
    UILabel *cardNoLabel = [[UILabel alloc] init];
    cardNoLabel.frame = CGRectMake(SCREEN_WIDTH*0.4, logoIV.y, SCREEN_WIDTH*0.6-40, 36);
    cardNoLabel.text = @"**** **** **** 1234";
    cardNoLabel.textColor = ZFAlpColor(0, 0, 0, 0.8);
    cardNoLabel.textAlignment = NSTextAlignmentRight;
    cardNoLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:cardNoLabel];
    self.cardNoLabel = cardNoLabel;
}

- (void)setModel:(ZFBankCardModel *)model {
    
    self.bankNameLabel.text = model.bankName;
    self.cardTypeLabel.text = [model.cardType isEqualToString:@"1"] ? @"借记卡" : @"信用卡";
    self.cardNoLabel.text = model.cardNum;
}


@end
