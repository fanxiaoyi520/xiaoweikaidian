//
//  KDAddMerAuthenController.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/2/18.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDAddMerAuthenController.h"
#import "ZFSignNameController.h"
#import "KDAddMerSuccessController.h"

@interface KDAddMerAuthenController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeight;
@property (weak, nonatomic) IBOutlet UIImageView *signIV;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTF;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UIButton *getCodeBtn;
@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, assign)NSInteger downCount;

@property (nonatomic, strong)UIImage *signImage;

@end

@implementation KDAddMerAuthenController

- (void)viewDidLoad {
    [super viewDidLoad];
    _topHeight.constant = IPhoneXTopHeight+20;
    self.naviTitle = NSLocalizedString(@"手机验证", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    _phoneNumTF.text = _phoneNum;
    [self getCodeBtn:nil];
}

#pragma mark - 点击方法
#pragma mark 签名
- (IBAction)signIV:(id)sender {
    ZFSignNameController *signVC = [[ZFSignNameController alloc] init];
    signVC.block = ^(UIImage *image) {
        self.signImage = image;
        self.signIV.image = image;
    };
    [self pushViewController:signVC];
}

#pragma mark 获取验证码
- (IBAction)getCodeBtn:(id)sender {
    if (_phoneNumTF.text.length < 1) {
        [[MBUtils sharedInstance] showMBTipWithText:_phoneNumTF.placeholder inView:self.view];
        return;
    }
    
    [self getCode];
}

- (void)retextBtn{
    _downCount--;
    [_getCodeBtn setTitle:[NSString stringWithFormat:@"%zds", _downCount] forState:UIControlStateNormal];
    
    if (_downCount == 0) {
        _getCodeBtn.enabled = YES;
        [_getCodeBtn setTitle:@"重新获取" forState:UIControlStateNormal];
        [_timer invalidate];
    }
}

#pragma mark 下一步
- (IBAction)nextStep:(id)sender {
    
    if (![self isCanNextStep]) {
        return;
    }
    [self validateCode];
}

- (BOOL)isCanNextStep{
    if (!_signImage) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请签署姓名", nil) inView:self.view];
        return NO;
    }
    if (_phoneNumTF.text.length < 1) {
        [[MBUtils sharedInstance] showMBTipWithText:_phoneNumTF.placeholder inView:self.view];
        return NO;
    }
    if (_codeTF.text.length < 1) {
        [[MBUtils sharedInstance] showMBTipWithText:_codeTF.placeholder inView:self.view];
        return NO;
    }
    
    return YES;
}

#pragma mark - 数据
#pragma mark 获取验证码
- (void)getCode{
    NSDictionary *dict = @{
                           @"phoneNum":_phoneNumTF.text,
                           @"countryCode":_areaNum,
                           @"merTemNo":_merTemNo,
                           @"commitType":@"Base",
                           @"reqType":@"04"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine merchantPostWithParams:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"rspCode"] isEqualToString:@"00"]) {
            [[MBUtils sharedInstance] dismissMB];
            _getCodeBtn.enabled = NO;
            _downCount = 60;
            [self retextBtn];
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(retextBtn) userInfo:nil repeats:YES];
            [_codeTF becomeFirstResponder];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"rspMsg"] inView:self.view];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)validateCode{
    
    NSString *signStr = [UIImageJPEGRepresentation(_signImage, 0.5) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    NSDictionary *dict = @{
                           @"phoneNum":_phoneNumTF.text,
                           @"countryCode":_areaNum,
                           @"otpNum":_codeTF.text,
                           @"signImage":signStr,
                           @"merTemNo":_merTemNo,
                           @"commitType":@"Base",
                           @"reqType":@"05"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine merchantPostWithParams:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"rspCode"] isEqualToString:@"00"]) {
//            [[MBUtils sharedInstance] dismissMB];
            [self finishAdd];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"rspMsg"] inView:self.view];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)finishAdd{
    NSDictionary *dict = @{
                           @"phoneNum":_phoneNumTF.text,
                           @"countryCode":_areaNum,
                           @"merTemNo":_merTemNo,
                           @"reqType":@"16"
                           };
    [NetworkEngine merchantPostWithParams:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"rspCode"] isEqualToString:@"00"]) {
            [[MBUtils sharedInstance] dismissMB];
            KDAddMerSuccessController *asVC = [[KDAddMerSuccessController alloc] init];
            asVC.merDict = requestResult;
            [self pushViewController:asVC];
            [self removeVC];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"rspMsg"] inView:self.view];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)removeVC{
    NSMutableArray *vcArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    NSMutableArray *resultVC = [NSMutableArray arrayWithObjects:vcArray[0], vcArray[vcArray.count-1], nil];
    [self.navigationController setViewControllers:resultVC animated:NO];
}

@end
