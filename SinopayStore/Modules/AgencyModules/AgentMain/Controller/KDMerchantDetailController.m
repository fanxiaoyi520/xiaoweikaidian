//
//  KDMerchantDetailController.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/4.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDMerchantDetailController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "KDTableViewUtil.h"

@interface KDMerchantDetailController ()<UITableViewDelegate, UITableViewDataSource>
/** tableView */
@property (nonatomic, weak) UITableView *tableView;

///信息标题
@property (nonatomic, strong)NSArray *titleArray;
///信息
@property (nonatomic, strong)NSMutableArray *contentArray;

///终端信息列表
@property (nonatomic, strong)NSArray *termList;

@end

@implementation KDMerchantDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.naviTitle = NSLocalizedString(@"商户详情", nil);
    _titleArray = @[                    
                    @[NSLocalizedString(@"商户编号", nil), NSLocalizedString(@"商户名称", nil), NSLocalizedString(@"注册办事处地址", nil), NSLocalizedString(@"手机", nil), NSLocalizedString(@"邮箱", nil)],
                    
                    @[@"UNION QR TID"]
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
    
    if (indexPath.section == 1) {//终端信息
        [cell addSubview:[self termView]];
        return cell;
    }

    cell.textLabel.text = _titleArray[indexPath.section][indexPath.row];
    if (_contentArray.count > indexPath.section) {
        cell.detailTextLabel.text = _contentArray[indexPath.section][indexPath.row];
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
    textLabel.text = NSLocalizedString(@"基本信息", nil);
    if (section == 2) {
        textLabel.text = NSLocalizedString(@"终端信息", nil);
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
    if (section == 1) {
        return 10;
    }
    return 44;
}

- (UIView *)termView{
    NSDictionary *dict = _termList[0];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    
    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 44)];
    titleL.font = [UIFont systemFontOfSize:14];
    titleL.text = @"UNION QR TID";
    titleL.textColor = [UIColor grayColor];
    [view addSubview:titleL];
    
    UILabel *termL = [[UILabel alloc] initWithFrame:CGRectMake(titleL.right+10, 0, 70, 44)];
    termL.font = [UIFont systemFontOfSize:14];
    termL.text = [dict objectForKey:@"termCode"];
    [view addSubview:termL];
    
    UIButton *downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    downBtn.frame = CGRectMake(termL.right, 0, SCREEN_WIDTH-20-termL.right, 44);
    downBtn.tag = 0;
    downBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    downBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    downBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [downBtn setTitle:NSLocalizedString(@"点击下载收款码", nil) forState:UIControlStateNormal];
    [downBtn setTitleColor:MainThemeColor forState:UIControlStateNormal];
    [downBtn addTarget:self action:@selector(downloadQrCode:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:downBtn];
    
    return view;
}

#pragma mark 下载图片
- (void)downloadQrCode:(UIButton *)btn{
    NSDictionary *dict = _termList[btn.tag];
    NSString *termImageUrl = [dict objectForKey:@"termImageUrl"];
    if ([termImageUrl isKindOfClass:[NSNull class]] || !termImageUrl) {
        return;
    }
    [[MBUtils sharedInstance] showMBInView:self.view];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL  URLWithString:termImageUrl]];
    UIImage *imageForSave = [UIImage imageWithData:data];
    if (!imageForSave) {
        [[MBUtils sharedInstance] showMBSuccessdWithText:NSLocalizedString(@"保存失败", nil) inView:self.view];
        return;
    }
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:[imageForSave CGImage] orientation:(ALAssetOrientation)[imageForSave imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
        if (error) {
            [[MBUtils sharedInstance] showMBSuccessdWithText:NSLocalizedString(@"保存失败", nil) inView:self.view];
        } else {
            [[MBUtils sharedInstance] showMBSuccessdWithText:NSLocalizedString(@"保存成功", nil) inView:self.view];
        }
    }];
}

#pragma mark - 获取数据
- (void)getData{
    if ([_merCode isKindOfClass:[NSNull class]] || !_merCode) {
        _merCode = @"";
    }
    
    NSArray *keyArray = @[
                          @[@"merCode", @"merName", @"merAddress", @"merPhone", @"email"]
                          
//                          @[@"termCode", @"termImageUrl"]
                          ];
    NSString *loginUser = [NSString stringWithFormat:@"%@%@", [ZFGlobleManager getGlobleManager].areaNum, [ZFGlobleManager getGlobleManager].userPhone];
    [[MBUtils sharedInstance] showMBInView:self.view];
    NSDictionary *dict = @{
                           @"userLoginName":loginUser,
                           @"merCode":_merCode,
                           @"reqType":@"25"
                           };
    [NetworkEngine merchantPostWithParams:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"rspCode"] isEqualToString:@"00"]) {
            [[MBUtils sharedInstance] dismissMB];
            NSDictionary *data = [requestResult objectForKey:@"merInfo"];
            _termList = [requestResult objectForKey:@"termList"];
            
            for (NSInteger i = 0; i < keyArray.count; i++) {
                NSArray *keyArr = keyArray[i];
                NSMutableArray *valueArray = [[NSMutableArray alloc] init];
                for (NSInteger j = 0; j < keyArr.count; j++) {
                    NSString *key = keyArr[j];
                    NSString *value = [data objectForKey:key];
                    if ([value isKindOfClass:[NSNull class]] || !value) {
                        value = @"";
                    }
                   
                    [valueArray addObject:value];
                }
                [self.contentArray addObject:valueArray];
            }
            
            if ([_termList isKindOfClass:[NSNull class]] || !_termList) {
                _termList = @[];
            }
            
            [self.tableView reloadData];
            
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"rspMsg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

@end
