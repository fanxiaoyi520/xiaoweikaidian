//
//  DDTableViewHeader.m
//  UItableview Cell的点击
//
//  Created by apple on 28/2/17.
//  Copyright © 2017年 mark. All rights reserved.
//

#import "DDTableViewHeader.h"

@interface DDTableViewHeader ()

@property (nonatomic,strong) UIImageView *directionImageView;

/** 日期label */
@property(nonatomic, weak) UILabel *dateLabel;
/** 笔数金额label */
@property(nonatomic, weak) UILabel *totalLabel;

@end


@implementation DDTableViewHeader


- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{

    if (self == [super initWithReuseIdentifier:reuseIdentifier]) {
        
        [self setupItems];
    }
    
    return self;
}


- (void)setupItems{
    UILabel *dateLabel = [[UILabel alloc] init];
    dateLabel.frame = CGRectMake(20, 0, 90, 44);
    dateLabel.textColor = [UIColor blackColor];
    dateLabel.textAlignment = NSTextAlignmentLeft;
    dateLabel.font = [UIFont systemFontOfSize:15.0];
    [self.contentView addSubview:dateLabel];
    self.dateLabel = dateLabel;
    
    UILabel *totalLabel = [[UILabel alloc] init];
    totalLabel.frame = CGRectMake(dateLabel.right, 0, SCREEN_WIDTH-dateLabel.right-60, 44);
    totalLabel.textColor = [UIColor blackColor];
    totalLabel.textAlignment = NSTextAlignmentCenter;
    totalLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.contentView addSubview:totalLabel];
    self.totalLabel = totalLabel;
    
    //右上角箭头图片
    self.directionImageView.image = [UIImage imageNamed:@"brand_expand"];
    self.directionImageView.frame = CGRectMake(SCREEN_WIDTH - 30, (44-8)/2, 15, 8);
    [self.contentView addSubview:self.directionImageView];

    //btn覆盖header,相应点击
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    button.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:button];
    [button addTarget:self action:@selector(headerClick:) forControlEvents:UIControlEventTouchUpInside];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.contentView.layer.borderWidth = 0.5;
}

- (void)headerClick:(UIButton *)btn{

    self.sectionModel.isExpanded = !self.sectionModel.isExpanded;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        if (!self.sectionModel.isExpanded) {
            
            self.directionImageView.transform = CGAffineTransformIdentity;
            
        }else{
        
            self.directionImageView.transform = CGAffineTransformMakeRotation(M_PI);
        }

    }];
    
    if (self.HeaderClickedBack) {
        
        self.HeaderClickedBack(self.sectionModel.isExpanded);
    }

}



- (UIImageView *)directionImageView {

    if (!_directionImageView) {
        
        _directionImageView = [[UIImageView alloc] init];
    }

    return _directionImageView;
}


- (void)setSectionModel:(KDCollectionDateModel *)sectionModel {
    _sectionModel = sectionModel;
    
    // 日期
    self.dateLabel.text = sectionModel.day;
    
    // 总的
    NSString *dailyAcount = @"0";
    if (![sectionModel.dailyAccount isKindOfClass:[NSNull class]]) {
        dailyAcount = [NSString stringWithFormat:@"%.2f", [sectionModel.dailyAccount doubleValue]/100];
    }
    self.totalLabel.text = [NSString stringWithFormat:@"%@%@%@   %@%@", NSLocalizedString(@"共", nil), sectionModel.dailyTotals, NSLocalizedString(@"笔", nil), dailyAcount, sectionModel.curr];
    
    if (!_sectionModel.isExpanded) {
        
        self.directionImageView.transform = CGAffineTransformIdentity;
        
    } else {
        self.directionImageView.transform = CGAffineTransformMakeRotation(M_PI);
    }
}



@end
