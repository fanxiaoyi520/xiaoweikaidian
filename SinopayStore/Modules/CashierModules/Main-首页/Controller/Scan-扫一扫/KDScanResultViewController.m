//
//  KDScanResultViewController.m
//  SinopayStore
//
//  Created by Jellyfish on 2018/1/3.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDScanResultViewController.h"

@interface KDScanResultViewController () <UITableViewDataSource, UITableViewDelegate>

/** tableView */
@property (nonatomic, weak) UITableView *tableView;
/** 左边 */
@property(nonatomic, strong) NSArray *leftTitleArray;

@end

@implementation KDScanResultViewController


#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"奖励领取", nil);
    self.leftTitleArray = [NSArray arrayWithObjects:NSLocalizedString(@"奖励单号", nil), NSLocalizedString(@"交易参考号", nil), NSLocalizedString(@"订单金额", nil), NSLocalizedString(@"奖励金额", nil), nil];
    
    [self setupTableView];
}

#pragma mark - 初始化方法
// 设置tableView
- (void)setupTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = GrayBgColor;
    tableView.scrollEnabled = NO;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}


#pragma mark -- UITableViewDataSourece&UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.leftTitleArray.count-1;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DetailsCell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = self.leftTitleArray[indexPath.row];
        cell.detailTextLabel.textColor = ZFAlpColor(0, 0, 0, 0.6);
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = self.scanResult.bonusId;
        } else if (indexPath.row == 1) {
            cell.detailTextLabel.text = self.scanResult.serialNumber;
        } else if (indexPath.row == 2) {
            cell.detailTextLabel.text = self.scanResult.txnAmt;
        }
    } else {
        cell.textLabel.text = self.leftTitleArray[self.leftTitleArray.count-1];
        cell.detailTextLabel.textColor = MainFontColor;
        cell.detailTextLabel.text = self.scanResult.bonusAmt;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 20;
    } else {
        return 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 0.0001;
    } else {
        return 74;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 74)];
    bgView.backgroundColor = GrayBgColor;
    
    UIButton *commitBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 30, SCREEN_WIDTH-40, 44)];
    [commitBtn setTitle:NSLocalizedString(@"领取", nil) forState:UIControlStateNormal];
    [commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    commitBtn.layer.cornerRadius = 5.0f;
    commitBtn.backgroundColor = MainThemeColor;
    [commitBtn addTarget:self action:@selector(commitBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:commitBtn];
    
    return bgView;
}

#pragma mark - 点击方法
- (void)commitBtnClicked
{
    NSDictionary *parameters = @{
                                 @"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                                 @"bonusId": self.scanResult.bonusId,
                                 @"txnType": @"43",
                                 };
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] showMBSuccessdWithText:NSLocalizedString(@"领取成功", nil) inView:self.view];
            // 返回需要刷新可提现金额
            [ZFGlobleManager getGlobleManager].isRWA = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AUTOTIPDISMISSTIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(NSError *error) {
        
    }];
}
@end
