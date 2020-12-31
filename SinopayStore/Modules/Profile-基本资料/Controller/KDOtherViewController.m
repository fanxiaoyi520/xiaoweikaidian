//
//  KDOtherViewController.m
//  SinopayStore
//
//  Created by 中付支付 on 2017/12/6.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "JPUSHService.h"

#import "KDOtherViewController.h"
#import "ZFNavigationController.h"
#import "DateUtils.h"

@interface KDOtherViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSArray *dataArray;

///热线
@property (nonatomic, strong)NSString *hotLine;

@end

@implementation KDOtherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"其他", nil);
    
    _hotLine = [[NSUserDefaults standardUserDefaults] objectForKey:@"ylkd_hot_line"];
    [self createView];
    [self getHotLine];
}

- (void)getHotLine{
    NSDictionary *dict = @{@"countryCode":[ZFGlobleManager getGlobleManager].areaNum,
                           @"mobile":[ZFGlobleManager getGlobleManager].userPhone,
                           @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                           @"txnType":@"16"
                           };
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] dismissMB];
            _hotLine = [NSString stringWithFormat:@"%@", [requestResult objectForKey:@"hotLine"]];
            [[NSUserDefaults standardUserDefaults] setObject:_hotLine forKey:@"ylkd_hot_line"];
            [_tableView reloadData];
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

- (void)createView{
    _dataArray = [NSArray arrayWithObjects:NSLocalizedString(@"给我们评分", nil), NSLocalizedString(@"商家热线", nil), NSLocalizedString(@"退出登录", nil), nil];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.scrollEnabled = NO;
    [self.view addSubview:_tableView];
}

#pragma mark table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 180;
    }
    if (section == 2) {
        return 20;
    }
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"otherCell"];
    cell.textLabel.text = _dataArray[indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.section == 1) {
        UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-200, 0, 180, 50)];
        phoneLabel.font = [UIFont systemFontOfSize:15];
        phoneLabel.textColor = UIColorFromRGB(0x000000);
        phoneLabel.alpha = 0.6;
        phoneLabel.textAlignment = NSTextAlignmentRight;
        phoneLabel.text = _hotLine;
        [cell addSubview:phoneLabel];
    }
    if (indexPath.section == 2) {
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = UIColorFromRGB(0xD73246);
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section != 0) {
        return nil;
    }
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 180)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
    imageView.center = CGPointMake(SCREEN_WIDTH/2, 40+32);
    imageView.image = [UIImage imageNamed:@"icon_other_logo_chinese"];
    [headView addSubview:imageView];
    
    UILabel *nameLable = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.bottom+10, SCREEN_WIDTH, 16)];
    nameLable.textAlignment = NSTextAlignmentCenter;
    nameLable.text = NSLocalizedString(@"小微开店", nil);
    nameLable.font = [UIFont systemFontOfSize:15];
    [headView addSubview:nameLable];
    
    NSString *verson = [NSString stringWithFormat:@"V %@", [[ZFGlobleManager getGlobleManager] getCurrentVersion]];
    UILabel *versonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, nameLable.bottom+10, SCREEN_WIDTH, 14)];
    versonLabel.textAlignment = NSTextAlignmentCenter;
    versonLabel.text = verson;
    versonLabel.textColor = UIColorFromRGB(0x313131);
    versonLabel.font = [UIFont systemFontOfSize:12];
    [headView addSubview:versonLabel];
    
    return headView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cell.userInteractionEnabled = YES;
    });
    DLog(@"----");
    if (indexPath.section == 0) {
        NSString *urlStr = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@&pageNumber=0&sortOrdering=2&mt=8", appstore_appid];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    }
    if (indexPath.section == 1) {
        NSString  *num = _hotLine;
        if (![num isKindOfClass:[NSNull class]] && num.length > 1) {
            num = [num stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSString *phoneNum = [[NSString alloc] initWithFormat:@"telprompt://%@", num];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNum]]; //拨号
        }
    }
    if (indexPath.section == 2) {
        [self exitLogin];
    }
}

//退出登录
- (void)exitLogin{
    [XLAlertController acWithTitle:NSLocalizedString(@"退出登录", nil) msg:nil confirmBtnTitle:NSLocalizedString(@"确定", nil) cancleBtnTitle:NSLocalizedString(@"取消", nil) confirmAction:^(UIAlertAction *action) {
//        [self sendEmail];
        [self logout];
    }];
}

- (void)sendEmail{
    if ([[ZFGlobleManager getGlobleManager].email isKindOfClass:[NSNull class]] || [ZFGlobleManager getGlobleManager].email.length < 1) {
        [self logout];
        return;
    }
    
    NSString *merIdAndTime = [NSString stringWithFormat:@"%@%@%@", [ZFGlobleManager getGlobleManager].merID, [DateUtils getCurrentDateWithFormat:@"YYYYMMddHHmmss"], [ZFGlobleManager getGlobleManager].termCode];
    
    NSDictionary *dicts = @{@"countryCode":[ZFGlobleManager getGlobleManager].areaNum,
                            @"mobile":[ZFGlobleManager getGlobleManager].userPhone,
                            @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                            @"email":[ZFGlobleManager getGlobleManager].email,
                            @"merIdAndDate":merIdAndTime,
                            @"txnType":@"63"
                            };
    [[MBUtils sharedInstance] showMBWithText:@"" inView:self.view];
    [NetworkEngine singlePostWithParmas:dicts success:^(id requestResult) {
        [self logout];
        
//        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
//
//        } else {
//            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
//        }
    } failure:^(id error) {
        
    }];
}

#pragma mark 退出登录
- (void)logout{
    NSDictionary *dict = @{@"countryCode":[ZFGlobleManager getGlobleManager].areaNum,
                           @"mobile":[ZFGlobleManager getGlobleManager].userPhone,
                           @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                           @"txnType":@"03"
                           };
    [[MBUtils sharedInstance] showMBWithText:NSLocalizedString(@"正在退出...", nil) inView:self.view];
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            //清空密码
            [ZFGlobleManager getGlobleManager].loginVC.pwdTextField.text = @"";
            [[ZFGlobleManager getGlobleManager] saveLoginPwd:@""];
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            window.rootViewController = [[ZFNavigationController alloc] initWithRootViewController:[ZFGlobleManager getGlobleManager].loginVC];
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

@end
