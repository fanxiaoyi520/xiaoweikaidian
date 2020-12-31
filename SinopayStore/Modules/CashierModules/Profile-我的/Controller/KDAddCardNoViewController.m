//
//  KDAddCardNoViewController.m
//  SinopayStore
//
//  Created by Jellyfish on 2018/3/5.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDAddCardNoViewController.h"
#import "UITextField+Format.h"
#import "KDGetMSCodeViewController.h"


@interface KDAddCardNoViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

/** 卡号 */
@property(nonatomic, weak) UITextField *cardNoTF;


@end

@implementation KDAddCardNoViewController

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"收款银行卡", nil);
    
    [self setupTableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.cardNoTF becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

#pragma mark - 初始化方法
- (void)setupTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.backgroundColor = GrayBgColor;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.scrollEnabled = NO;
    tableView.tableFooterView = [UIView new];
    [self.view addSubview:tableView];
}

#pragma mark -- UITableViewDataSourece&UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MYCELL"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.textColor = ZFAlpColor(0, 0, 0, 0.8);
    cell.textLabel.text = NSLocalizedString(@"卡号", nil);
    
    // 右边
    UITextField *textField = [UITextField new];
    textField.placeholder = NSLocalizedString(@"请输入银行卡号", nil);
    textField.textAlignment = NSTextAlignmentLeft;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.textColor = ZFAlpColor(0, 0, 0, 0.6);
    textField.returnKeyType = UIReturnKeyDone;
    textField.font = [UIFont systemFontOfSize:15.0];
    textField.size = CGSizeMake(SCREEN_WIDTH-130, 44);
    textField.x = 110;
    textField.y = 0;
    textField.delegate = self;
    self.cardNoTF = textField;
    [cell addSubview:textField];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 45+44+45)];
    bgView.backgroundColor = GrayBgColor;
    
    // 提交按钮
    UIButton *commitBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 45, SCREEN_WIDTH-40, 44)];
    [commitBtn setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
    [commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [commitBtn setTitleColor:ZFAlpColor(255, 255, 255, 0.7) forState:UIControlStateHighlighted];
    commitBtn.layer.cornerRadius = 5.0f;
    commitBtn.backgroundColor = MainThemeColor;
    [commitBtn addTarget:self action:@selector(commitBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:commitBtn];
    
    return bgView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 45*2+44;
}

#pragma mark - 点击方法
- (void)commitBtnClicked {
    if (self.cardNoTF.text.length == 0) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请输入银行卡号", nil) inView:self.view];
        return;
    } else if (self.cardNoTF.text.length < 9) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"卡号有误", nil) inView:self.view];
        return;
    }
    
    [self.view endEditing:YES];
    
    [self clickGetCodeBtn];
}

// 获取验证码
- (void)clickGetCodeBtn {
    NSString *cardNum = [TripleDESUtils getEncryptWithString:[self.cardNoTF.text stringByReplacingOccurrencesOfString:@" " withString:@""] keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV];
    NSString *phoneNo = [TripleDESUtils getEncryptWithString:[ZFGlobleManager getGlobleManager].userPhone keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV];
    
    NSDictionary *parameters = @{@"countryCode" : [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID" : [ZFGlobleManager getGlobleManager].sessionID,
                                 @"phoneNo" : phoneNo,
                                 @"cardNum" : cardNum,
                                 @"sysareaid" : @"SG",
                                 @"txnType" : @"59"};
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            KDGetMSCodeViewController *vc = [[KDGetMSCodeViewController alloc] initWithParams:parameters];
            vc.cardNum = cardNum;
            vc.orderId = [requestResult objectForKey:@"orderId"];
            [self pushViewController:vc];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            return ;
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - 其他方法
// 格式化卡号
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [textField formatBankCardNoWithString:string range:range];
    return NO;
}


@end
