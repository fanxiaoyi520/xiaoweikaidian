//
//  KDRMPassWordController.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/25.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDRMPassWordController.h"

@interface KDRMPassWordController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeight;
@property (weak, nonatomic) IBOutlet UIView *originBV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *originBVHeight;
@property (weak, nonatomic) IBOutlet UILabel *tipL1;
@property (weak, nonatomic) IBOutlet UILabel *tipL2;
@property (weak, nonatomic) IBOutlet UILabel *tipL3;
@property (weak, nonatomic) IBOutlet UITextField *originTF;
@property (weak, nonatomic) IBOutlet UITextField *pwTF1;
@property (weak, nonatomic) IBOutlet UITextField *pwTF2;

@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@end

@implementation KDRMPassWordController

- (void)viewDidLoad {
    [super viewDidLoad];
    _topHeight.constant = IPhoneXTopHeight;
    [self setupView];
}

- (void)setupView{
    [_originTF limitTextLength:6];
    [_pwTF1 limitTextLength:6];
    [_pwTF2 limitTextLength:6];
    
    if (_pwType == 1) {
        self.naviTitle = NSLocalizedString(@"设置支付密码", nil);
    } else if (_pwType == 2) {
        self.naviTitle = NSLocalizedString(@"重置支付密码", nil);
    } else {
        _originBV.hidden = NO;
        _originBVHeight.constant = 90;
        self.naviTitle = NSLocalizedString(@"修改支付密码", nil);
    }
    
    _tipL3.text = NSLocalizedString(@"确认密码", nil);
    _pwTF2.placeholder = NSLocalizedString(@"请再次输入", nil);
}

#pragma mark - 确定
- (IBAction)confirmBtn:(id)sender {
    [self.view endEditing:YES];
    if (_pwType == 0) {
        if (_originTF.text.length < 1) {
            [[MBUtils sharedInstance] showMBTipWithText:_originTF.placeholder inView:self.view];
            return;
        }
        if (_originTF.text.length != 6) {
            [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"原密码输入错误", nil) inView:self.view];
            return;
        }
    }
    
    //新密码
    if (_pwTF1.text.length < 1) {
        [[MBUtils sharedInstance] showMBTipWithText:_pwTF1.placeholder inView:self.view];
        return;
    }
    if (_pwTF1.text.length != 6) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"密码输入错误", nil) inView:self.view];
        return;
    }
    
    //确认密码
    if (_pwTF2.text.length < 1) {
        [[MBUtils sharedInstance] showMBTipWithText:_pwTF2.placeholder inView:self.view];
        return;
    }
    if (![_pwTF1.text isEqualToString:_pwTF2.text]) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"两次输入的密码不一致", nil) inView:self.view];
        return;
    }
    
    [self setPW];
}

#pragma mark 设置密码
- (void)setPW{
    NSString *operateType = @"UPDATE_PAY_PASSWORD";
    NSString *oldPw = @"";
    if (_pwType == 0) {
        oldPw = [TripleDESUtils getEncryptWithString:_originTF.text keyString:AgencyTripledesKey ivString:TRIPLEDES_IV];
    }
    
    if (_pwType == 1) {
        operateType = @"SET_PAY_PASSWORD";
    }
    if (_pwType == 2) {
        operateType = @"FORGET_PAY_PASSWORD";
    }
    
    NSString *pw = [TripleDESUtils getEncryptWithString:_pwTF1.text keyString:AgencyTripledesKey ivString:TRIPLEDES_IV];
    
    NSDictionary *dict = @{
                           @"currentLoginUser":[NSString stringWithFormat:@"%@%@", [ZFGlobleManager getGlobleManager].areaNum, [ZFGlobleManager getGlobleManager].userPhone],
                           @"oldPassword":oldPw,
                           @"payPassword":pw,
                           @"secondaryPassword":pw,
                           @"operateType":operateType,
                           @"msgType":@"verifyIdCard",
                           TxnType:@"18"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine agentPostWithParams:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"00"]) {
            [[MBUtils sharedInstance] showMBSuccessdWithText:NSLocalizedString(@"成功", nil) inView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (_pwType == 0) {
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    NSArray *vc = self.navigationController.viewControllers;
                    [self.navigationController popToViewController:vc[vc.count-3] animated:YES];
                }
            });
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

@end
