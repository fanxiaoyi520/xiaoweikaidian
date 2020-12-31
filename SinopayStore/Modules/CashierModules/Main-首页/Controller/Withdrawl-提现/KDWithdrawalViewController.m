//
//  KDWithdrawalViewController.m
//  SinopayStore
//
//  Created by Jellyfish on 2018/1/4.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDWithdrawalViewController.h"
#import "KDWithdrawalResultViewController.h"
#import "KDWithdrawalResult.h"
#import "YYModel.h"

@interface KDWithdrawalViewController () <UITextFieldDelegate>

/** 金额输入框 */
@property(nonatomic, weak) UITextField *amountTF;

@end

@implementation KDWithdrawalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"提现", nil);
    
    [self initView];
}

#pragma mark - 初始化视图
- (void)initView {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, 60)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    // 提现金额
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 120, bgView.height)];
    leftLabel.font = [UIFont systemFontOfSize:15.0];
    leftLabel.text = NSLocalizedString(@"提现金额：", nil);
    leftLabel.textColor = ZFAlpColor(0, 0, 0, 0.8);
    leftLabel.textAlignment = NSTextAlignmentLeft;
    [bgView addSubview:leftLabel];
    
    // 金额输入框
    UITextField *amountTF = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftLabel.frame), 0, SCREEN_WIDTH-CGRectGetMaxX(leftLabel.frame)-20, bgView.height)];
    amountTF.placeholder = NSLocalizedString(@"最低提现10.00", nil);
    amountTF.textAlignment = NSTextAlignmentRight;
    amountTF.font = [UIFont systemFontOfSize:20.0];
//    amountTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"最低提现10.00", nil) attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20], NSForegroundColorAttributeName: ZFAlpColor(0, 0, 0, 0.3)}];
    amountTF.keyboardType = UIKeyboardTypeDecimalPad;
    amountTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    amountTF.delegate = self;
    if ([self.withdrawalMoney doubleValue] >= 10) {
        amountTF.text = self.withdrawalMoney;
    }
    [bgView addSubview:amountTF];
    self.amountTF = amountTF;
    
    // 提示图片
    UIImageView *tipView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bgView.frame)-10, SCREEN_WIDTH, 50)];
    tipView.image = [UIImage imageNamed:@"pic_blue_tips"];
    [self.view addSubview:tipView];
    
    // 提示文字
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, SCREEN_WIDTH-20, 40)];
    tipLabel.font = [UIFont systemFontOfSize:12.0];
    tipLabel.text = NSLocalizedString(@"提现金额预计1-2个工作日到账（法定节假日除外）", nil);
    tipLabel.numberOfLines = 0;
    tipLabel.textColor = ZFAlpColor(0, 0, 0, 0.6);
    tipLabel.textAlignment = NSTextAlignmentLeft;
    [tipView addSubview:tipLabel];
    
    // 按钮
    UIButton *nextstepBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(tipView.frame)+30, SCREEN_WIDTH-40, 44)];
    [nextstepBtn setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
    [nextstepBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextstepBtn setTitleColor:ZFAlpColor(255, 255, 255, 0.8) forState:UIControlStateHighlighted];
    nextstepBtn.layer.cornerRadius = 5.0f;
    nextstepBtn.backgroundColor = MainThemeColor;
    [nextstepBtn addTarget:self action:@selector(nextstepBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextstepBtn];
    
    // 可提现金额
    UILabel *withdrawalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(nextstepBtn.frame)+20, SCREEN_WIDTH, 20)];
    withdrawalLabel.font = [UIFont systemFontOfSize:14.0];
    withdrawalLabel.textColor = ZFAlpColor(0, 0, 0, 0.6);
    withdrawalLabel.textAlignment = NSTextAlignmentCenter;
    NSString *tipStr = NSLocalizedString(@"可提现金额：", nil);
    NSString *text = [NSString stringWithFormat:@"%@%@", tipStr, self.withdrawalMoney];
    // 添加富文本属性
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attrStr addAttributes:@{NSForegroundColorAttributeName:MainThemeColor, NSFontAttributeName:[UIFont systemFontOfSize:14.0]} range:NSMakeRange(tipStr.length, text.length-tipStr.length)];
    withdrawalLabel.attributedText = attrStr;
    [self.view addSubview:withdrawalLabel];
}


#pragma mark - 点击方法
- (void)nextstepBtnClicked {
    [self.view endEditing:YES];
    // 想提现的金额
    NSString *amount = self.amountTF.text;
    
    if (amount.length == 0) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请输入提现金额", nil) inView:self.view];
    } else if ([self.amountTF.text floatValue] < 10.00) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"提现金额不能低于10.00", nil) inView:self.view];
    } else if ([self.amountTF.text floatValue] > [self.withdrawalMoney floatValue]) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"已超出可提现金额", nil) inView:self.view];
    } else {
        [self.view endEditing:YES];
        [self withdrawlAction];
    }
}

#pragma mark - 网络请求
// 提现请求
- (void)withdrawlAction {
    NSString *withdrawlAmount = [NSString stringWithFormat:@"%.0f", [self.amountTF.text floatValue]*100];
    
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                                 @"drawAmt": withdrawlAmount,
                                 @"txnType": @"34",};
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            KDWithdrawalResultViewController *vc = [[KDWithdrawalResultViewController alloc] init];
            vc.result = [KDWithdrawalResult yy_modelWithJSON:requestResult];
            [self pushViewController:vc];
            
            // 跳转之后,移除此控制器
            NSMutableArray<ZFBaseViewController *> *tempMArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
            [tempMArray removeObject:self];
            [self.navigationController setViewControllers:tempMArray animated:NO];
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        } 
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - 其他方法
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    BOOL isHaveDian= NO;
    if ([textField.text containsString:@"."]) {
        isHaveDian = YES;
    }else{
        isHaveDian = NO;
    }
   
    if (string.length > 0) {
        
        //当前输入的字符
        unichar single = [string characterAtIndex:0];
        // 不能输入.0-9以外的字符
        if (!((single >= '0' && single <= '9') || single == '.')) {
            return NO;
        }
        
        // 只能有一个小数点
        if (isHaveDian && single == '.') {
            return NO;
        }
        
        // 如果第一位是.则前面加上0.
        if ((textField.text.length == 0) && (single == '.')) {
            textField.text = @"0";
        }
        
        // 如果第一位是0则后面必须输入点，否则不能输入。
        if ([textField.text hasPrefix:@"0"]) {
            if (textField.text.length > 1) {
                NSString *secondStr = [textField.text substringWithRange:NSMakeRange(1, 1)];
                if (![secondStr isEqualToString:@"."]) {
                    return NO;
                }
            }else{
                if (![string isEqualToString:@"."]) {
                    return NO;
                }
            }
        }
        
        // 小数点后最多能输入两位
        if (isHaveDian) {
            NSRange ran = [textField.text rangeOfString:@"."];
            // 由于range.location是NSUInteger类型的，所以这里不能通过(range.location - ran.location)>2来判断
            if (range.location > ran.location) {
                if ([textField.text pathExtension].length > 1) {
                    return NO;
                }
            }
        }
    }
    
    return YES;
}




@end
