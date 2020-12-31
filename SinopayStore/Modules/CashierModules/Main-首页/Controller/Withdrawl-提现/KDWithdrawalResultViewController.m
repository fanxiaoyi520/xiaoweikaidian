//
//  KDWithdrawalResultViewController.m
//  SinopayStore
//
//  Created by Jellyfish on 2018/1/4.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDWithdrawalResultViewController.h"

@interface KDWithdrawalResultViewController () <UITableViewDataSource, UITableViewDelegate>

/** tableView */
@property(nonatomic, weak) UITableView *tableView;

@end

@implementation KDWithdrawalResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"交易详情", nil);
    // 返回需要刷新可提现金额
    [ZFGlobleManager getGlobleManager].isRWA = YES;
    
    [self initView];
}

#pragma mark - 初始化视图
- (void)initView {
    // 提示图片
    UIImageView *tipView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-100)/2, IPhoneXTopHeight+50, 100, 100)];
    tipView.image = [UIImage imageNamed:@"pic_success"];
    [self.view addSubview:tipView];
    
    // 提示文字
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tipView.frame)+20, SCREEN_WIDTH, 20)];
    tipLabel.font = [UIFont systemFontOfSize:17.0];
    tipLabel.text = NSLocalizedString(@"提现申请已提交", nil);
    tipLabel.textColor = MainThemeColor;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];
    
    //到账日期提醒
    UILabel *timeTipL = [[UILabel alloc] initWithFrame:CGRectMake(20, tipLabel.bottom+10, SCREEN_WIDTH-40, 35)];
    timeTipL.font = [UIFont systemFontOfSize:12];
    timeTipL.text = self.result.tips;
    timeTipL.alpha = 0.6;
    timeTipL.numberOfLines = 0;
    timeTipL.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:timeTipL];
    
    // tableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(timeTipL.frame)+20, SCREEN_WIDTH, 44*4) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.scrollEnabled = NO;
    tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

#pragma mark -- UITableViewDataSourece&UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DetailsCell"];
    
    NSArray *leftTitleArray = [NSArray arrayWithObjects:NSLocalizedString(@"提现金额", nil), NSLocalizedString(@"提现单号", nil), NSLocalizedString(@"收款银行卡", nil), NSLocalizedString(@"提现申请时间", nil), nil];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.textColor = ZFAlpColor(0, 0, 0, 0.8);
    cell.textLabel.text = leftTitleArray[indexPath.row];
    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
    cell.detailTextLabel.textColor = ZFAlpColor(0, 0, 0, 0.6);
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    if (indexPath.row == 0) {
        cell.detailTextLabel.text = self.result.drawAmt;
    } else if (indexPath.row == 1) {
        cell.detailTextLabel.text = self.result.drawNumber;
    } else if (indexPath.row == 2) {
        cell.detailTextLabel.text = self.result.cardNo;
    } else if (indexPath.row == 3) {
        cell.detailTextLabel.text = self.result.drawApplyTime;
    }
    
    return cell;
}


@end
