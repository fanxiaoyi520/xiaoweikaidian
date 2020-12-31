//
//  KDCashierProfileController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/1/3.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDCashierProfileController.h"
#import "KDCashierChangePWController.h"
#import "KDCashierMoreLanguageController.h"
#import "KDCashierDetailController.h"
#import "KDCashierBankCardController.h"
#import "ZFNavigationController.h"


@interface KDCashierProfileController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSArray *dataArray;
@property (nonatomic, strong)NSArray *imageArray;

///头像
@property (nonatomic, strong)UIImageView *headImage;
///商户名
@property (nonatomic, strong)UILabel *nameLabel;

@end

@implementation KDCashierProfileController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = GrayBgColor;
    
    [self setHomeNaviTitle:NSLocalizedString(@"我的", nil)];
    [self createHeadView];
    [self createView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _nameLabel.text = [ZFGlobleManager getGlobleManager].userPhone;
}

- (void)createHeadView{
    UIView *headBack = [[UIView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight+20, SCREEN_WIDTH, 70)];
    headBack.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headBack];
    
    _headImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 11, 48, 48)];
    _headImage.image = [UIImage imageNamed:@"list_icon_head_portrait"];
    [headBack addSubview:_headImage];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headImage.right+20, 0, SCREEN_WIDTH-_headImage.width-60, headBack.height)];
    _nameLabel.font = [UIFont systemFontOfSize:15];
    [headBack addSubview:_nameLabel];
    
    UIImageView *rightImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-37, 0, 17, 17)];
    rightImage.centerY = headBack.height/2;
    rightImage.image = [UIImage imageNamed:@"list_right"];
    [headBack addSubview:rightImage];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushToMerchInfo)];
    [headBack addGestureRecognizer:tap];
}

- (void)pushToMerchInfo{
    KDCashierDetailController *cdVC = [[KDCashierDetailController alloc] init];
    [self pushViewController:cdVC];
}

- (void)createView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight+100, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight-80) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = GrayBgColor;
    _tableView.scrollEnabled = NO;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:_tableView];
    
    //退出按钮
    UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    exitBtn.frame = CGRectMake(SCREEN_WIDTH-80, IPhoneXStatusBarHeight, 60, IPhoneXTopHeight-IPhoneXStatusBarHeight);
    exitBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    exitBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [exitBtn setTitle:NSLocalizedString(@"退出登录", nil) forState:UIControlStateNormal];
    [exitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [exitBtn addTarget:self action:@selector(exitBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:exitBtn];
}

- (void)exitBtn{
    DLog(@"exit");
    [XLAlertController acWithTitle:NSLocalizedString(@"退出登录", nil) msg:@"" confirmBtnTitle:NSLocalizedString(@"确定", nil) cancleBtnTitle:NSLocalizedString(@"取消", nil) confirmAction:^(UIAlertAction *action) {
        [self logout];
    }];
    
}

- (void)logout{
    NSDictionary *dict = @{@"countryCode":[ZFGlobleManager getGlobleManager].areaNum,
                           @"mobile":[ZFGlobleManager getGlobleManager].userPhone,
                           @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                           @"txnType":@"40"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //清空密码
                [ZFGlobleManager getGlobleManager].loginVC.pwdTextField.text = @"";
                [[ZFGlobleManager getGlobleManager] saveLoginPwd:@""];
                
                UIWindow *window = [UIApplication sharedApplication].keyWindow;
                window.rootViewController = [[ZFNavigationController alloc] initWithRootViewController:[ZFGlobleManager getGlobleManager].loginVC];
            });
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark - UITableViewDataSource UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.imageView.image = [UIImage imageNamed:self.imageArray[indexPath.row]];
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DLog(@"%zd", indexPath.row);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        KDCashierBankCardController *vc = [KDCashierBankCardController new];
        [self pushViewController:vc];
    }
    
    if (indexPath.row == 1) {//修改密码
        KDCashierChangePWController *pwVC = [[KDCashierChangePWController alloc] init];
        [self pushViewController:pwVC];
    }
    if (indexPath.row == 2) {//多语言
        KDCashierMoreLanguageController *chVC = [[KDCashierMoreLanguageController alloc] init];
        [self pushViewController:chVC];
    }
}

// 设置分割线偏移
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

#pragma mark - 懒加载
- (NSArray *)dataArray{
    _dataArray = [NSArray arrayWithObjects:NSLocalizedString(@"收款银行卡", nil), NSLocalizedString(@"密码修改", nil), NSLocalizedString(@"多语言", nil), nil];
    return _dataArray;
}

- (NSArray *)imageArray {
    if (!_imageArray) {
        _imageArray = [NSArray arrayWithObjects:@"list_card", @"list_password", @"list_languages", nil];
    }
    
    return _imageArray;
}

@end
