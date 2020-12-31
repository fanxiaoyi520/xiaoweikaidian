//
//  KDRMBalanceDetailController.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/27.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDRMBalanceDetailController.h"
#import "KDRedemptionUtil.h"
#import "KDRedemptionDetailController.h"

@interface KDRMBalanceDetailController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeight;
@property (weak, nonatomic) IBOutlet UILabel *amountTipL;
@property (weak, nonatomic) IBOutlet UILabel *amountL;
@property (weak, nonatomic) IBOutlet UILabel *typeL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (weak, nonatomic) IBOutlet UILabel *balanceAmtL;
@property (weak, nonatomic) IBOutlet UIButton *orderNumBtn;
@property (weak, nonatomic) IBOutlet UIView *orderNumBV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orderNumBVHeight;

@end

@implementation KDRMBalanceDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    _topHeight.constant = IPhoneXTopHeight+10;
    self.naviTitle = NSLocalizedString(@"详情", nil);
    self.view.backgroundColor = GrayBgColor;
    
    if ([_model.operateType isEqualToString:@"WITHDARW"]) {
        _orderNumBV.hidden = NO;
        _orderNumBVHeight.constant = 40;
        _amountTipL.text = NSLocalizedString(@"出账金额", nil);
    }
    [self setupValue];
}

- (IBAction)clickOrderNum:(id)sender {
    KDRedemptionDetailController *rdVC = [[KDRedemptionDetailController alloc] init];
    rdVC.orderNum = _model.orderNum;
    [self pushViewController:rdVC];
}

- (void)setupValue{
    _amountL.text = [NSString stringWithFormat:@"%@", _model.withDarwAmt];
    NSString *operateType = [KDRedemptionUtil getOperateTypeChineseWith:_model.operateType];
    NSString *transState = [KDRedemptionUtil getTransStateChineseWith:_model.transState];
    
    _typeL.text = [NSString stringWithFormat:@"%@-%@", operateType, transState];
    _timeL.text = _model.applyDate;
    _balanceAmtL.text = [NSString stringWithFormat:@"%@", _model.afterAccountAmt];
    [_orderNumBtn setTitle:_model.orderNum forState:UIControlStateNormal];
}


@end
