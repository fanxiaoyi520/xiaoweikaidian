//
//  KDSetMoneyController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/11/20.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDSetMoneyController.h"

@interface KDSetMoneyController ()<UITextFieldDelegate>
///金额输入框
@property (nonatomic, strong)UITextField *amountTF;
@property (nonatomic, strong)NSString *zero_Frist;
@property (nonatomic, strong)NSString *point_Two;
@end

@implementation KDSetMoneyController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"设置金额", nil);
    self.view.backgroundColor = GrayBgColor;
    [self createView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_amountTF becomeFirstResponder];
}

- (void)createView{
    UIView *bjView = [UIView new];
    bjView.frame = CGRectMake(20, IPhoneXTopHeight+30, SCREEN_WIDTH-40, 299);
    bjView.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1/1.0];
    bjView.layer.cornerRadius = 5.0f;
    [self.view addSubview:bjView];
    
    UIImageView *payImageView = [UIImageView new];
    [bjView addSubview:payImageView];
    payImageView.frame = CGRectMake(10, 16, 36, 36);
    
    UILabel *payLab = [UILabel new];
    [bjView addSubview:payLab];
    payLab.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    payLab.textColor = [UIColor colorWithRed:43/255.0 green:45/255.0 blue:48/255.0 alpha:1/1.0];
    payLab.frame = CGRectMake(payImageView.right + 5, 26, bjView.width - 51, 16);
    
    if ([self.payType isEqualToString:@"1"]) {
        payImageView.image = [UIImage imageNamed:@"icon_1unionpay40x40"];
        payLab.text = NSLocalizedString(@"云闪付", nil);
    } else {
        payImageView.image = [UIImage imageNamed:@"icon_1alipay40x40"];
        payLab.text = NSLocalizedString(@" 支付宝 ", nil);
    }
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 68, bjView.width, 231)];
    backView.layer.cornerRadius = 5.0f;
    backView.backgroundColor = [UIColor whiteColor];
    [bjView addSubview:backView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 16)];
    label.text = NSLocalizedString(@"金额", nil);
    label.font = [UIFont boldSystemFontOfSize:15];
    label.alpha = 0.6;
    [backView addSubview:label];
    
    UILabel *symbolL = [[UILabel alloc] init];
    symbolL.text = [ZFGlobleManager getGlobleManager].merTxnCurr;
    symbolL.font =  [UIFont fontWithName:@"PingFangSC-Medium" size:18];
    symbolL.textColor = [UIColor colorWithRed:43/255.0 green:43/255.0 blue:43/255.0 alpha:1/1.0];
    symbolL.adjustsFontSizeToFitWidth = YES;
    [backView addSubview:symbolL];
    CGSize size = [symbolL.text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size:18]}];
    CGSize statuseStrSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
    symbolL.frame = CGRectMake(20, label.bottom+48, statuseStrSize.width, 18);
    
    _amountTF = [[UITextField alloc] initWithFrame:CGRectMake(symbolL.right+10, label.bottom+32, backView.width-symbolL.right-30, 40)];
    _amountTF.keyboardType = UIKeyboardTypeDecimalPad;
    _amountTF.font = [UIFont boldSystemFontOfSize:36];
    _amountTF.delegate = self;
    _amountTF.alpha = 0.8;
    _amountTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [backView addSubview:_amountTF];
    _amountTF.text = self.money;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, _amountTF.bottom+16, backView.width-40, 1)];
    lineView.backgroundColor = MainThemeColor;
    lineView.alpha = 0.2;
    [backView addSubview:lineView];
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake(10, lineView.bottom+32, backView.width-20, 40);
    [confirmBtn setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirmClick) forControlEvents:UIControlEventTouchUpInside];
    confirmBtn.layer.cornerRadius = 5.0;
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmBtn setTitleColor:ZFAlpColor(255, 255, 255, 0.7) forState:UIControlStateHighlighted];
    [confirmBtn setBackgroundImage:[UIImage imageNamed:@"btn_background_clickable"] forState:UIControlStateNormal];
    [backView addSubview:confirmBtn];
}

- (void)confirmClick{
    [[TZLocationManager manager] startLocation];
    [[TZLocationManager manager] startLocationWithGeocoderBlock:^(NSArray *array) {
        if (array.count > 0){
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:[[ZFGlobleManager getGlobleManager] getLocationArray:array] forKey:@"location"];
            [userDefaults synchronize];
            
            [_amountTF resignFirstResponder];
            NSString *amount = _amountTF.text;
            if ([amount doubleValue] < 0.01) {
                [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请输入金额", nil) inView:self.view];
                return;
            }

            self.block(_amountTF.text);
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"No results were returned.", nil) inView:self.view];
            NSLog(@"No results were returned.");
        }
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField == _amountTF) {
        if ([string isEqualToString:@"."]) {
            if ([_amountTF.text containsString:@"."]) {
                return NO;
            }
            if (_amountTF.text.length < 1) {
                return NO;
            }
        }
        
        // 小数点后最多能输入两位
        if ([_amountTF.text containsString:@"."]) {
            NSRange ran = [textField.text rangeOfString:@"."];
            // 由于range.location是NSUInteger类型的，所以这里不能通过(range.location - ran.location)>2来判断
            if (range.location > ran.location) {
                if ([textField.text pathExtension].length > 1 && ![string isEqualToString:@""]) {
                    return NO;
                }
            }
        }
        
        NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@".1234567890"] invertedSet];
        NSString *str = [[string componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
        return [string isEqualToString:str];
    }
    
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
