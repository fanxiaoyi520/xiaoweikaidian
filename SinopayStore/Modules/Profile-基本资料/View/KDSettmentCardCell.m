//
//  KDSettmentCardCell.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/4/28.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDSettmentCardCell.h"

#define HEIGHTRATE (SCREEN_HEIGHT/667)

@implementation KDSettmentCardCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createView];
    }
    self.backgroundColor = GrayBgColor;
    return self;
}

- (void)createView{
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-20, 145*HEIGHTRATE)];
    [self addSubview:backView];
    DLog(@"self.width = %.f", self.width);
    ///卡背景
    _backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, backView.width, 135*HEIGHTRATE)];
    [backView addSubview:_backImageView];
    
    ///卡logo
    UIView *logoBack = [[UIView alloc] initWithFrame:CGRectMake(20, 10, 50*HEIGHTRATE, 50*HEIGHTRATE)];
    logoBack.backgroundColor = [UIColor whiteColor];
    logoBack.layer.cornerRadius = logoBack.height/2;
    [backView addSubview:logoBack];
    
    _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32*HEIGHTRATE, 32*HEIGHTRATE)];
    _logoImageView.center = CGPointMake(logoBack.width/2, logoBack.height/2);
    [logoBack addSubview:_logoImageView];
    
    ///卡名称
    _cardNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(logoBack.right+10, 10, self.width-logoBack.right-20, 16*HEIGHTRATE)];
    _cardNameLabel.textColor = [UIColor whiteColor];
    _cardNameLabel.font = [UIFont systemFontOfSize:15*HEIGHTRATE];
    _cardNameLabel.adjustsFontSizeToFitWidth = YES;
    [backView addSubview:_cardNameLabel];
    
    ///用户名
    _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_cardNameLabel.x, _cardNameLabel.bottom+9*HEIGHTRATE, _cardNameLabel.width, 14*HEIGHTRATE)];
    _userNameLabel.textColor = [UIColor whiteColor];
    _userNameLabel.font = [UIFont systemFontOfSize:12*HEIGHTRATE];
    _userNameLabel.adjustsFontSizeToFitWidth = YES;
    [backView addSubview:_userNameLabel];
    
    ///卡号
    _cardNoLabel = [[UILabel alloc] initWithFrame:CGRectMake(_userNameLabel.x, _userNameLabel.bottom+15*HEIGHTRATE, _userNameLabel.width, 20*HEIGHTRATE)];
    _cardNoLabel.font = [UIFont systemFontOfSize:20*HEIGHTRATE];
    _cardNoLabel.textColor = [UIColor whiteColor];
    _cardNoLabel.adjustsFontSizeToFitWidth = YES;
    [backView addSubview:_cardNoLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(logoBack.x, _cardNoLabel.bottom+10*HEIGHTRATE, backView.width-20, 1)];
    lineView.backgroundColor = [UIColor whiteColor];
    lineView.alpha = 0.3;
    [backView addSubview:lineView];
    
    ///结算状态
    _setStatuLabel = [[UILabel alloc] initWithFrame:CGRectMake(_cardNameLabel.x, lineView.bottom+1, _cardNameLabel.width, 30*HEIGHTRATE)];
    _setStatuLabel.textColor = [UIColor whiteColor];
    _setStatuLabel.font = [UIFont systemFontOfSize:12*HEIGHTRATE];
    _setStatuLabel.adjustsFontSizeToFitWidth = YES;
    [backView addSubview:_setStatuLabel];
    
    ///修改按钮
    _changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _changeBtn.frame = CGRectMake(backView.width-50, _setStatuLabel.y, 40, _setStatuLabel.height);
    [_changeBtn addTarget:self action:@selector(clickChangeBtn) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:_changeBtn];
}

//点击更改
- (void)clickChangeBtn{
    [self.delegate clickChangeBtnWith:@"aaa"];
}

- (void)setSettmentCardModel:(KDSettmentCardModel *)settmentCardModel{
    _backImageView.image = [UIImage imageNamed:@"pic_bank_hengsheng"];
    _logoImageView.image = [UIImage imageNamed:@"bk_hengsheng"];
    _cardNameLabel.text = @"香港上海匯豐銀行有限公司";
    _userNameLabel.text = @"张三";
    _cardNoLabel.text = @"62170**********2455";
    _setStatuLabel.text = @"结算金额30%进入此账户";
}

@end
