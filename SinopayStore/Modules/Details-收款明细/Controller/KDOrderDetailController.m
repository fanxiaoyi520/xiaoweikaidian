//
//  KDOrderDetailController.m
//  SinopayStore
//
//  Created by 中付支付 on 2017/12/8.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "KDOrderDetailController.h"
#import "KDValidationPWController.h"
#import "KDReceiptsWebController.h"

@interface KDOrderDetailController ()<UITableViewDataSource, UITableViewDelegate>

/** tableView */
@property (nonatomic, weak) UITableView *tableView;

///信息标题
@property (nonatomic, strong)NSArray *titleArray;
///信息
@property (nonatomic, strong)NSMutableArray *contentArray;
///商户号 撤销时用
@property (nonatomic, strong)NSString *merCode;

///撤销标志 0 未撤销 1 已撤销
@property (nonatomic, strong)NSString *refundFlag;

@property (nonatomic, strong)UIButton *rightBtn;

@end

@implementation KDOrderDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.naviTitle = NSLocalizedString(@"交易详情", nil);
    
    _titleArray = [NSArray arrayWithObjects:NSLocalizedString(@"交易类型", nil), NSLocalizedString(@"卡号", nil), NSLocalizedString(@"交易金额", nil), NSLocalizedString(@"交易时间", nil), NSLocalizedString(@"订单号", nil), NSLocalizedString(@"参考号", nil), NSLocalizedString(@"POS号", nil), NSLocalizedString(@"手续费率", nil), NSLocalizedString(@"手续费", nil), NSLocalizedString(@"结算金额", nil), nil];//NSLocalizedString(@"手机尾号", nil),
    
    _contentArray = [[NSMutableArray alloc] init];
    [self createRightBtn];
    [self setupTableView];
    [self getOrderDetail];
}

- (void)createRightBtn{
    //结算按钮
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _rightBtn.frame = CGRectMake(SCREEN_WIDTH-120, IPhoneXStatusBarHeight, 110, IPhoneNaviHeight);
    [_rightBtn setTitle:NSLocalizedString(@"小票", nil) forState:UIControlStateNormal];
    [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _rightBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    _rightBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_rightBtn addTarget:self action:@selector(clickRightBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_rightBtn];
}

- (void)clickRightBtn{
    KDReceiptsWebController *rwVC = [[KDReceiptsWebController alloc] init];
    rwVC.orderID = _orderID;
    [self pushViewController:rwVC];
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
            NSArray *arr = [NSArray arrayWithObjects:@"recMethod", @"cardNum", @"txnAmt", @"transTime", @"orderID", @"serialNumber", @"counterCode", @"contractRate", @"serviceCharge", @"settAmt", nil];//@"phoneTailNum",
            NSDictionary *dict = [requestResult objectForKey:@"list"];
            for (NSInteger i = 0; i < arr.count; i++) {
                NSString *key = arr[i];
                NSString *value = [dict objectForKey:key];
                
                if ([value isKindOfClass:[NSNull class]] || !value) {
                    value = @"";
                }
                
                if (i == 2 || i == 8 || i == 9) {
                    if (value.length > 0) {//金额以分为单位
                        if (![value isEqualToString:@"-"]) {
                            value = [NSString stringWithFormat:@"%.2f", [value doubleValue]/100];
                        }
                    }
                }
                if (i == 3) {
                    if (value.length == 14) {//调整时间格式
                        value = [self setDateFormatter:value];
                    }
                }
                
                [_contentArray addObject:value];
            }
            
            _refundFlag = [dict objectForKey:@"refundFlag"];
            if ([_refundFlag isKindOfClass:[NSNull class]] || !_refundFlag) {
                _refundFlag = @"";
            }
            _merCode = [dict objectForKey:@"merCode"];
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
        return 7;
    } else {
        return 3;
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
        index = indexPath.row+7;
    }
    
    cell.textLabel.text = _titleArray[index];
    if (_contentArray.count > index) {
        cell.detailTextLabel.text = _contentArray[index];
    }
    
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *contentView = [UIView new];
    contentView.backgroundColor = [UIColor clearColor];
    contentView.frame = CGRectMake(20, 0, SCREEN_WIDTH, 44);
    
    UILabel *textLabel = [UILabel new];
    textLabel.x = 15;
    textLabel.y = 15;
    textLabel.text = NSLocalizedString(@"交易信息", nil);
    if (section == 1) {
        textLabel.text = NSLocalizedString(@"结算信息", nil);
    }
    [textLabel sizeToFit];
    textLabel.textColor = [UIColor grayColor];
    textLabel.font = [UIFont systemFontOfSize:14.0];
    textLabel.textAlignment = NSTextAlignmentLeft;
    
    [contentView addSubview:textLabel];
    
    return contentView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 1) {
        if (!_refundFlag) {
            return nil;
        }
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
        UIButton *revocationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        revocationBtn.frame = CGRectMake(20, 30, SCREEN_WIDTH-40, 40);
        revocationBtn.layer.cornerRadius = 5.0;
        [revocationBtn setTitle:NSLocalizedString(@"撤销", nil) forState:UIControlStateNormal];
        [revocationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        revocationBtn.backgroundColor = MainThemeColor;
        [revocationBtn addTarget:self action:@selector(revocationBtn) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:revocationBtn];
        if (![_refundFlag isEqualToString:@"0"]) {
            revocationBtn.enabled = NO;
            revocationBtn.alpha = 0.6;
            revocationBtn.backgroundColor = [UIColor grayColor];
            [revocationBtn setTitle:NSLocalizedString(@"已撤销", nil) forState:UIControlStateNormal];
        }
        
        return backView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 1) {
        CGFloat height = _refundFlag ? 100:0.1;
        return height;
    }
    return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

- (void)revocationBtn{
    if ([_orderID isKindOfClass:[NSNull class]] || !_orderID) {
        return;
    }
    if ([_merCode isKindOfClass:[NSNull class]] || !_merCode) {
        return;
    }
    
    [XLAlertController acWithTitle:NSLocalizedString(@"确认撤销此交易？", nil) msg:@"" confirmBtnTitle:NSLocalizedString(@"确定", nil) cancleBtnTitle:NSLocalizedString(@"取消", nil) confirmAction:^(UIAlertAction *action) {
        KDValidationPWController *vaVC = [[KDValidationPWController alloc] init];
        vaVC.orderID = _orderID;
        vaVC.merCode = _merCode;
        [self pushViewController:vaVC];
    }];
}

@end
