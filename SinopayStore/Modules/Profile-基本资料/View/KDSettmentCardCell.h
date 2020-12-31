//
//  KDSettmentCardCell.h
//  SinopayStore
//
//  Created by 中付支付 on 2018/4/28.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSettmentCardModel.h"

@protocol SettmentCellDelegate <NSObject>

- (void)clickChangeBtnWith:(NSString *)tag;

@end

@interface KDSettmentCardCell : UITableViewCell
///卡背景
@property (nonatomic, strong)UIImageView *backImageView;
///卡logo
@property (nonatomic, strong)UIImageView *logoImageView;
///卡名称
@property (nonatomic, strong)UILabel *cardNameLabel;
///用户名
@property (nonatomic, strong)UILabel *userNameLabel;
///卡号
@property (nonatomic, strong)UILabel *cardNoLabel;
///结算状态
@property (nonatomic, strong)UILabel *setStatuLabel;
///修改按钮
@property (nonatomic, strong)UIButton *changeBtn;

@property (nonatomic, strong)KDSettmentCardModel *settmentCardModel;

///
@property (nonatomic, weak)id<SettmentCellDelegate> delegate;

@end
