//
//  KDCashierBankCardController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/1/3.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDCashierBankCardController.h"
#import "ZFBankCardCell.h"
#import "YYModel.h"
#import "KDAddCardNoViewController.h"

#define BANK_CARD_INFO [NSString stringWithFormat:@"cashier_bank_card%@", [ZFGlobleManager getGlobleManager].userPhone]

@interface KDCashierBankCardController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;
/** 银行卡模型 */
@property(nonatomic, strong) NSMutableArray<ZFBankCardModel *> *bankCardArray;

@end

@implementation KDCashierBankCardController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = GrayBgColor;
    self.naviTitle = NSLocalizedString(@"收款银行卡", nil);
    
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:BANK_CARD_INFO];
    self.bankCardArray = (NSMutableArray *)[NSArray yy_modelArrayWithClass:[ZFBankCardModel class] json:dic];
    
    [self createView];
    [self getCardInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([ZFGlobleManager getGlobleManager].isChanged) {
        [self getCardInfo];
    }
}

- (void)createView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = GrayBgColor;
    _tableView.scrollEnabled = NO;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:_tableView];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.bankCardArray.count == 0 ? 40 : 80;
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.bankCardArray.count == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.text = NSLocalizedString(@"添加银行卡", nil);
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    } else {
        ZFBankCardCell *cell = [ZFBankCardCell cellWithTableView:tableView];
        cell.model = self.bankCardArray[indexPath.row];
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.bankCardArray.count == 0) {
        KDAddCardNoViewController *vc = [[KDAddCardNoViewController alloc] init];
        [self pushViewController:vc];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    footerView.backgroundColor = GrayBgColor;
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, SCREEN_WIDTH-40, 30)];
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.text = NSLocalizedString(@"此预付卡仅用于收银员奖励金收取，暂只支持SINOPAY预付卡绑定。", nil);
    timeLabel.textColor = ZFAlpColor(0, 0, 0, 0.6);
    timeLabel.numberOfLines = 0;
    [footerView addSubview:timeLabel];
    return  footerView;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.bankCardArray.count == 0 ? NO : YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"删除", nil);
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"删除", nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSDictionary *dict = @{@"countryCode":[ZFGlobleManager getGlobleManager].areaNum,
                               @"mobile":[ZFGlobleManager getGlobleManager].userPhone,
                               @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                               @"cardId":self.bankCardArray[indexPath.row].cardId,
                               @"txnType":@"62"
                               };
        [[MBUtils sharedInstance] showMBInView:self.view];
        [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:BANK_CARD_INFO];
                [[MBUtils sharedInstance] showMBSuccessdWithText:NSLocalizedString(@"解绑成功", nil) inView:self.view];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AUTOTIPDISMISSTIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.bankCardArray removeObjectAtIndex:indexPath.row];
                    [tableView reloadData];
                });
            } else {
                [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            }
        } failure:^(id error) {

        }];
    }];
    
    return @[deleteAction];
}

- (void)getCardInfo{
    NSDictionary *dict = @{@"countryCode":[ZFGlobleManager getGlobleManager].areaNum,
                           @"mobile":[ZFGlobleManager getGlobleManager].userPhone,
                           @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                           @"cardType":@"0",
                           @"txnType":@"61"
                           };
    
    if (!self.bankCardArray.count) {
        [[MBUtils sharedInstance] showMBInView:self.view];
    }
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[NSUserDefaults standardUserDefaults] setObject:requestResult[@"list"] forKey:BANK_CARD_INFO];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [ZFGlobleManager getGlobleManager].isChanged = NO;
            self.bankCardArray = (NSMutableArray *)[NSArray yy_modelArrayWithClass:[ZFBankCardModel class] json:requestResult[@"list"]];
            [self.tableView reloadData];
        }
    } failure:^(id error) {
        
    }];
}

@end
