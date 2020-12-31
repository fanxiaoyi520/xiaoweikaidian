//
//  KDAddSettmentCardController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/4/28.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDAddSettmentCardController.h"
#import "KDBankNameModel.h"
#import "KDBranchBankModel.h"

#define left_distance 130

@interface KDAddSettmentCardController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

/** tableView */
@property (nonatomic, strong) UITableView *tableView;
///左侧标题
@property (nonatomic, strong)NSArray *titleArray;
/** 开户姓名TextField */
@property(nonatomic, strong) UITextField *accountNameTF;
/** 银行账号TextField */
@property(nonatomic, strong) UITextField *bankNoTF;
///选择的银行
@property (nonatomic, strong)KDBankNameModel *bankNameModel;
///选择的分行
@property (nonatomic, strong)KDBranchBankModel *branchBankModel;
///临时选择的银行
@property (nonatomic, assign)NSInteger bankIndex;

@end

@implementation KDAddSettmentCardController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.whiteNavTitle = NSLocalizedString(@"添加收款账户", nil);
    _titleArray = [NSArray arrayWithObjects:NSLocalizedString(@"受益人姓名", nil), NSLocalizedString(@"银行账号", nil), NSLocalizedString(@"银行名称", nil), NSLocalizedString(@"所属分行", nil), nil];
    [self createView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
}

- (void)createView{
    for (NSInteger i = 0; i < 2; i++) {
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(left_distance, 0, SCREEN_WIDTH-left_distance-40, 44)];
        textField.textAlignment = NSTextAlignmentRight;
        textField.font = [UIFont systemFontOfSize:15.0];
        textField.delegate = self;
        if (i == 0) {
            textField.placeholder = NSLocalizedString(@"请输入银行开户姓名", nil);
            _accountNameTF = textField;
        }
        
        if (i == 1) {
            textField.placeholder = NSLocalizedString(@"请输入银行账号", nil);
            textField.keyboardType = UIKeyboardTypeNumberPad;
            _bankNoTF = textField;
        }
    }
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = GrayBgColor;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.showsVerticalScrollIndicator = YES;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

#pragma mark - tableview
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 70;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.textColor = ZFAlpColor(0, 0, 0, 0.8);
    cell.textLabel.text = _titleArray[indexPath.row];
    
    if (indexPath.row == 0) {
        [cell addSubview:_accountNameTF];
    }
    if (indexPath.row == 1) {
        [cell addSubview:_bankNoTF];
    }
    if (indexPath.row == 2 || indexPath.row == 3) {
        UIView *selectView = [[UIView alloc] initWithFrame:CGRectMake(120, 0, SCREEN_WIDTH-140, 44)];
        selectView.tag = indexPath.row;
        [cell addSubview:selectView];
        // 添加手势
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectViewClicked:)];
        [selectView addGestureRecognizer:tapGestureRecognizer];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(selectView.frame)-(selectView.width-25+20), 0, selectView.width-25, 44)];
        if (indexPath.row == 2) {
            titleLabel.text = !_bankNameModel ? NSLocalizedString(@"请选择开户银行", nil) : _bankNameModel.bankName;
        } else {
            titleLabel.text = !_branchBankModel ? NSLocalizedString(@"请选择所属分行", nil) : _branchBankModel.branchName;
        }
        titleLabel.font = [UIFont systemFontOfSize:15.0];
        titleLabel.textColor = ZFAlpColor(0, 0, 0, 0.3);
        titleLabel.textAlignment = NSTextAlignmentRight;
        [cell addSubview:titleLabel];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_fold_grey"]];
        imageView.frame = CGRectMake(CGRectGetMaxX(titleLabel.frame)+5, 12, 20, 20);
        [cell addSubview:imageView];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 70)];
    
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 30, SCREEN_WIDTH-40, 40)];
    [confirmBtn setTitle:NSLocalizedString(@"确认", nil) forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmBtn.layer.cornerRadius = 5.0f;
    confirmBtn.backgroundColor = MainThemeColor;
    [confirmBtn addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:confirmBtn];
    
    return backView;
}

#pragma mark - pickerView
- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 10;
}

#pragma mark - 点击方法
//选择银行或分行
- (void)selectViewClicked:(UITapGestureRecognizer *)tap{
    
}

//点击确认提交
- (void)confirmBtnClicked{
    
}


@end
