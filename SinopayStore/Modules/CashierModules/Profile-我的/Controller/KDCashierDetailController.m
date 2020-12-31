//
//  KDCashierDetailController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/1/3.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDCashierDetailController.h"

@interface KDCashierDetailController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSArray *dataArray;

@end

@implementation KDCashierDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"收银员资料", nil);
    [self createView];
    
    [self getUserInfo];
}

- (void)getUserInfo{
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"txnType": @"35",
                                 @"sessionID":[ZFGlobleManager getGlobleManager].sessionID};
//    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            if (![[requestResult objectForKey:@"merName"] isKindOfClass:[NSNull class]] && [requestResult objectForKey:@"merName"]) {
                [[NSUserDefaults standardUserDefaults] setObject:[requestResult objectForKey:@"merName"] forKey:CASHIER_MERCHANTS_NAME];
            }
            if (![[requestResult objectForKey:@"merId"] isKindOfClass:[NSNull class]] && [requestResult objectForKey:@"merId"]) {
                [[NSUserDefaults standardUserDefaults] setObject:[requestResult objectForKey:@"merId"] forKey:CASHIER_MERCHANTS_MERID];
            }
            [_tableView reloadData];
            
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)createView{
    _dataArray = [NSArray arrayWithObjects:NSLocalizedString(@"头像", nil), NSLocalizedString(@"所属商户", nil), NSLocalizedString(@"商户号", nil), NSLocalizedString(@"手机号", nil), nil];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = GrayBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:_tableView];
}

#pragma mark - tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 70;
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0 || section == 1) {
        return 20;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    if (indexPath.section == 0) {
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-90, 11, 48, 48)];
        imageView.layer.cornerRadius = imageView.width/2.0;
        imageView.clipsToBounds = YES;
        imageView.image = [ZFGlobleManager getGlobleManager].headImage;
        [cell addSubview:imageView];
    }
    cell.textLabel.text = _dataArray[indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    
    if (indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 3) {
        [cell addSubview:[self cellLabelWith:indexPath.section]];
    }
    
    return cell;
}

//右侧标签
- (UILabel *)cellLabelWith:(NSInteger)index{
    NSString *str = @"";
    if (index == 1) {
        str = [[NSUserDefaults standardUserDefaults] objectForKey:CASHIER_MERCHANTS_NAME];
    }
    if (index == 2) {
        str = [[NSUserDefaults standardUserDefaults] objectForKey:CASHIER_MERCHANTS_MERID];
    }
    if (index == 3) {
        str = [[ZFGlobleManager getGlobleManager].userPhone stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-230, 0, 200, 50)];
    label.textAlignment = NSTextAlignmentRight;
    label.textColor = [UIColor grayColor];
    label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    label.text = str;
    label.numberOfLines = 0;
//    label.adjustsFontSizeToFitWidth = YES;
    return label;
}

@end
