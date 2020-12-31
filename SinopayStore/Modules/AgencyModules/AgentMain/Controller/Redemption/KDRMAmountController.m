//
//  KDRMAmountController.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/20.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDRMAmountController.h"
#import "KDRedemptionCardModel.h"
#import "ZFValidatePwdController.h"
#import "KDRMCardListController.h"

@interface KDRMAmountController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeight;
@property (weak, nonatomic) IBOutlet UILabel *cardNumL;
@property (weak, nonatomic) IBOutlet UILabel *rateTipL;
@property (weak, nonatomic) IBOutlet UILabel *currencyL;
@property (weak, nonatomic) IBOutlet UITextField *amountTF;
@property (weak, nonatomic) IBOutlet UILabel *amountTipL;
@property (weak, nonatomic) IBOutlet UILabel *redemptionTipL;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@property (nonatomic, strong)KDRedemptionCardModel *cardModel;
///手续费
@property (nonatomic, assign)double serviceCharge;
///提现金额
@property (nonatomic, assign)double withDarwAmt;

@end

@implementation KDRMAmountController

- (void)viewDidLoad {
    [super viewDidLoad];
    _topHeight.constant = IPhoneXTopHeight+10;
    self.naviTitle = NSLocalizedString(@"提现管理", nil);
    self.view.backgroundColor = UIColorFromRGB(0xf6f6f6);
    [self getBankCardList];
    
    _rateTipL.text = [NSString stringWithFormat:@"提现金额(收取%.2f%%服务费)", _rate*100];
    _amountTipL.text = [NSString stringWithFormat:@"可用余额 %.2f", _amount];
    
    [_amountTF addTarget:self action:@selector(amountEdit) forControlEvents:UIControlEventEditingChanged];
    
    if (_amount < 0.01) {
//        _amountTF.enabled = NO;
        _confirmBtn.enabled = NO;
    }
}

- (void)amountEdit{
    _amountTipL.textColor = [UIColor blackColor];
    if (_amountTF.text.length == 0 || [_amountTF.text doubleValue] < 0.01) {
        _amountTipL.text = [NSString stringWithFormat:@"可用余额 %.2f", _amount];
        return;
    }
    
    _withDarwAmt = [self formatterNumWith:[_amountTF.text doubleValue]];
    _serviceCharge = [self formatterNumWith:_withDarwAmt*_rate];
    
    if (_serviceCharge < 0.1) {
        _serviceCharge = 0.1;
    }
    
    _amountTipL.text = [NSString stringWithFormat:@"服务费 %.2f", _serviceCharge];
    
    if (_withDarwAmt + _serviceCharge > _amount) {
        _amountTipL.text = NSLocalizedString(@"金额已超过可用余额", nil);
        _amountTipL.textColor = [UIColor redColor];
        [self redemptionAll];
    }
}

#pragma mark 全部提现算法
- (void)redemptionAll{
    _withDarwAmt = [self formatterNumWith:_amount / (1+_rate)];
    _serviceCharge = [self formatterNumWith:_amount - _withDarwAmt];
}

- (double)formatterNumWith:(double)num{
    NSDecimalNumberHandler *roundPlain = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    
    NSString *str = [NSString stringWithFormat:@"%f", num];
    NSDecimalNumber *strNum = [NSDecimalNumber decimalNumberWithString:str];
    strNum = [strNum decimalNumberByRoundingAccordingToBehavior:roundPlain];
 
    return [strNum doubleValue];
}

#pragma mark - 点击方法
#pragma mark 更换银行卡
- (IBAction)changeCardBtn:(id)sender {
    KDRMCardListController *clVC = [[KDRMCardListController alloc] init];
    clVC.isChoose = YES;
    clVC.block = ^(KDRedemptionCardModel * _Nonnull model) {
        _cardModel = model;
        _cardNumL.text = model.cardNo;
    };
    [self pushViewController:clVC];
}

#pragma mark 全部提现
- (IBAction)redemptionAllBtn:(id)sender {
//    [self redemptionAll];
    _amountTF.text = [NSString stringWithFormat:@"%.2f", _amount];
//    _amountTipL.text = [NSString stringWithFormat:@"服务费 %.2f", _serviceCharge];
    [self amountEdit];
}

#pragma mark 提现
- (IBAction)confirmBtn:(id)sender {
    [_amountTF resignFirstResponder];
    if (_amount < 0.11) {
        return;
    }
    
    if ([_amountTF.text doubleValue] + _serviceCharge > _amount) {
        NSString *message = [NSString stringWithFormat:@"%@ %.2f\n%@ %.2f", NSLocalizedString(@"到账金额", nil), _withDarwAmt, NSLocalizedString(@"服务费", nil), _serviceCharge] ;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"余额不足以支付服务费，实际到账金额如下", nil) message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self nextStep];
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:confirm];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self nextStep];
    }

}

- (void)nextStep{
    NSDictionary *dict = @{
                           @"currentLoginUser":[NSString stringWithFormat:@"%@%@", [ZFGlobleManager getGlobleManager].areaNum, [ZFGlobleManager getGlobleManager].userPhone],
                           @"settleBankCode":_cardModel.bankCode,
                           @"settleBankName":_cardModel.settleBankName,
                           @"settleCard":_cardModel.settleAccount,
                           @"settleAccountName":_cardModel.settleAccountName,
                           @"serviceCharge":[NSString stringWithFormat:@"%.2f", _serviceCharge],
                           @"inAccountAmt":[NSString stringWithFormat:@"%.2f", _withDarwAmt],
                           @"withDarwAmt":[NSString stringWithFormat:@"%.2f", _withDarwAmt],
                           TxnType:@"22"
                           };
    ZFValidatePwdController *vpVC = [[ZFValidatePwdController alloc] init];
    vpVC.redemptionDict = dict;
    [self pushViewController:vpVC];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == _amountTF) {
        if (string.length == 0) {//删除
            return YES;
        }
        if (![@"1234567890." containsString:string]) {//允许输入内容
            return NO;
        }
        if ([string isEqualToString:@"0"]) {//开头
            if ([textField.text isEqualToString:@"0"]) {
                return NO;
            }
        }
        if ([textField.text containsString:@"."]) {//结尾两位小数
            NSArray *arr = [textField.text componentsSeparatedByString:@"."];
            NSString *str = arr[1];
            if (str.length >= 2) {
                return NO;
            }
        }
        if ([string isEqualToString:@"."]) {
            if (!textField.text.length) {
                textField.text = [@"0" stringByAppendingString:string];
                return NO;
            } else {
                if ([textField.text containsString:@"."]) {
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

#pragma mark - 数据
#pragma mark 获取银行卡
- (void)getBankCardList{
    NSDictionary *dict = @{
                           @"currentLoginUser":[NSString stringWithFormat:@"%@%@", [ZFGlobleManager getGlobleManager].areaNum, [ZFGlobleManager getGlobleManager].userPhone],
                           TxnType:@"20"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine agentPostWithParams:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"00"]) {
            [[MBUtils sharedInstance] dismissMB];
            NSArray *array = [requestResult objectForKey:@"cardList"];
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in array) {
                KDRedemptionCardModel *model = [[KDRedemptionCardModel alloc] init];
                [model setValuesForKeysWithDictionary:dict];
                [arr addObject:model];
            }
            _cardModel = arr[0];
            _cardNumL.text = _cardModel.cardNo;
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

@end
