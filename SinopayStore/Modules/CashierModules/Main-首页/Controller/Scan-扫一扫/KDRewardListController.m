//
//  KDRewardListController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/3/1.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDRewardListController.h"
#import "KDRcwardListCell.h"
#import "KDRewardListModel.h"

@interface KDRewardListController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;
///领取按钮
@property (nonatomic, strong)UIButton *getBtn;
///完成按钮
@property (nonatomic, strong)UIButton *completeBtn;
///是否请求成功
@property (nonatomic, assign)BOOL isSuccess;
@end

@implementation KDRewardListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"奖励领取", nil);
    [self createView];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (_isSuccess) {
        [_dataArray removeAllObjects];
    }
}

#pragma mark -- 初始化视图
- (void)createView{
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight-50) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = GrayBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    _getBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _getBtn.frame = CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH, 50);
    _getBtn.backgroundColor = MainThemeColor;
    [_getBtn setTitle:NSLocalizedString(@"一键领取", nil) forState:UIControlStateNormal];
    [_getBtn addTarget:self action:@selector(getBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_getBtn];
    
    //右上角按钮
    _completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _completeBtn.frame = CGRectMake(SCREEN_WIDTH-130, IPhoneXStatusBarHeight, 110, IPhoneNaviHeight);
    _completeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _completeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_completeBtn setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
    [_completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_completeBtn addTarget:self action:@selector(completeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    _completeBtn.hidden = YES;
    [self.view addSubview:_completeBtn];
}

- (void)getBtnClick{
    DLog(@"getbtn");
    
    NSString *bonusIdStr = @"";
    for (NSInteger i = 0; i < _dataArray.count; i++) {
        KDRewardListModel *model = _dataArray[i];
        NSString *bounsId = model.bonusId;
        if ([bounsId isKindOfClass:[NSNull class]]) {//判空
            bounsId = @"";
        }
        if (i == 0) {
            bonusIdStr = bounsId;
        } else {
            bonusIdStr = [bonusIdStr stringByAppendingString:[NSString stringWithFormat:@",%@", bounsId]];
        }
    }
    
    NSDictionary *parameters = @{
                                 @"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                                 @"bonusIdList":bonusIdStr,
                                 @"txnType": @"58",
                                 };
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [_dataArray removeAllObjects];
            _isSuccess = YES;
            NSDictionary *bonusRecordList = [requestResult objectForKey:@"bonusRecordList"];
            for (NSDictionary *dict in bonusRecordList) {
                KDRewardListModel *model = [[KDRewardListModel alloc] init];
                [model setValuesForKeysWithDictionary:dict];
                [_dataArray addObject:model];
            }
            _tableView.size = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight);
            _getBtn.hidden = YES;
            _completeBtn.hidden = NO;
            [_tableView reloadData];
            
            // 返回需要刷新可提现金额
            [ZFGlobleManager getGlobleManager].isRWA = YES;
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(NSError *error) {
        
    }];
}

//完成
- (void)completeBtnClick{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"rewardlist";
    KDRcwardListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[KDRcwardListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    KDRewardListModel *model = _dataArray[indexPath.row];
    cell.model = model;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 165;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

// 设置分割线偏移
//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
//        [cell setSeparatorInset:UIEdgeInsetsZero];
//    }
//}

@end
