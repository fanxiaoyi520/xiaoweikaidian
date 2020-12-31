//
//  KDVoidDetailController.m
//  SinopayStore
//
//  Created by 中付支付 on 2017/12/15.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "KDVoidDetailController.h"

@interface KDVoidDetailController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITableView *tableView;
///信息标题
@property (nonatomic, strong)NSArray *titleArray;
///信息
@property (nonatomic, strong)NSMutableArray *contentArray;

@end

@implementation KDVoidDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"交易详情", nil);
    //撤销后的数组
    _titleArray = [NSArray arrayWithObjects:NSLocalizedString(@"交易类型", nil), NSLocalizedString(@"卡号", nil), NSLocalizedString(@"手机尾号", nil), NSLocalizedString(@"撤销金额", nil), NSLocalizedString(@"撤销时间", nil), NSLocalizedString(@"订单号", nil), NSLocalizedString(@"原订单号", nil), NSLocalizedString(@"原参考号", nil), nil];
    _contentArray = [[NSMutableArray alloc] init];
    
    [self setupTableView];
    [self getOrderDetail];
}


- (void)getOrderDetail{
    
    if ([_orderID isKindOfClass:[NSNull class]] || !_orderID) {
        return;
    }
    
    NSDictionary *dicts = @{@"countryCode":[ZFGlobleManager getGlobleManager].areaNum,
                            @"mobile":[ZFGlobleManager getGlobleManager].userPhone,
                            @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                            @"orderID":_orderID,
                            @"txnType":@"09"
                            };
    [[MBUtils sharedInstance] showMBWithText:@"" inView:self.view];
    [NetworkEngine singlePostWithParmas:dicts success:^(id requestResult) {
        
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] dismissMB];
            NSArray *arr = [NSArray arrayWithObjects:@"recMethod", @"cardNum", @"phoneTailNum", @"txnAmt", @"transTime", @"orderID", @"origOrderID", @"origSerialNumber", nil];
            NSDictionary *dict = [requestResult objectForKey:@"list"];
            for (NSInteger i = 0; i < arr.count; i++) {
                NSString *key = arr[i];
                NSString *value = [dict objectForKey:key];
                
                if ([value isKindOfClass:[NSNull class]] || !value) {
                    value = @"";
                }
                
                if (i == 3) {
                    if (value.length > 0) {//金额以分为单位
                        value = [NSString stringWithFormat:@"%.2f", [value doubleValue]/100];
                    }
                }
                if (i == 4) {
                    if (value.length == 14) {//调整时间格式
                        value = [self setDateFormatter:value];
                    }
                }
                [_contentArray addObject:value];
            }
        
            [_tableView reloadData];
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

- (NSString *)setDateFormatter:(NSString *)dateStr{
    NSString *resultStr = @"";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddHHmmss"];
    NSDate *date = [formatter dateFromString:dateStr];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    resultStr = [formatter stringFromDate:date];
    if (!resultStr) {
        resultStr = @"";
    }
    return resultStr;
}

// 设置tableView
- (void)setupTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = GrayBgColor;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.showsVerticalScrollIndicator =  NO;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

#pragma mark -- UITableViewDataSourece
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 6;
    } else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"orderCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.textColor = ZFAlpColor(0, 0, 0, 0.8);
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    NSInteger index = 0;
    if (indexPath.section == 0) {
        index = indexPath.row;
    } else {
        index = indexPath.row+6;
    }
    
    cell.textLabel.text = _titleArray[index];
    if (_contentArray.count > index) {
        cell.detailTextLabel.text = _contentArray[index];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return nil;
    }
    
    UIView *contentView = [UIView new];
    contentView.backgroundColor = [UIColor clearColor];
    contentView.frame = CGRectMake(20, 0, SCREEN_WIDTH, 44);
    
    UILabel *textLabel = [UILabel new];
    textLabel.x = 15;
    textLabel.y = 15;
    textLabel.text = NSLocalizedString(@"交易信息", nil);
    [textLabel sizeToFit];
    textLabel.textColor = [UIColor grayColor];
    textLabel.font = [UIFont systemFontOfSize:14.0];
    textLabel.textAlignment = NSTextAlignmentLeft;
    [contentView addSubview:textLabel];
    
    return contentView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 10;
    }
    return 44;
}


@end
