//
//  KDRedemptionManageController.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/20.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDRedemptionManageController.h"
#import "KDTableViewUtil.h"
#import "KDRMAmountController.h"
#import "KDRMGetCodeController.h"
#import "KDRMPayManageController.h"
#import "KDAgentTableViewController.h"

@interface KDRedemptionManageController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeight;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *amountL;

@property (nonatomic, strong)NSString *amount;
@property (nonatomic, strong)NSString *rate;

@end

@implementation KDRedemptionManageController

- (void)viewDidLoad {
    [super viewDidLoad];
    _topHeight.constant = IPhoneXTopHeight;
    self.naviTitle = NSLocalizedString(@"提现管理", nil);
    [self setupRefresh];
    [self getData];
    
    UIButton *btn = [[ZFGlobleManager getGlobleManager] createRightBtn:@selector(redemptionRecord) view:self title:NSLocalizedString(@"申请记录", nil)];
    [self.view addSubview:btn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:@"withdraw_complete" object:nil];
}

#pragma mark - 点击方法
#pragma mark 申请提现
- (IBAction)applyRedemptionBtn:(id)sender {
    if (!_amount) {
        [self getData];
        return;
    }
    [self checkPW];
}

#pragma mark 支付设置
- (IBAction)paySettmentBtn:(id)sender {
    KDRMPayManageController *pmVC = [[KDRMPayManageController alloc] init];
    [self pushViewController:pmVC];
}

#pragma mark 明细查询
- (IBAction)detailQueryBtn:(id)sender {
    KDAgentTableViewController *atVC = [[KDAgentTableViewController alloc] init];
    atVC.tableType = 5;
    [self pushViewController:atVC];
}

#pragma mark 申请记录
- (void)redemptionRecord{
    KDAgentTableViewController *atVC = [[KDAgentTableViewController alloc] init];
    atVC.tableType = 6;
    [self pushViewController:atVC];
}

#pragma mark - 刷新
-(void)setupRefresh {
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getData];
    }];
    [KDTableViewUtil setHeaderWith:header];
    _scrollView.mj_header = header;
}

#pragma mark - 获取数据
- (void)getData{
    NSDictionary *dict = @{
                           @"currentLoginUser":[NSString stringWithFormat:@"%@%@", [ZFGlobleManager getGlobleManager].areaNum, [ZFGlobleManager getGlobleManager].userPhone],
                           TxnType:@"19"
                           };
    
    [NetworkEngine agentPostWithParams:dict success:^(id requestResult) {
        [self.scrollView.mj_header endRefreshing];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"00"]) {
            [[MBUtils sharedInstance] dismissMB];
            _amount = [requestResult objectForKey:@"accountAmt"];
            _rate = [requestResult objectForKey:@"paymentRate"];
            _amountL.text = [NSString stringWithFormat:@"%@ %.2f", @"¥", [_amount doubleValue]];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        [self.scrollView.mj_header endRefreshing];
    }];
}

- (void)checkPW{
    
    NSDictionary *dict = @{
                           @"currentLoginUser":[NSString stringWithFormat:@"%@%@", [ZFGlobleManager getGlobleManager].areaNum, [ZFGlobleManager getGlobleManager].userPhone],
                           TxnType:@"15"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine agentPostWithParams:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"00"]) {
            [[MBUtils sharedInstance] dismissMB];
            if ([[requestResult objectForKey:@"isSet"] isEqualToString:@"true"]) {
                KDRMAmountController *maVC = [[KDRMAmountController alloc] init];
                maVC.amount = [_amount doubleValue];
                maVC.rate = [_rate doubleValue];
                [self pushViewController:maVC];
            } else {
                KDRMGetCodeController *gcVC = [[KDRMGetCodeController alloc] init];
                [self pushViewController:gcVC];
            }
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

@end
