//
//  KDWithdrawalDetailsViewController.m
//  SinopayStore
//
//  Created by Jellyfish on 2018/1/3.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDWithdrawalDetailsViewController.h"
#import "YYModel.h"
#import "KDWithdrawalDetails.h"
#import "KDAwardDetails.h"

@interface KDWithdrawalDetailsViewController () <UITableViewDataSource, UITableViewDelegate>

/** tableView */
@property (nonatomic, weak) UITableView *tableView;

/** 左边显示信息 */
@property(nonatomic, strong) NSMutableArray *leftTitleArray;
/** 提现详情模型 */
@property(nonatomic, strong) KDWithdrawalDetails *withdrawalDetail;
/** 奖励详情模型 */
@property(nonatomic, strong) KDAwardDetails *awardDetail;

/** 详情类型 */
@property(nonatomic, assign) DetailsType type;

@end

@implementation KDWithdrawalDetailsViewController

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([_transNumber hasPrefix:@"B"] || [_transNumber hasPrefix:@"b"]) {
        self.type = DetailsTypeAward;
        self.naviTitle = NSLocalizedString(@"奖励详情", nil);
        self.leftTitleArray = [NSMutableArray arrayWithObjects:NSLocalizedString(@"奖励金额", nil), NSLocalizedString(@"当前状态", nil), NSLocalizedString(@"奖励单号", nil), NSLocalizedString(@"交易参考号", nil), NSLocalizedString(@"交易金额", nil), nil];
    } else if ([_transNumber hasPrefix:@"R"]){
        self.type = DetailsTypeRevocation;
        self.naviTitle = NSLocalizedString(@"奖励撤销详情", nil);
        self.leftTitleArray = [NSMutableArray arrayWithObjects:NSLocalizedString(@"撤销金额", nil), NSLocalizedString(@"当前状态", nil), NSLocalizedString(@"撤销单号", nil), NSLocalizedString(@"交易参考号", nil), NSLocalizedString(@"交易金额", nil), nil];
    } else {
        self.type = DetailsTypeWithdrawal;
        self.naviTitle = NSLocalizedString(@"提现详情", nil);
        self.leftTitleArray = [NSMutableArray arrayWithObjects:NSLocalizedString(@"提现金额", nil), NSLocalizedString(@"当前状态", nil), NSLocalizedString(@"提现单号", nil), NSLocalizedString(@"收款银行卡", nil), NSLocalizedString(@"提现申请时间", nil), nil];
    }
    
    [self setupTableView];
    [self getTransDetails];
}


#pragma mark - 初始化方法
// 设置tableView
- (void)setupTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = GrayBgColor;
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
        return 1;
    } else {
        return self.leftTitleArray.count-1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DetailsCell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.textColor = ZFAlpColor(0, 0, 0, 0.8);
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    if (indexPath.section == 0) {
        cell.textLabel.text = self.leftTitleArray[indexPath.row];
        cell.detailTextLabel.textColor = MainFontColor;
        cell.detailTextLabel.text = self.type != DetailsTypeWithdrawal ? self.awardDetail.bonusAmt : self.withdrawalDetail.drawAmt;
    } else {
        cell.textLabel.text = self.leftTitleArray[indexPath.row+1];
        cell.detailTextLabel.textColor = ZFAlpColor(0, 0, 0, 0.6);
        
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = self.type != DetailsTypeWithdrawal ? self.awardDetail.bonusStatus : self.withdrawalDetail.drawStatus;
        } else if (indexPath.row == 1) {
            cell.detailTextLabel.text = self.type != DetailsTypeWithdrawal ? self.awardDetail.bonusId : self.withdrawalDetail.drawNumber;
        } else if (indexPath.row == 2) {
            cell.detailTextLabel.text = self.type != DetailsTypeWithdrawal ? self.awardDetail.serialNumber : self.withdrawalDetail.cardNo;
        } else if (indexPath.row == 3) {
            cell.detailTextLabel.text = self.type != DetailsTypeWithdrawal ? self.awardDetail.transAmt : self.withdrawalDetail.drawApplyTime;
        } else {
            cell.detailTextLabel.text = self.withdrawalDetail.drawAccTime;
        }
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
    return 0.0001;
}


#pragma mark -- 网络请求
- (void)getTransDetails {
    NSString *transNumber = _transNumber;
    if ([_transNumber isKindOfClass:[NSNull class]] || !_transNumber) {
        transNumber = @"";
    }
    NSDictionary *parameters = @{
                                 @"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"startDate": @"2018-08",//[self.record.transDate substringToIndex:7],
                                 @"transNumber":transNumber,
                                 @"beginNum": @"1",
                                 @"queryRows": @"20",
                                 @"txnType": @"44",
                                 };
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            
            if (self.type != DetailsTypeWithdrawal) {
                self.awardDetail = [KDAwardDetails yy_modelWithJSON:[requestResult objectForKey:@"info"]];
            } else {
                self.withdrawalDetail = [KDWithdrawalDetails yy_modelWithJSON:[requestResult objectForKey:@"info"]];
                if (self.withdrawalDetail.drawAccTime.length > 0) {
                    [self.leftTitleArray addObject:NSLocalizedString(@"提现到账时间", nil)];
                }
            }
            
            [self.tableView reloadData];
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {
        
    }];
}

@end
