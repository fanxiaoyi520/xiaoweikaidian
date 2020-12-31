//
//  KDAwardRecordHeader.m
//  SinopayStore
//
//  Created by Jellyfish on 2018/1/4.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDAwardRecordHeader.h"

@interface KDAwardRecordHeader ()

/** 日期 */
@property(nonatomic, weak) UILabel *dateLabel;
/** 奖励提现 */
@property(nonatomic, weak) UILabel *awardLabel;

@end


@implementation KDAwardRecordHeader


+ (instancetype)headerViewWithTableView:(UITableView *)tableView {
    static NSString *ID = @"KDAwardRecordHeader";
    KDAwardRecordHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:ID];
    if (!header) {
        header = [[KDAwardRecordHeader alloc] initWithReuseIdentifier:ID];
    }
    
    return header;
}


- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithReuseIdentifier:reuseIdentifier]) {
        [self setupItems];
    }
    
    return self;
}


- (void)setupItems{
    // 日期
    UILabel *dateLabel = [[UILabel alloc] init];
    dateLabel.frame = CGRectMake(20, 5, SCREEN_WIDTH-40, 20);
    dateLabel.textColor = [UIColor blackColor];
    dateLabel.textAlignment = NSTextAlignmentLeft;
    dateLabel.font = [UIFont systemFontOfSize:15.0];
    [self.contentView addSubview:dateLabel];
    self.dateLabel = dateLabel;
    
    // 奖励
    UILabel *awardLabel = [[UILabel alloc] init];
    awardLabel.frame = CGRectMake(20, CGRectGetMaxY(dateLabel.frame), SCREEN_WIDTH-40, 20);
    awardLabel.textColor = ZFAlpColor(0, 0, 0, 0.6);
    awardLabel.textAlignment = NSTextAlignmentLeft;
    awardLabel.font = [UIFont systemFontOfSize:13.0];
    [self.contentView addSubview:awardLabel];
    self.awardLabel = awardLabel;
}

- (void)setSectionModel:(TradeSectionModel *)sectionModel
{
    self.dateLabel.text = sectionModel.month;
    self.awardLabel.text = [NSString stringWithFormat:@"%@%@  %@%@", NSLocalizedString(@"奖励:", nil), sectionModel.bousAct, NSLocalizedString(@"提现:", nil), sectionModel.drawAct];
}

@end
