//
//  KDCashierRigisterController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/1/3.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDCashierRigisterController.h"
#import "KDCRegisterDetailController.h"

@interface KDCashierRigisterController ()<UITableViewDelegate, UITableViewDataSource>
///商户号
@property (nonatomic, strong)UITextField *numTextField;
///商户列表
@property (nonatomic, strong)UITableView *tableView;
///商户数组
@property (nonatomic, strong)NSMutableArray *dataArray;

@end

@implementation KDCashierRigisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"收银员注册", nil);
    self.view.backgroundColor = GrayBgColor;
    
    [self createView];
}

- (void)createView{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight+20, SCREEN_WIDTH, 40)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, 40)];
    nameLabel.text = NSLocalizedString(@"商户号", nil);
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.adjustsFontSizeToFitWidth = YES;
    [backView addSubview:nameLabel];
    
    _numTextField = [[UITextField alloc] initWithFrame:CGRectMake(nameLabel.right+10, 0, SCREEN_WIDTH-120, 40)];
    _numTextField.font = [UIFont systemFontOfSize:14];
    _numTextField.placeholder = NSLocalizedString(@"请输入商户号", nil);
    _numTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _numTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_numTextField limitTextLength:15];
    [backView addSubview:_numTextField];
    
    //确定按钮
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, backView.bottom+45, SCREEN_WIDTH-40, 40)];
    confirmBtn.backgroundColor = MainThemeColor;
    confirmBtn.layer.cornerRadius = 5;
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [confirmBtn setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmBtn];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, backView.bottom+10, SCREEN_WIDTH, SCREEN_HEIGHT-backView.bottom-10) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = GrayBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
//    [self.view addSubview:_tableView];
}

#pragma mark 下一步
- (void)nextStep{
    if (_numTextField.text.length == 0) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请输入商户号", nil) inView:nil];
        return;
    }
    if (_numTextField.text.length < 5) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"商户号输入错误", nil) inView:self.view];
        return;
    }
    
    NSDictionary *dict = @{@"merId":_numTextField.text,
                           @"txnType":@"30"
                           };
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] dismissMB];
            NSString *merName = [requestResult objectForKey:@"merName"];
            NSString *merId = [requestResult objectForKey:@"merId"];
            if ([merName isKindOfClass:[NSNull class]] || !merName) {
                return ;
            }
            if ([merId isKindOfClass:[NSNull class]] || !merId) {
                return ;
            }
            
            KDCRegisterDetailController *crdVC = [[KDCRegisterDetailController alloc] init];
            crdVC.merName = merName;
            crdVC.merId = merId;
            [self pushViewController:crdVC];
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

- (void)getData{
    _dataArray = [NSMutableArray arrayWithObjects:@"1234", @"1234", @"1234", @"1234", @"1234", @"1234", @"1234", nil];
}

#pragma mark - table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
   
    if (indexPath.row < _dataArray.count) {
        cell.textLabel.text = _dataArray[indexPath.row];
        cell.detailTextLabel.text = _dataArray[indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_tableView reloadData];
}

@end
