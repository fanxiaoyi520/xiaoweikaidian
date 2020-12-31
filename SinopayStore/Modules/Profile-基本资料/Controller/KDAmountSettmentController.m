//
//  KDAmountSettmentController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/5/2.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDAmountSettmentController.h"

@interface KDAmountSettmentController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITextField *amountTF;
@property (nonatomic, strong)UITableView *tableView;

@end

@implementation KDAmountSettmentController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.whiteNavTitle = NSLocalizedString(@"结算信息", nil);
    [self createView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
}

- (void)createView{
    _amountTF = [[UITextField alloc] initWithFrame:CGRectMake(100, 0, SCREEN_WIDTH-120, 50)];
    _amountTF.placeholder = NSLocalizedString(@"请输入交易金额", nil);
    _amountTF.textAlignment = NSTextAlignmentRight;
    _amountTF.keyboardType = UIKeyboardTypeDecimalPad;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = GrayBgColor;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:tableView];
    _tableView = tableView;
}

#pragma mark tableviewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 20;
    }
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = NSLocalizedString(@"金额", nil);
        
        [cell addSubview:_amountTF];
        return cell;
    }
    
    //section = 1
    UIImageView *seleteImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-44, 13, 24, 24)];
    [cell addSubview:seleteImage];
    
    NSString *imageName = @"icon_select_normal";
    NSString *str = NSLocalizedString(@"交易金额小于等于", nil);
    if (indexPath.row == 1) {
        str = NSLocalizedString(@"交易金额大于", nil);
        if (_amountType == 2) {
            imageName = @"icon_select_highlight";
        }
    } else {
        if (_amountType == 1) {
            imageName = @"icon_select_highlight";
        }
    }
    seleteImage.image = [UIImage imageNamed:imageName];
    cell.textLabel.text = str;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        _amountType = indexPath.row+1;
        [_tableView reloadData];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return nil;
    }
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake(20, 30, SCREEN_WIDTH-40, 40);
    [confirmBtn setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(clickConfirmBtn) forControlEvents:UIControlEventTouchUpInside];
    confirmBtn.layer.cornerRadius = 5.0;
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmBtn setTitleColor:ZFAlpColor(255, 255, 255, 0.7) forState:UIControlStateHighlighted];
    [confirmBtn setBackgroundImage:[UIImage imageNamed:@"btn_background_clickable"] forState:UIControlStateNormal];
    [confirmBtn setBackgroundImage:[UIImage imageNamed:@"btn_background_non_clickable"] forState:UIControlStateDisabled];
    [confirmBtn setBackgroundImage:[UIImage imageNamed:@"btn_background_clickable"] forState:UIControlStateHighlighted];
    [footView addSubview:confirmBtn];
    
    return footView;
}

- (void)clickConfirmBtn{
    if (_amountTF.text && _amountType) {
        self.amountBlock(_amountTF.text, _amountType);
    }
    [self.navigationController popViewControllerAnimated:YES];
}


@end
