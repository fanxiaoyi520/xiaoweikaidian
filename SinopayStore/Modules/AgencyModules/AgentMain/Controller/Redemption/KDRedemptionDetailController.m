//
//  KDRedemptionDetailController.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/28.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDRedemptionDetailController.h"
#import "KDRedemptionUtil.h"

@interface KDRedemptionDetailController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeight;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *withdrawAmtL;
@property (weak, nonatomic) IBOutlet UILabel *serviceAmtL;
@property (weak, nonatomic) IBOutlet UILabel *currentStatuL;
@property (weak, nonatomic) IBOutlet UILabel *createTimeL;
@property (weak, nonatomic) IBOutlet UILabel *cardNoL;
@property (weak, nonatomic) IBOutlet UILabel *orderNumL;

///处理进度
@property (weak, nonatomic) IBOutlet UILabel *applyTimeL;
@property (weak, nonatomic) IBOutlet UILabel *checkTimeL;
@property (weak, nonatomic) IBOutlet UILabel *successTimeL;
@property (weak, nonatomic) IBOutlet UILabel *checkStatuL;
@property (weak, nonatomic) IBOutlet UILabel *resultL;
@property (weak, nonatomic) IBOutlet UIImageView *checkStatuIV;
@property (weak, nonatomic) IBOutlet UIImageView *resultIV;
@property (weak, nonatomic) IBOutlet UILabel *colorL1;
@property (weak, nonatomic) IBOutlet UILabel *colorL2;
@property (weak, nonatomic) IBOutlet UILabel *colorL3;


@end

@implementation KDRedemptionDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.naviTitle = NSLocalizedString(@"提现详情", nil);
    _topHeight.constant = IPhoneXTopHeight;
    
    if (_detailType == 1) {
        _topView.hidden = NO;
        _topViewHeight.constant = 200;
    }
    [self getData];
}

- (void)setupValueWith:(NSDictionary *)dict{
    NSString *transState = [dict objectForKey:@"transState"];
    
    _withdrawAmtL.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"withDarwAmt"]];
    _serviceAmtL.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"serviceCharge"]];
    _currentStatuL.text = [KDRedemptionUtil getTransStateChineseWith:transState];
    _createTimeL.text = [dict objectForKey:@"applyDate"];
    _cardNoL.text = [dict objectForKey:@"settleCard"];
    _orderNumL.text = [dict objectForKey:@"orderNum"];
    
    //处理进度 默认等待审核
    _applyTimeL.text = [[dict objectForKey:@"applyDate"] substringFromIndex:5];
    
    //审核成功
    if ([transState isEqualToString:@"WTIHDARW_AUDTI_SUCCESS"]) {
        _colorL1.backgroundColor = UIColorFromRGB(0x577CE2);
        _colorL2.backgroundColor = _colorL1.backgroundColor;
        _checkStatuIV.image = [UIImage imageNamed:@"icon_lt_right"];
        _checkStatuL.textColor = UIColorFromRGB(0x577CE2);
        _checkStatuL.alpha = 1;
        _checkTimeL.text = @"03-28 15:26:50";//[[dict objectForKey:@"auditDate"] substringFromIndex:5];
    }
    
    //审核失败
    if ([transState isEqualToString:@"WTIHDARW_AUDTI_FAILED"]) {
        _colorL1.backgroundColor = UIColorFromRGB(0xD73F34);
        _checkStatuIV.image = [UIImage imageNamed:@"icon_lt_fail"];
        _checkStatuL.textColor = UIColorFromRGB(0xD73F34);
        _checkStatuL.text = NSLocalizedString(@"审核失败", nil);
        _checkStatuL.alpha = 1;
        _checkTimeL.text = @"03-28 15:26:50";//[[dict objectForKey:@"auditDate"] substringFromIndex:5];
        _checkTimeL.textColor = UIColorFromRGB(0xD73F34);
    }
    
    //提现成功
    if ([transState isEqualToString:@"WTIHDARW_SUCCESS"]) {
        _colorL1.backgroundColor = _colorL2.backgroundColor = _colorL3.backgroundColor = MainThemeColor;
        _checkStatuIV.image = [UIImage imageNamed:@"icon_lt_right"];
        _resultIV.image = [UIImage imageNamed:@"icon_lt_right"];
        
        _checkStatuL.textColor = MainThemeColor;
        _checkStatuL.alpha = 1;
        _checkTimeL.text = @"03-28 15:26:50";//[[dict objectForKey:@"auditDate"] substringFromIndex:5];
    
        _resultL.textColor = MainThemeColor;
        _resultL.alpha = 1;
        _successTimeL.text = @"03-28 15:26:50";//[[dict objectForKey:@"settleDate"] substringFromIndex:5];
    }
    
    //出账失败
    if ([transState isEqualToString:@"WTIHDARW_SETTLE_FAILED"]) {
        _colorL1.backgroundColor = _colorL2.backgroundColor = MainThemeColor;
        _colorL3.backgroundColor = UIColorFromRGB(0xD73F34);
        _checkStatuIV.image = [UIImage imageNamed:@"icon_lt_right"];
        _resultIV.image = [UIImage imageNamed:@"icon_lt_fail"];
        
        _checkStatuL.textColor = MainThemeColor;
        _checkStatuL.alpha = 1;
        _checkTimeL.text = @"03-28 15:26:50";//[[dict objectForKey:@"auditDate"] substringFromIndex:5];
        
        _resultL.textColor = UIColorFromRGB(0xD73F34);
        _resultL.text = NSLocalizedString(@"出账失败", nil);
        _resultL.alpha = 1;
        _successTimeL.text = @"03-28 15:26:50";//[[dict objectForKey:@"settleDate"] substringFromIndex:5];
        _successTimeL.textColor = UIColorFromRGB(0xD73F34);
    }
}

#pragma mark 获取数据
- (void)getData{

    NSDictionary *dict = @{
                           @"currentLoginUser":[NSString stringWithFormat:@"%@%@", [ZFGlobleManager getGlobleManager].areaNum, [ZFGlobleManager getGlobleManager].userPhone],
                           @"orderNumber":_orderNum,
                           TxnType:@"24"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine agentPostWithParams:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"00"]) {
            [[MBUtils sharedInstance] dismissMB];
            [self setupValueWith:[requestResult objectForKey:@"withDarwDetails"]];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {

    }];
}

@end
