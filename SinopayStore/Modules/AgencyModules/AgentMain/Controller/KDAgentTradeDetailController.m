//
//  KDAgentTradeDetailController.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/4.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDAgentTradeDetailController.h"
#import "KDTableViewUtil.h"

@interface KDAgentTradeDetailController ()<UITableViewDelegate, UITableViewDataSource>
/** tableView */
@property (nonatomic, weak) UITableView *tableView;

///信息标题
@property (nonatomic, strong)NSArray *titleArray;
///信息
@property (nonatomic, strong)NSMutableArray *contentArray;

@end

@implementation KDAgentTradeDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"交易详情", nil);
    _titleArray = @[
                    @[NSLocalizedString(@"订单号", nil), NSLocalizedString(@"交易参考号", nil), NSLocalizedString(@"交易时间", nil), NSLocalizedString(@"交易金额", nil), NSLocalizedString(@"交易币种", nil), NSLocalizedString(@"交易类型", nil), NSLocalizedString(@"交易卡号", nil), NSLocalizedString(@"交易状态", nil)],
                    
                    @[NSLocalizedString(@"商户名", nil), NSLocalizedString(@"商户号", nil), NSLocalizedString(@"终端号", nil)]
                    ];
    
    _contentArray = [[NSMutableArray alloc] init];
    [self setupTableView];
    [self getData];
}

- (void)setupTableView {
    UITableView *tableView = [KDTableViewUtil getTableViewWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight) vc:self];
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

#pragma mark -- UITableViewDataSourece
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _titleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_titleArray[section] count];
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
    
    cell.textLabel.text = _titleArray[indexPath.section][indexPath.row];
    if (_contentArray.count > indexPath.section) {
        cell.detailTextLabel.text = _contentArray[indexPath.section][indexPath.row];
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
        textLabel.text = NSLocalizedString(@"商户信息", nil);
    }
    [textLabel sizeToFit];
    textLabel.textColor = [UIColor grayColor];
    textLabel.font = [UIFont systemFontOfSize:14.0];
    textLabel.textAlignment = NSTextAlignmentLeft;
    
    [contentView addSubview:textLabel];
    
    return contentView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

#pragma mark - 获取数据
- (void)getData{
    if ([_orderNum isKindOfClass:[NSNull class]] || !_orderNum) {
        _orderNum = @"";
    }
    
    NSArray *keyArray = @[
                          @[@"orderNum", @"referNo", @"transDate", @"txnAmt", @"transCurr", @"transType", @"cardNo", @"respCode"],
                          
                          @[@"merName", @"merCode", @"termCode"]
                          ];
    NSDictionary *dict = @{
                           @"orderNum":_orderNum,
                           TxnType:@"14"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine agentPostWithParams:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"00"]) {
            [[MBUtils sharedInstance] dismissMB];
            
            NSDictionary *data = [requestResult objectForKey:@"transInfo"];
            for (NSInteger i = 0; i < keyArray.count; i++) {
                NSArray *keyArr = keyArray[i];
                NSMutableArray *valueArray = [[NSMutableArray alloc] init];
                for (NSInteger j = 0; j < keyArr.count; j++) {
                    NSString *key = keyArr[j];
                    NSString *value = [NSString stringWithFormat:@"%@", [data objectForKey:key]];
                    if ([value isKindOfClass:[NSNull class]] || !value) {
                        value = @"";
                    }
                    if ([key isEqualToString:@"transCurr"]) {
                        value = [self getCurrWith:value];
                    }
                    if ([key isEqualToString:@"transType"]) {
                        NSString *transCode = [data objectForKey:@"transCode"];
                        NSString *transTypeStr = NSLocalizedString(@"消费", nil);//PER、01 消费
                        if ([transCode isEqualToString:@"PVR"] || [transCode isEqualToString:@"31"]) {
                            transTypeStr = NSLocalizedString(@"撤销", nil);
                        }
                        if ([transCode isEqualToString:@"CTH"]) {
                            transTypeStr = NSLocalizedString(@"退货", nil);
                        }
                        NSString *srveniryMode = [data objectForKey:@"srveniryMode"];
                        NSString *emvStr = @"POS";
                        //03、03、93、94是emv 其他是pos
                        if ([srveniryMode hasPrefix:@"03"] || [srveniryMode hasPrefix:@"04"] || [srveniryMode hasPrefix:@"93"] || [srveniryMode hasPrefix:@"94"]) {
                            emvStr = @"EMV";
                        }
                        
                        value = [NSString stringWithFormat:@"%@-%@", emvStr, transTypeStr];
                    }
                    if ([key isEqualToString:@"cardNo"]) {//卡号脱敏
                        value = [self hidePrivacyString:value fore:6 aft:4];
                    }
                    if ([key isEqualToString:@"respCode"]) {
                        NSString *str = NSLocalizedString(@"成功", nil);
                        if (![value isEqualToString:@"00"]) {
                            str = NSLocalizedString(@"失败", nil);
                        }
                        value = [NSString stringWithFormat:@"%@-%@", value, str];
                    }
                    [valueArray addObject:value];
                }
                [self.contentArray addObject:valueArray];
            }
        
            [self.tableView reloadData];
            
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

- (NSString *)getCurrWith:(NSString *)curr{
    NSArray *array = @[@"344-HKD", @"156-RMB", @"458-MYR", @"702-SGD"];
    NSString *result = curr;
    for (NSString *str in array) {
        if ([str containsString:curr]) {
            result = str;
            break;
        }
    }
    
    return result;
}

#pragma mark - 脱敏
- (NSString *)hidePrivacyString:(NSString *)string fore:(NSInteger)fore aft:(NSInteger)aft{
    NSString *newStr = @"";
    if ([string isKindOfClass:[NSNull class]] || !string) {
        return @"";
    }
    NSInteger hideLenth = string.length-fore-aft;
    if (hideLenth <= 0) {
        return string;
    }
    NSRange range = {fore, hideLenth};
    NSString *star = @"";
    for (NSInteger i = 0; i < hideLenth; i++) {
        star = [star stringByAppendingString:@"*"];
    }
    newStr = [string stringByReplacingCharactersInRange:range withString:star];
    
    return newStr;
}

@end
