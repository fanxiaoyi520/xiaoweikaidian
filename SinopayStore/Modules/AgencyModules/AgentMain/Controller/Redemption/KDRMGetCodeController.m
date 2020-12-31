//
//  KDRMGetCodeController.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/25.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDRMGetCodeController.h"
#import "KDRMPassWordController.h"

@interface KDRMGetCodeController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeight;
@property (weak, nonatomic) IBOutlet UILabel *numTipL;
@property (weak, nonatomic) IBOutlet UILabel *codeTipL;
@property (weak, nonatomic) IBOutlet UITextField *numTF;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UIButton *getCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, assign)NSInteger downCount;

@end

@implementation KDRMGetCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.naviTitle = NSLocalizedString(@"身份验证", nil);
    _topHeight.constant = IPhoneXTopHeight+20;
}

#pragma mark - 点击方法
#pragma mark 获取验证码按钮
- (IBAction)getCodeBtn:(id)sender {
    [self.view endEditing:YES];
    if (_numTF.text.length < 1) {
        [[MBUtils sharedInstance] showMBTipWithText:_numTF.placeholder inView:self.view];
        return;
    }
    
    [self verifyIdCardGetCode];
}

#pragma mark 下一步
- (IBAction)nextStep:(id)sender {
    [self.view endEditing:YES];
    if (_codeTF.text.length < 1) {
        [[MBUtils sharedInstance] showMBTipWithText:_codeTF.placeholder inView:self.view];
        return;
    }
    [self verifyIdCardCode];
}

- (void)retextBtn{
    _downCount--;
    [_getCodeBtn setTitle:[NSString stringWithFormat:@"%zds", _downCount] forState:UIControlStateNormal];
    
    if (_downCount == 0) {
        _getCodeBtn.enabled = YES;
        [_getCodeBtn setTitle:NSLocalizedString(@"重新获取", nil) forState:UIControlStateNormal];
        [_timer invalidate];
    }
}

#pragma mark - 请求
#pragma mark 获取验证码
- (void)verifyIdCardGetCode{

    NSDictionary *dict = @{
                           @"currentLoginUser":[NSString stringWithFormat:@"%@%@", [ZFGlobleManager getGlobleManager].areaNum, [ZFGlobleManager getGlobleManager].userPhone],
                           @"idCard":_numTF.text,
                           @"areaCode":[ZFGlobleManager getGlobleManager].areaNum,
                           @"telPhone":[ZFGlobleManager getGlobleManager].userPhone,
                           @"msgType":@"verifyIdCard",
                           TxnType:@"16"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine agentPostWithParams:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"00"]) {
            [[MBUtils sharedInstance] dismissMB];
            _getCodeBtn.enabled = NO;
            _downCount = 180;
            [self retextBtn];
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(retextBtn) userInfo:nil repeats:YES];
            [_codeTF becomeFirstResponder];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark 验证验证码
- (void)verifyIdCardCode{
    NSDictionary *dict = @{
                           @"currentLoginUser":[NSString stringWithFormat:@"%@%@", [ZFGlobleManager getGlobleManager].areaNum, [ZFGlobleManager getGlobleManager].userPhone],
                           @"msgCode":_codeTF.text,
                           @"areaCode":[ZFGlobleManager getGlobleManager].areaNum,
                           @"telPhone":[ZFGlobleManager getGlobleManager].userPhone,
                           @"msgType":@"verifyIdCard",
                           TxnType:@"17"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine agentPostWithParams:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"00"]) {
            [[MBUtils sharedInstance] dismissMB];
            KDRMPassWordController *pwVC = [[KDRMPassWordController alloc] init];
            pwVC.pwType = _getCodeType+1;
            [self pushViewController:pwVC];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

@end
