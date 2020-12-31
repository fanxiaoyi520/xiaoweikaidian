//
//  KDMerchantInfoViewController.m
//  SinopayStore
//
//  Created by Jellyfish on 2017/12/5.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "KDMerchantInfoViewController.h"

#define UserInfo [NSString stringWithFormat:@"userInfo%@", [ZFGlobleManager getGlobleManager].userPhone]


@interface KDMerchantInfoViewController () <UITableViewDataSource, UITableViewDelegate>

/** tableView */
@property (nonatomic, weak) UITableView *tableView;

/** 头部title数组 */
@property(nonatomic, strong) NSArray *headTitleArray;
///信息标题
@property (nonatomic, strong)NSArray *titleArray;
///信息
@property (nonatomic, strong)NSMutableArray *contentArray;


@end

@implementation KDMerchantInfoViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"商户资料", nil);
//    self.headTitleArray = [NSArray arrayWithObjects:NSLocalizedString(@"交易信息", nil), NSLocalizedString(@"签约费率", nil), NSLocalizedString(@"结算信息", nil), nil];
    self.headTitleArray = [NSArray arrayWithObjects:NSLocalizedString(@"交易信息", nil), NSLocalizedString(@"结算信息", nil), nil];
   
    NSInteger loginType = [[NSUserDefaults standardUserDefaults] integerForKey:@"loginTypeBtn"];
    if (loginType == 2) {//收银员商户去掉结算信息
        self.headTitleArray = [NSArray arrayWithObjects:NSLocalizedString(@"交易信息", nil), nil];
    }
    
    _titleArray = @[@[NSLocalizedString(@"所在国家", nil), NSLocalizedString(@"商家名称", nil), NSLocalizedString(@"店铺名称", nil), NSLocalizedString(@"商户编号", nil), NSLocalizedString(@"终端编号", nil), NSLocalizedString(@"联系人", nil), NSLocalizedString(@"联系电话", nil)],
                    @[NSLocalizedString(@"收益人姓名", nil), NSLocalizedString(@"银行名称", nil), NSLocalizedString(@"银行账号", nil), NSLocalizedString(@"分行号", nil)]];
    
    _contentArray = [[NSMutableArray alloc] init];
    
    [self setupTableView];
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:UserInfo];
    if (dict) {
        [self dealDataWithDict:dict];
    } else {
        [[MBUtils sharedInstance] showMBInView:self.view];
    }
    
    [self getUserInfo];
}

#pragma mark 获取数据
- (void)getUserInfo{
    NSDictionary *dict = @{@"countryCode":[ZFGlobleManager getGlobleManager].areaNum,
                           @"mobile":[ZFGlobleManager getGlobleManager].userPhone,
                           @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                           @"txnType":@"13"
                           };
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] dismissMB];
            [self dealDataWithDict:requestResult];
            
            [[NSUserDefaults standardUserDefaults] setObject:requestResult forKey:UserInfo];
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

- (void)dealDataWithDict:(NSDictionary *)requestResult{
    [_contentArray removeAllObjects];
//    NSArray *arr = [NSArray arrayWithObjects:@"country", @"merName", @"merShortName", @"merCode", @"termCode", @"contact", @"phoneNumber", @"upopContractRate", @"emvContractRate", @"accountName", @"bankName", @"cardNum", @"branchNum", nil];
    
    NSArray *arr = @[@[@"country", @"merName", @"merShortName", @"merCode", @"termCode", @"contact", @"phoneNumber"],
                     @[@"accountName", @"bankName", @"cardNum", @"branchNum"]];
    
    for (NSInteger i = 0; i < arr.count; i++) {
        NSArray *keys = arr[i];
        NSMutableArray *values = [[NSMutableArray alloc] init];
        for (NSInteger j = 0; j < keys.count; j++) {
            NSString *key = keys[j];
            NSString *value = [requestResult objectForKey:key];
            if ([value isKindOfClass:[NSNull class]] || !value) {
                value = @"";
            }
            [values addObject:value];
        }
        [_contentArray addObject:values];
    }
    
    [_tableView reloadData];
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
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

#pragma mark -- UITableViewDataSourece
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.headTitleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (!_contentArray.count) {
        return 0;
    }
    NSArray *arr = _contentArray[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"MYCELL";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.textColor = ZFAlpColor(0, 0, 0, 0.8);
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0];
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.textLabel.text = _titleArray[indexPath.section][indexPath.row];
    cell.detailTextLabel.text = _contentArray[indexPath.section][indexPath.row];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *contentView  = [UIView new];
    contentView.backgroundColor = [UIColor clearColor];
    contentView.frame = CGRectMake(20, 0, SCREEN_WIDTH, 44);
    
    UILabel *textLabel = [UILabel new];
    textLabel.x = 15;
    textLabel.y = 15;
    textLabel.text = self.headTitleArray[section];
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
    return 44;
}




@end
