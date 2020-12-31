//
//  KDAgentTableViewController.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/4/10.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDAgentTableViewController.h"
#import "KDMerchantListCell.h"
#import "KDAgentListCell.h"
#import "KDAgentTradeListCell.h"
#import "KDAgentBenefitCell.h"
#import "KDFenrunDetailCell.h"
#import "KDRMBalanceCell.h"
#import "KDRedemptionListCell.h"
#import "UIScrollView+EmptyDataSet.h"
#import "KDTableViewUtil.h"
#import "KDFilterView.h"
#import "DateUtils.h"
#import "ZFPickerView.h"
#import "KDMerchantDetailController.h"
#import "KDAgentTradeDetailController.h"
#import "KDRMBalanceDetailController.h"
#import "KDRedemptionDetailController.h"


@interface KDAgentTableViewController ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, KDBenefitCellDelegate, ZFPickerViewDelegate>
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, assign)NSInteger currentPage;

@property (nonatomic, strong)KDFilterView *filterView;
@property (nonatomic, strong)NSString *beginTime;
@property (nonatomic, strong)NSString *endTime;
@property (nonatomic, strong)NSString *searchStr;

///操作类型
@property (nonatomic, strong)ZFPickerView *typePicker;
@property (nonatomic, strong)NSArray *typeArray;
@property (nonatomic, strong)NSArray *typeCodeArray;
@property (nonatomic, strong)NSString *operateType;

///总笔数
@property (nonatomic, strong)UILabel *totalSizeL;
///总金额
@property (nonatomic, strong)UILabel *totalAmtL;

@end

@implementation KDAgentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavTitle];
    
    _dataArray = [[NSMutableArray alloc] init];
    [self createView];
    _currentPage = 1;
    _searchStr = @"";
    NSDate *monthAgo = [NSDate dateWithTimeInterval:-24*60*60*31 sinceDate:[NSDate date]];
    _beginTime = [DateUtils dateToStringWithFormatter:@"yyyy-MM-dd" date:monthAgo];
    _endTime = [DateUtils dateToStringWithFormatter:@"yyyy-MM-dd" date:[NSDate date]];
    [self.tableView.mj_header beginRefreshing];
}

- (void)setupNavTitle{
    if (_tableType == 1) {
        self.naviTitle = NSLocalizedString(@"代理列表", nil);
    } else if (_tableType == 2) {
        self.naviTitle = NSLocalizedString(@"交易查询", nil);
    } else if (_tableType == 3) {
        self.naviTitle = NSLocalizedString(@"分润查询", nil);
    } else if (_tableType == 4) {
        self.naviTitle = NSLocalizedString(@"分润查询", nil);
    } else if (_tableType == 5) {
        self.naviTitle = NSLocalizedString(@"余额明细", nil);
    } else if (_tableType == 6) {
        self.naviTitle = NSLocalizedString(@"申请记录", nil);
    } else {
        self.naviTitle = NSLocalizedString(@"商户列表", nil);
    }
}

- (void)createView{
    CGRect tableFrame = CGRectMake(0, IPhoneXTopHeight+120, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight-120);
    
    if (_tableType == 1) {
        tableFrame = CGRectMake(0, IPhoneXTopHeight+120, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight-120);
    }
    
    if (_tableType == 2) {
        [self createOtherView];
        tableFrame = CGRectMake(0, IPhoneXTopHeight+160, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight-160);
    }
    
    if (_tableType == 3) {
        tableFrame = CGRectMake(0, IPhoneXTopHeight+70, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight-70);
    }
    
    if (_tableType == 4) {
        tableFrame = CGRectMake(0, IPhoneXTopHeight+50, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight-50);
    }
    
    if (_tableType == 5 || _tableType == 6) {
        UIButton *btn = [[ZFGlobleManager getGlobleManager] createRightBtn:@selector(showPicker) view:self title:NSLocalizedString(@"筛选", nil)];
        [self.view addSubview:btn];
        
        tableFrame = CGRectMake(0, IPhoneXTopHeight+70, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight-70);
    }
    
    _tableView = [KDTableViewUtil getTableViewWithFrame:tableFrame vc:self];
    [self.view addSubview:_tableView];
    [KDTableViewUtil setTableView:_tableView header:^{
        _currentPage = 1;
        [self getData];
    } footer:^{
        [self getData];
    }];
    
    [self createFilterView];
}

- (void)createFilterView{
    __weak typeof(self) weakSelf = self;
    _filterView = [[KDFilterView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, 120)];
    
    if (_tableType == 0) {
        _filterView.myFrame = CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, 120);
        _filterView.placeholder = NSLocalizedString(@"可输入商户号进行查询", nil);
    } else if (_tableType == 1) {
        _filterView.myFrame = CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, 120);
    } else if (_tableType == 2) {
        _filterView.myFrame = CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, 120);
        _filterView.placeholder = NSLocalizedString(@"可输入交易卡号进行查询", nil);
    } else if (_tableType == 3) {
        _filterView.myFrame = CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, 70);
        _filterView.filterType = 1;
    } else if (_tableType == 4) {
        _filterView.myFrame = CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, 50);
        _filterView.filterType = 2;
        if ([[_infoDict objectForKey:@"xiajiType"] isEqualToString:@"MERCHANTS"]) {
            _filterView.placeholder = NSLocalizedString(@"可输入商户号进行查询", nil);
        }
    } else if (_tableType == 5 || _tableType == 6) {
        _filterView.myFrame = CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, 70);
        _filterView.filterType = 1;
        [self createOperatePicker];
    }
    
    _filterView.block = ^(NSString *searchText, NSString *beginTime, NSString *endTime) {
        _searchStr = searchText;
        if (!searchText) {
            _searchStr = @"";
        }
        _beginTime = beginTime;
        _endTime = endTime;
        _currentPage = 1;
        [weakSelf.tableView.mj_header beginRefreshing];
    };
    [self.view addSubview:_filterView];
}

- (void)createOtherView{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight+120, SCREEN_WIDTH, 40)];
    [self.view addSubview:topView];
    
    UILabel *totalL = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 40)];
    totalL.font = [UIFont systemFontOfSize:15];
    totalL.text = @"成功交易笔数:";
    [topView addSubview:totalL];
    
    _totalSizeL = [[UILabel alloc] initWithFrame:CGRectMake(totalL.right, 0, 50, totalL.height)];
    _totalSizeL.font = [UIFont systemFontOfSize:15];
    _totalSizeL.text = @"0";
    _totalSizeL.textColor = [UIColor redColor];
    [topView addSubview:_totalSizeL];
    
    UILabel *amtL = [[UILabel alloc] initWithFrame:CGRectMake(_totalSizeL.right, 0, 80, totalL.height)];
    amtL.font = [UIFont systemFontOfSize:15];
    amtL.text = @"交易金额:";
    [topView addSubview:amtL];
    
    _totalAmtL = [[UILabel alloc] initWithFrame:CGRectMake(amtL.right, 0, 80, totalL.height)];
    _totalAmtL.font = [UIFont systemFontOfSize:15];
    _totalAmtL.text = @"0.00";
    _totalAmtL.textColor = [UIColor redColor];
    [topView addSubview:_totalAmtL];
}

- (void)createOperatePicker{
    _operateType = @"";
    _typeArray = @[@"全部", @"提现", @"分润"];
    _typeCodeArray = @[@"", @"WITHDARW", @"FENRUN"];
    
    if (_tableType == 6) {
        _typeArray = @[@"全部", @"提现成功", @"提现审核成功", @"提现等待审核", @"提现审核失败", @"出帐失败"];
        _typeCodeArray = @[@"", @"WTIHDARW_SUCCESS", @"WTIHDARW_AUDTI_SUCCESS", @"WTIHDARW_WAIT_AUDTI", @"WTIHDARW_AUDTI_FAILED", @"WTIHDARW_SETTLE_FAILED"];
    }
    
    _typePicker = [[ZFPickerView alloc] init];
    _typePicker.delegate = self;
    _typePicker.dataArray = _typeArray;
    [self.view addSubview:_typePicker];
}

- (void)showPicker{
    [_typePicker show];
}

#pragma mark - tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_tableType == 1) {
        return 140;
    } else if (_tableType == 2) {
        return 140;
    } else if (_tableType == 3) {
        return 210;
    } else if (_tableType == 4) {
        return 160;
    } else if (_tableType == 5) {
        return 75;
    } else {
        return 110;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row >= _dataArray.count) {
        return nil;
    }
    if (_tableType == 1) {
        KDAgentListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"agentListCell"];
        if (!cell) {
            cell = (KDAgentListCell *)[[[NSBundle mainBundle] loadNibNamed:@"KDAgentListCell" owner:self options:nil] firstObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.model = _dataArray[indexPath.row];
        
        return cell;
    } else if (_tableType == 2) {
        KDAgentTradeListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KDAgentTradeListCell"];
        if (!cell) {
            cell = (KDAgentTradeListCell *)[[[NSBundle mainBundle] loadNibNamed:@"KDAgentTradeListCell" owner:self options:nil] firstObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.model = _dataArray[indexPath.row];
        
        return cell;
    } else if (_tableType == 3) {
        KDAgentBenefitCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AgentBenefitCell"];
        if (!cell) {
            cell = (KDAgentBenefitCell *)[[[NSBundle mainBundle] loadNibNamed:@"KDAgentBenefitCell" owner:self options:nil] firstObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;
        cell.model = _dataArray[indexPath.row];
        
        return cell;
    } else if (_tableType == 4) {
        KDFenrunDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fenrunDetailCell"];
        if (!cell) {
            cell = (KDFenrunDetailCell *)[[[NSBundle mainBundle] loadNibNamed:@"KDFenrunDetailCell" owner:self options:nil] firstObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.model = _dataArray[indexPath.row];
        
        return cell;
    } else if (_tableType == 5) {
        KDRMBalanceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KDRMBalanceCell"];
        if (!cell) {
            cell = (KDRMBalanceCell *)[[[NSBundle mainBundle] loadNibNamed:@"KDRMBalanceCell" owner:self options:nil] firstObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.model = _dataArray[indexPath.row];
        
        return cell;
    } else if (_tableType == 6) {
        KDRedemptionListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KDRedemptionListCell"];
        if (!cell) {
            cell = (KDRedemptionListCell *)[[[NSBundle mainBundle] loadNibNamed:@"KDRedemptionListCell" owner:self options:nil] firstObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.model = _dataArray[indexPath.row];
        
        return cell;
    } else {
        KDMerchantListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KDMerchantListCell"];
        if (!cell) {
            cell = (KDMerchantListCell *)[[[NSBundle mainBundle] loadNibNamed:@"KDMerchantListCell" owner:self options:nil] firstObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.model = _dataArray[indexPath.row];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < _dataArray.count) {
        if (_tableType == 0) {
            KDAgentMerModel *model = _dataArray[indexPath.row];
            KDMerchantDetailController *dVC = [[KDMerchantDetailController alloc] init];
            dVC.merCode = model.merCode;
            [self pushViewController:dVC];
            
        }
        if (_tableType == 2) {
            KDAgentTradeModel *model = _dataArray[indexPath.row];
            KDAgentTradeDetailController *dVC = [[KDAgentTradeDetailController alloc] init];
            dVC.orderNum = model.orderNum;
            [self pushViewController:dVC];
            
        }
        
        if (_tableType == 5) {
            KDRMBalanceModel *model = _dataArray[indexPath.row];
            KDRMBalanceDetailController *bdVC = [[KDRMBalanceDetailController alloc] init];
            bdVC.model = model;
            [self pushViewController:bdVC];
            
        }
        
        if (_tableType == 6) {
            KDRedemptionModel *model = _dataArray[indexPath.row];
            KDRedemptionDetailController *rdVC = [[KDRedemptionDetailController alloc] init];
            rdVC.orderNum = model.orderNum;
            [self pushViewController:rdVC];
        }
    }
}

#pragma mark - tableviewEmptydelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView{
    return [UIImage imageNamed:@"pic_nodata"];
}
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"暂无相关数据", nil) attributes:attributes];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView{
    if (_tableType == 2 || _tableType == 5 || _tableType == 6) {
        return -80;
    }
    return -100;
}

#pragma mark - pickerDelegate
- (void)selectZFPickerViewTag:(NSInteger)tag index:(NSInteger)index{
    _operateType = _typeCodeArray[index];
    [_tableView.mj_header beginRefreshing];
}

- (void)benefitClickType:(NSString *)type dict:(NSDictionary *)dict{
    KDAgentTableViewController *atVC = [[KDAgentTableViewController alloc] init];
    atVC.tableType = 4;
    atVC.infoDict = dict;
    [self pushViewController:atVC];
}

#pragma mark 获取数据
- (void)getData{
    NSString *loginUser = [NSString stringWithFormat:@"%@%@", [ZFGlobleManager getGlobleManager].areaNum, [ZFGlobleManager getGlobleManager].userPhone];
    
    NSDictionary *dict = @{
                           @"userLoginName":loginUser,
                           @"startDate":[_beginTime stringByReplacingOccurrencesOfString:@"-" withString:@""],
                           @"endDate":[_endTime stringByReplacingOccurrencesOfString:@"-" withString:@""],
                           @"merCode":_searchStr,
                           @"merName":@"",
                           @"pageNum":[NSString stringWithFormat:@"%zd", _currentPage],
                           @"pageSize":@"10",
                           @"reqType":@"24"
                           };
    if (_tableType == 1) {
        dict = @{
                 @"currentLoginUser":loginUser,
                 @"xiaJiAccount":_searchStr,
                 @"startTime":_beginTime,
                 @"endTime":_endTime,
                 @"pageNum":[NSString stringWithFormat:@"%zd", _currentPage],
                 TxnType:@"12"
                 };
    }
    
    if (_tableType == 2) {
        dict = @{
                 @"currentLoginUser":loginUser,
                 @"startDate":_beginTime,
                 @"endDate":_endTime,
                 @"pageNum":[NSString stringWithFormat:@"%zd", _currentPage],
                 @"cardNo":_searchStr,
                 TxnType:@"13"
                 };
    }
    
    if (_tableType == 3) {
        dict = @{
                 @"currentLoginUser":loginUser,
                 @"startTime":_beginTime,
                 @"endTime":_endTime,
                 @"pageNum":[NSString stringWithFormat:@"%zd", _currentPage],
                 TxnType:@"10"
                 };
    }
    
    if (_tableType == 4) {
        NSString *xiajiType = @"";
        NSString *xiajiAccount = @"";
        NSString *fenrunDate = @"";
        if (_infoDict) {
            xiajiType = [_infoDict objectForKey:@"xiajiType"];
            xiajiAccount = [_infoDict objectForKey:@"xiajiAccount"];
            fenrunDate = [_infoDict objectForKey:@"fenrunTime"];
            if (fenrunDate.length >= 8) {
                fenrunDate = [[fenrunDate componentsSeparatedByString:@" "] firstObject];
            }
        } else {
            [self->_tableView.mj_header endRefreshing];
            [self->_tableView.mj_footer endRefreshing];
            self.tableView.emptyDataSetSource = self;
            self.tableView.emptyDataSetDelegate = self;
            [_tableView reloadData];
            return;
        }
        if (_searchStr.length > 0) {
            xiajiAccount = _searchStr;
        }
        
        dict = @{
                 @"currentLoginUser":loginUser,
                 @"xiaJiType":xiajiType,
                 @"xiaJiAccount":xiajiAccount,
                 @"fenrunDate":fenrunDate,
                 @"pageNum":[NSString stringWithFormat:@"%zd", _currentPage],
                 TxnType:@"11"
                 };
    }
    
    if (_tableType == 5) {
        dict = @{
                 @"currentLoginUser":loginUser,
                 @"startDate":[_beginTime stringByAppendingString:@" 00:00:00"],
                 @"endDate":[_endTime stringByAppendingString:@" 23:59:59"],
                 @"pageNum":[NSString stringWithFormat:@"%zd", _currentPage],
                 @"operateType":_operateType,
                 TxnType:@"25"
                 };
    }
    
    if (_tableType == 6) {
        dict = @{
                 @"currentLoginUser":loginUser,
                 @"startDate":[_beginTime stringByAppendingString:@" 00:00:00"],
                 @"endDate":[_endTime stringByAppendingString:@" 23:59:59"],
                 @"pageNum":[NSString stringWithFormat:@"%zd", _currentPage],
                 @"withdarwState":_operateType,
                 TxnType:@"23"
                 };
    }
    
    [self requestWith:dict];
}

- (void)requestWith:(NSDictionary *)dict{
    if (_tableType != 0) {
        [NetworkEngine agentPostWithParams:dict success:^(id requestResult) {
           [self endRefresh];
            
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"00"]) {
                [self dealDataWith:requestResult];
            } else {
                [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"rspMsg"] inView:self.view];
            }
        } failure:^(id error) {
            [self endRefresh];
        }];
    } else {
        
        [NetworkEngine merchantPostWithParams:dict success:^(id requestResult) {
            [self endRefresh];
           
            if ([[requestResult objectForKey:@"rspCode"] isEqualToString:@"00"]) {
                [self dealDataWith:requestResult];
            } else {
                [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"rspMsg"] inView:self.view];
            }
        } failure:^(id error) {
            [self endRefresh];
        }];
    }
}

- (void)endRefresh{
    [self->_tableView.mj_header endRefreshing];
    [self->_tableView.mj_footer endRefreshing];
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
}

- (void)dealDataWith:(NSDictionary *)requestResult{
    if (self.currentPage == 1) {//第一页 清空之前的数据
        [self.dataArray removeAllObjects];
    }
    self.currentPage++;
    
    NSString *key = @"merList";
    if (_tableType == 1) {
        key = @"listAgentInfo";
    }
    if (_tableType == 2) {
        _totalSizeL.text = [NSString stringWithFormat:@"%@", [requestResult objectForKey:@"transListSize"]];
        _totalAmtL.text = [NSString stringWithFormat:@"%.2f", [[requestResult objectForKey:@"totalAmt"] doubleValue]];
        key = @"transList";
    }
    if (_tableType == 3) {
        key = @"listAgentFenRunResp";
    }
    if (_tableType == 4) {
        key = @"agentFenrunBranchList";
    }
    if (_tableType == 5) {
        key = @"agentBillDetails";
    }
    if (_tableType == 6) {
        key = @"listWithDarwInfo";
    }
    
    NSArray *dataArray = [requestResult objectForKey:key];
    
    if ([dataArray isKindOfClass:[NSNull class]]) {
        [_tableView reloadData];
        return ;
    }
    if (dataArray.count < 10) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
    
    if (dataArray.count >= 6) {
        [self.tableView.mj_footer setHidden:NO];
    } else {
        [self.tableView.mj_footer setHidden:YES];
    }
    
    [self dealWithArray:dataArray];
    
    [self.tableView reloadData];
}

- (void)dealWithArray:(NSArray *)dataArray{
    if (_tableType == 1) {
        for (NSDictionary *dictionary in dataArray) {
            KDAgentModel *model = [[KDAgentModel alloc] init];
            [model setValuesForKeysWithDictionary:dictionary];
            [self.dataArray addObject:model];
        }
        
    } else if (_tableType == 2) {
        for (NSDictionary *dictionary in dataArray) {
            KDAgentTradeModel *model = [[KDAgentTradeModel alloc] init];
            [model setValuesForKeysWithDictionary:dictionary];
            [self.dataArray addObject:model];
        }
    } else if (_tableType == 3) {
        for (NSDictionary *dictionary in dataArray) {
            NSDictionary *dict = [dictionary objectForKey:@"agentFenrunDto"];
            NSString *agentFenRunBranch = [dictionary objectForKey:@"agentFenRunBranch"];
            NSArray *branchArr = [[ZFGlobleManager getGlobleManager] stringToArray:agentFenRunBranch];
            
            KDBenefitModel *model = [[KDBenefitModel alloc] init];
            [model setValuesForKeysWithDictionary:dict];
            for (NSDictionary *brDict in branchArr) {
                NSString *type = [brDict objectForKey:@"xiajiType"];
                if ([type isEqualToString:@"AGENT"]) {
                    model.agentDict = brDict;
                }
                if ([type isEqualToString:@"MERCHANTS"]) {
                    model.merchantDict = brDict;
                }
            }
            [self.dataArray addObject:model];
        }
        
    } else if (_tableType == 4) {
        for (NSDictionary *dict in dataArray) {
            KDBenefitDetailModel *model = [[KDBenefitDetailModel alloc] init];
            [model setValuesForKeysWithDictionary:dict];
            [self.dataArray addObject:model];
        }
    } else if (_tableType == 5) {
        for (NSDictionary *dictionary in dataArray) {
            KDRMBalanceModel *model = [[KDRMBalanceModel alloc] init];
            [model setValuesForKeysWithDictionary:dictionary];
            [self.dataArray addObject:model];
        }
    } else if (_tableType == 6) {
        for (NSDictionary *dictionary in dataArray) {
            KDRedemptionModel *model = [[KDRedemptionModel alloc] init];
            [model setValuesForKeysWithDictionary:dictionary];
            [self.dataArray addObject:model];
        }
    } else {
        for (NSDictionary *dictionary in dataArray) {
            KDAgentMerModel *model = [[KDAgentMerModel alloc] init];
            [model setValuesForKeysWithDictionary:dictionary];
            [self.dataArray addObject:model];
        }
    }
}

@end
