//
//  KDAwardRecodeViewController.m
//  SinopayStore
//
//  Created by Jellyfish on 2018/1/3.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDAwardRecodeViewController.h"
#import "KDAwardRecordCell.h"
#import "CDatePickerViewEx.h"
#import "KDWithdrawalDetailsViewController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "YYModel.h"
#import "MJRefresh.h"
#import "TradeSectionModel.h"
#import "KDAwardRecordHeader.h"


#define QueryRows 20

@interface KDAwardRecodeViewController () <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong)UITableView *tableView;

/** 底部容器视图 */
@property (nonatomic, weak) UIView *contentView;
/** 日期PickerView */
@property (nonatomic, weak) CDatePickerViewEx *pickerView;
/** 遮罩 */
@property(nonatomic, weak) UIView *darkView;

/** 按月区分 */
@property(nonatomic, strong) NSMutableArray<TradeSectionModel *> *sectionArray;

/** 当前日期 */
@property(nonatomic, copy) NSString *currentDate;
// 当前页数
@property (nonatomic, assign)NSInteger currentPage;

@end

@implementation KDAwardRecodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"奖励记录", nil);
    
    
    [self createView];
    
    self.currentDate = @"all";
    self.currentPage = 1;
    
    [self queryTradeRecodeByDate:self.currentDate beginNum:self.currentPage];
    //撤销奖励通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadList) name:@"voidRewardNotification" object:nil];
}

//重新加载列表
- (void)reloadList{
    self.currentDate = @"all";
    self.currentPage = 1;
    
    [self queryTradeRecodeByDate:self.currentDate beginNum:self.currentPage];
}

#pragma mark -- 初始化视图
- (void)createView{
    //筛选按钮
    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    registerBtn.frame = CGRectMake(SCREEN_WIDTH-60, IPhoneXStatusBarHeight+2, 60, 44);
    [registerBtn setTitle:NSLocalizedString(@"筛选", nil) forState:UIControlStateNormal];
    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    registerBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [registerBtn addTarget:self action:@selector(clickSelectBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerBtn];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 60;
    _tableView.backgroundColor = GrayBgColor;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    [self setupRefresh];
    
    [self createTimerPicker];
}

- (void)createTimerPicker{
    // 遮罩
    UIView *darkView = [[UIView alloc] init];
    darkView.backgroundColor = ZFAlpColor(46, 49, 50, 0.6);
    darkView.frame = ZFSCREEN;
    [[UIApplication sharedApplication].keyWindow addSubview:darkView];
    self.darkView = darkView;
    self.darkView.hidden = YES;
    
    // 容器视图
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 225)];
    contentView.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication].keyWindow addSubview:contentView];
    self.contentView = contentView;
    
    // 取消按钮
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];;
    cancelBtn.backgroundColor = [UIColor clearColor];
    [cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:cancelBtn];
    
    // 提示文字
    UILabel *tiplabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3, 0, SCREEN_WIDTH/3, 44)];
    tiplabel.text = NSLocalizedString(@"请选择月份", nil);
    tiplabel.textColor = UIColorFromRGB(0x313131);
    tiplabel.textAlignment = NSTextAlignmentCenter;
    tiplabel.font = [UIFont boldSystemFontOfSize:17.0];
    [contentView addSubview:tiplabel];
    
    // 确定按钮
    UIButton *ctBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-80, 0, 80, 44)];;
    ctBtn.backgroundColor = [UIColor clearColor];
    [ctBtn setTitleColor:MainThemeColor forState:UIControlStateNormal];
    [ctBtn setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    ctBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [ctBtn addTarget:self action:@selector(ctBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:ctBtn];
    
    // 分割线
    UIView *spliteView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, 1)];
    spliteView.backgroundColor = GrayBgColor;
    [contentView addSubview:spliteView];
    
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:nowDate];
    NSArray *dateArr = [dateStr componentsSeparatedByString:@"-"];
    
    // 日期选择器
    CDatePickerViewEx *pickerView = [[CDatePickerViewEx alloc] initWithFrame:CGRectMake(0, 45, SCREEN_WIDTH, 230)];
    [pickerView setupMinYear:2015 maxYear:[dateArr[0] integerValue]];
    [pickerView setDefaultTime:[dateArr[0] integerValue]-2015 And:[dateArr[1] integerValue]-1];
    [contentView addSubview:pickerView];
    self.pickerView = pickerView;
}

#pragma mark -- UITableViewDataSourece&UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sectionArray[section].monthList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    KDAwardRecordCell *cell = [KDAwardRecordCell cellWithTableView:tableView];
    cell.record = self.sectionArray[indexPath.section].monthList[indexPath.row];
    return cell;
}


#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    KDAwardRecordHeader *headView = [KDAwardRecordHeader headerViewWithTableView:tableView];
    headView.sectionModel = self.sectionArray[section];
    return headView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    KDWithdrawalDetailsViewController *detailVC = [[KDWithdrawalDetailsViewController alloc] init];
    KDAwardRecord *record = self.sectionArray[indexPath.section].monthList[indexPath.row];
    detailVC.transNumber = record.transNumber;
    if (record.transNumber.length > 0) {
        [self pushViewController:detailVC];
    }
}

// 设置分割线偏移
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}


#pragma mark -- DZNEmptyDataSetSource
// 设置空白页展示图片
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView{
    return [UIImage imageNamed:@"pic_no_account"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSString *text = NSLocalizedString(@"暂无奖励记录", nil);
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:13.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return -80;
}
// 不影响刷新
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView{
    return YES;
}

#pragma mark - 点击方法
// 筛选
- (void)clickSelectBtn {
    self.darkView.hidden = NO;
    [UIView animateWithDuration:0.5f animations:^{
        self.contentView.y = SCREEN_HEIGHT-225;
    }];
}

// 确定选择时间
- (void)ctBtnClicked {
    // 退出选择器
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.contentView.y = SCREEN_HEIGHT;
                     }
                     completion:^(BOOL finished){
                         self.darkView.hidden = YES;
                     }];
    
    NSString *selectDate = [self getTimeStringWith:self.pickerView.date];
    DLog(@"选中日期：%@", selectDate);
    
    if (![selectDate isEqualToString:self.currentDate]) { // 不同
        NSString *year = [selectDate substringToIndex:4];
        NSString *month = [selectDate substringFromIndex:4];
        // 保存本次选择的日期作为查询依据
        self.currentDate = [year stringByAppendingString:month];
        
        [self.sectionArray removeAllObjects];
        [self.tableView reloadData];
        
        // 重新筛选默认查询第一页
        self.currentPage = 1;
        [self queryTradeRecodeByDate:selectDate beginNum:self.currentPage];
    }
}

// 取消选择时间
- (void)cancelBtnClicked {
    self.darkView.hidden = YES;
    // 退出选择器
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.contentView.y = SCREEN_HEIGHT;
                     }
                     completion:^(BOOL finished){
                         self.darkView.hidden = YES;
                     }];
}


#pragma mark -- 网络请求
- (void)queryTradeRecodeByDate:(NSString *)date beginNum:(NSInteger)page {
    NSDictionary *parameters = @{
                                 @"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"startDate":date,
                                 @"transNumber":@"",
                                 @"beginNum":[NSString stringWithFormat:@"%zd", page],
                                 @"queryRows": [NSString stringWithFormat:@"%zd", QueryRows],
                                 @"txnType": @"44",
                                 };
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        self.tableView.emptyDataSetSource = self;
        self.tableView.emptyDataSetDelegate = self;

        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {

            // 当前查询出来的交易数据
            NSArray <TradeSectionModel *> *currentSectionArray = [NSArray yy_modelArrayWithClass:[TradeSectionModel class] json:[requestResult objectForKey:@"list"]];
            
            if (self.sectionArray.count) { // 第二次以上查询
                for (int i = 0; i < currentSectionArray.count; i++) {
                    if (![currentSectionArray[i].month isEqualToString:self.sectionArray.lastObject.month]) {
                        // 不同的话在原来的基础上添加一个分区模型
                        TradeSectionModel *sectiomModel = [[TradeSectionModel alloc] init];
                        sectiomModel = currentSectionArray[i];
                        [self.sectionArray addObject:sectiomModel];
                        
                        continue ;
                    }
                    
                    // 相同的话添加到上一次的月份当中
                    for (KDAwardRecord *record in currentSectionArray[i].monthList) {
                        [self.sectionArray.lastObject.monthList addObject:record];
                    }
                }
            } else {
                self.sectionArray = [NSMutableArray arrayWithArray:currentSectionArray];
            }
            
            // 获取数据之后的刷新处理
            // 第一次获取决定是否隐藏尾部刷新控件
            NSInteger totalCount = 0;
            for (TradeSectionModel *section in currentSectionArray) {
                totalCount += section.monthList.count;
            }
            
            DLog(@"总共--%zd", totalCount);
            
            if (self.currentPage == 1) {
                if (totalCount < 10) {
                    [self.tableView.mj_footer setHidden:YES];
                } else {
                    [self.tableView.mj_footer setHidden:NO];
                }
            }
            
            // 统一结束刷新
            [self.tableView.mj_footer endRefreshing];
            
            // 如果当前页数不够显示的页数,说明没有数据了
            if (totalCount < QueryRows) {
                // 没有更多的数据了
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            
            [self.tableView reloadData];
            
        } else {
            [self.tableView.mj_footer endRefreshing];
            
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"1"]) {//没有交易记录
                if (self.currentPage > 1) { // 查过一次显示没有更多数据
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                } else { // 第一页都没有隐藏
                    [self.tableView.mj_footer setHidden:YES];
                    [self.tableView reloadData];
                }
            } else {
                [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            }
        }
    } failure:^(NSError *error) {
        [self.tableView.mj_footer endRefreshing];
    }];
}


#pragma mark - 其他方法
- (NSString *)getTimeStringWith:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    return dateStr;
}

- (NSString *)stringTimeWith:(NSString *)dateStr{
    NSString *resultStr = @"";
    if (![dateStr isKindOfClass:[NSNull class]] && dateStr && dateStr.length > 6) {
        resultStr = [dateStr substringToIndex:6];
        resultStr = [NSString stringWithFormat:@"%@-%@", [resultStr substringToIndex:4], [resultStr substringFromIndex:4]];
    } else {
        resultStr = [self getTimeStringWith:[NSDate date]];
    }
    return resultStr;
}

/** 添加刷新控件 */
-(void)setupRefresh {
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self queryTradeRecodeByDate:self.currentDate beginNum:++self.currentPage];
    }];
    [footer setTitle:NSLocalizedString(@"上拉加载更多数据", nil) forState:MJRefreshStateIdle];
    [footer setTitle:NSLocalizedString(@"正在加载", nil) forState:MJRefreshStateRefreshing];
    [footer setTitle:NSLocalizedString(@"加载完毕", nil) forState:MJRefreshStateNoMoreData];
    footer.stateLabel.font = [UIFont systemFontOfSize:13.0];
    footer.automaticallyHidden = NO;
    footer.automaticallyRefresh = YES;
    self.tableView.mj_footer = footer;
    // 开始隐藏
    [self.tableView.mj_footer setHidden:YES];
}


#pragma mark - 懒加载
- (NSMutableArray<TradeSectionModel *> *)sectionArray {
    if (!_sectionArray) {
        _sectionArray = [NSMutableArray array];
    }
    return _sectionArray;
}

@end
