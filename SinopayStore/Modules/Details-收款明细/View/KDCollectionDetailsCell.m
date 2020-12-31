//
//  KDCollectionDetailsCell.m
//  SinopayStore
//
//  Created by Jellyfish on 2017/12/7.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "KDCollectionDetailsCell.h"
#import "DateUtils.h"

@interface KDCollectionDetailsCell ()

/** 收款类型 */
@property (nonatomic, weak) UILabel *collectionTypeLabel;
/** 交易金额 */
@property (nonatomic, weak) UILabel *tradeAmountLabel;
/** 交易时间 */
@property (nonatomic, weak) UILabel *tradeTimeLabel;
/** 结算金额 */
@property (nonatomic, weak) UILabel *finalAmountLabel;

@end

@implementation KDCollectionDetailsCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"FinanceDetailsCell";
    KDCollectionDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[KDCollectionDetailsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupSubviews];
    }
    
    return self;
}

/** 添加子控件 */
- (void)setupSubviews {
    // 上横线
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    topLine.backgroundColor = GrayBgColor;
    [self addSubview:topLine];
    // 下横线
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 59, SCREEN_WIDTH, 1)];
    bottomLine.backgroundColor = GrayBgColor;
    [self addSubview:bottomLine];
    
    // 收款类型
    UILabel *collectionTypeLabel = [[UILabel alloc] init];
    collectionTypeLabel.frame = CGRectMake(20, 12-3, SCREEN_WIDTH/2, 18);
    collectionTypeLabel.textColor = ZFAlpColor(0, 0, 0, 0.8);
    collectionTypeLabel.textAlignment = NSTextAlignmentLeft;
    collectionTypeLabel.font = [UIFont systemFontOfSize:14.0];
    collectionTypeLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:collectionTypeLabel];
    self.collectionTypeLabel = collectionTypeLabel;
    
    // 交易金额
    UILabel *tradeAmountLabel = [[UILabel alloc] init];
    tradeAmountLabel.frame = CGRectMake(SCREEN_WIDTH/2, 12-3, SCREEN_WIDTH/2-20, 18);
    tradeAmountLabel.textColor = ZFAlpColor(0, 0, 0, 0.6);
    tradeAmountLabel.textAlignment = NSTextAlignmentRight;
    tradeAmountLabel.font = [UIFont systemFontOfSize:12.0];
    [self addSubview:tradeAmountLabel];
    self.tradeAmountLabel = tradeAmountLabel;
    
    // 交易时间
    UILabel *tradeTimeLabel = [[UILabel alloc] init];
    tradeTimeLabel.frame = CGRectMake(20, CGRectGetMaxY(collectionTypeLabel.frame)+3, SCREEN_WIDTH/2, 18);
    tradeTimeLabel.textColor = ZFAlpColor(0, 0, 0, 0.6);
    tradeTimeLabel.textAlignment = NSTextAlignmentLeft;
    tradeTimeLabel.font = [UIFont systemFontOfSize:12.0];
    [self addSubview:tradeTimeLabel];
    self.tradeTimeLabel = tradeTimeLabel;
    
    // 结算金额
//    UILabel *finalAmountLabel = [[UILabel alloc] init];
//    finalAmountLabel.frame = CGRectMake(SCREEN_WIDTH/2, CGRectGetMaxY(tradeAmountLabel.frame)+3, SCREEN_WIDTH/2-20, 18);
//    finalAmountLabel.textColor = MainThemeColor;
//    finalAmountLabel.textAlignment = NSTextAlignmentRight;
//    finalAmountLabel.font = [UIFont systemFontOfSize:14.0];
//    [self addSubview:finalAmountLabel];
//    self.finalAmountLabel = finalAmountLabel;
}

- (void)setCellModel:(KDCollectionDeatilsModel *)cellModel {
    _cellModel = cellModel;
    // 交易类型
    self.collectionTypeLabel.text = cellModel.recMethod;
    
    // 金额
//    self.tradeAmountLabel.text = [NSString stringWithFormat:@"%@%.2f", NSLocalizedString(@"金额：", nil), [cellModel.txnAmt floatValue]/100.0];
    self.tradeAmountLabel.text = [NSString stringWithFormat:@"%.2f",[cellModel.txnAmt floatValue]/100.0];
    
    NSString *tradeTime = cellModel.transTime;
    if (cellModel.transTime.length >= 12) {
        // 截取时间
        tradeTime = [[cellModel.transTime substringFromIndex:8] substringToIndex:4];
        NSString *hour = [tradeTime substringToIndex:2];
        NSString *minute = [tradeTime substringFromIndex:2];
        tradeTime = [[hour stringByAppendingString:@":"] stringByAppendingString:minute];
    }
    // 20171124104541
    // 交易时间
    self.tradeTimeLabel.text = tradeTime;
    // 结算金额
//    self.finalAmountLabel.text = [NSString stringWithFormat:@"%@%.2f", NSLocalizedString(@"结算：", nil), [cellModel.settAmt floatValue]/100.0];
}

@end
