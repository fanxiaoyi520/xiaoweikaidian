//
//  KDCollectionDetailsViewController.m
//  SinopayStore
//
//  Created by Jellyfish on 2017/12/4.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "KDCollectionDetailsViewController.h"
#import "CDatePickerViewEx.h"
#import "KDCollectionDetailsCell.h"
#import "DDTableViewHeader.h"
#import "MJExtension.h"
#import "YYModel.h"
#import "KDTableViewUtil.h"
#import "KDCollectionDateModel.h"
#import "KDCollectionDeatilsModel.h"
#import "KDOrderDetailController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "KDVoidDetailController.h"
#import "KDSettmentWebController.h"
#import "KDMoreWebController.h"
#import "KDReceiptDetailController.h"

@interface KDCollectionDetailsViewController () <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
/** 底部容器视图 */
@property (nonatomic, weak) UIView *contentView;
/** 日期PickerView */
@property (nonatomic, weak) CDatePickerViewEx *pickerView;
/** 遮罩 */
@property(nonatomic, weak) UIView *darkView;

/** tableView */
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray<KDCollectionDateModel *> *dateArray;

/** 导航栏按钮 */
@property(nonatomic, weak) UIButton *naviButton;
/** 当前日期 */
@property(nonatomic, copy) NSString *currentDate;
/** 上次选择的日期 */
//@property(nonatomic, copy) NSString *lastDate;

@end

@implementation KDCollectionDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    // 默认选择当前月份
    self.currentDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [self setupNaviTitleView];
    [self setupTableView];
    [self setupDatePickerView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chexiaoComplete) name:@"chexiao_complete" object:nil];
}

- (void)chexiaoComplete{
    [self.tableView.mj_header beginRefreshing];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:UNREAD_MESSAGE]) {
        [self.tableView.mj_header beginRefreshing];
    }
}

#pragma mark - 初始化方法
// 自定义导航栏title
- (void)setupNaviTitleView {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, IPhoneXTopHeight)];
    bgView.backgroundColor = MainThemeColor;
    [self.view addSubview:bgView];
    
    UIButton *naviButton = [UIButton buttonWithType:UIButtonTypeCustom];
    naviButton.frame = CGRectMake(SCREEN_WIDTH*0.2, IPhoneXStatusBarHeight, SCREEN_WIDTH*0.6, IPhoneXTopHeight-IPhoneXStatusBarHeight);
    [naviButton setImage:[UIImage imageNamed:@"icon_unfold_white"] forState:UIControlStateNormal];
    [naviButton setImage:[UIImage imageNamed:@"icon_unfold_white"] forState:UIControlStateHighlighted];
    
    // 默认设置当前月份
    [naviButton setTitle:self.currentDate forState:UIControlStateNormal];
    naviButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [naviButton addTarget:self action:@selector(showMonth) forControlEvents:UIControlEventTouchUpInside];
    // 设置偏移量
    [naviButton setTitleEdgeInsets:UIEdgeInsetsMake(-5, -naviButton.imageView.width, 0, naviButton.imageView.width+10)];
    [naviButton setImageEdgeInsets:UIEdgeInsetsMake(0, naviButton.titleLabel.width, 0, -naviButton.titleLabel.width)];
    [bgView addSubview:naviButton];
    self.naviButton = naviButton;
    
    //结算按钮
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightBtn.frame = CGRectMake(SCREEN_WIDTH-120, IPhoneXStatusBarHeight, 110, IPhoneNaviHeight);
    [rightBtn setTitle:NSLocalizedString(@"手动结算", nil) forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    rightBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [rightBtn addTarget:self action:@selector(clickSettmentBtn) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:rightBtn];
    
    //更多按钮
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    leftBtn.frame = CGRectMake(20, IPhoneXStatusBarHeight, 110, rightBtn.height);
    [leftBtn setTitle:NSLocalizedString(@"更多", nil) forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    leftBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [leftBtn addTarget:self action:@selector(moreBtnClick) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:leftBtn];
}

// 设置tableView
- (void)setupTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight-44) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = GrayBgColor;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    [self setupRefresh];
}

#pragma mark -- UITableViewDataSourece&UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dateArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dateArray[section].isExpanded ? (self.dateArray[section].dailyList.count) : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDCollectionDetailsCell *cell = [KDCollectionDetailsCell cellWithTableView:tableView];
    cell.cellModel = self.dateArray[indexPath.section].dailyList[indexPath.row];
    
    return cell;
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DLog(@"%zd--%zd", indexPath.section, indexPath.row);
    KDCollectionDeatilsModel *model = self.dateArray[indexPath.section].dailyList[indexPath.row];
    KDReceiptDetailController *rdVC = [[KDReceiptDetailController alloc] init];
    rdVC.orderID = model.orderID;
    [self pushViewController:rdVC];
    
    
//    if ([model.orderID hasPrefix:@"C"]) {//撤销后的
//        KDVoidDetailController *vdVC = [[KDVoidDetailController alloc] init];
//        vdVC.orderID = model.orderID;
//        [self pushViewController:vdVC];
//    } else {//没有撤销的
//        KDOrderDetailController *orderVC = [[KDOrderDetailController alloc] init];
//        orderVC.orderID = model.orderID;
//        [self pushViewController:orderVC];
//    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    DDTableViewHeader *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    
    if (!headerView) {
        headerView = [[DDTableViewHeader alloc] initWithReuseIdentifier:@"header"];
    }
    
    headerView.sectionModel = self.dateArray[section];
    headerView.HeaderClickedBack = ^(BOOL isExpand){
        [tableView reloadSections:[[NSIndexSet alloc] initWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
    };
    
    return  headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
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
    NSString *text = NSLocalizedString(@"暂无交易记录", nil);
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:13.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return -60;
}
// 不影响刷新
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView{
    return YES;
}

#pragma mark - 点击方法
- (void)showMonth
{
    self.darkView.hidden = NO;
    [UIView animateWithDuration:0.5f animations:^{
        self.contentView.y = SCREEN_HEIGHT-225;
    }];
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
        // 保存本次选择的日期作为查询依据
        self.currentDate = selectDate;
        [self.naviButton setTitle:selectDate forState:UIControlStateNormal];
        
        [self.dateArray removeAllObjects];
        [self.tableView reloadData];
        // 查询
        //[self queryTradeRecodeByDate:selectDate];
        [self.tableView.mj_header beginRefreshing];
    }
}

//去结算
- (void)clickSettmentBtn{
    KDSettmentWebController *swVC = [[KDSettmentWebController alloc] init];
    swVC.block = ^(BOOL isReload) {
        if (isReload) {
            [self.tableView.mj_header beginRefreshing];
        }
    };
    [self pushViewController:swVC];
}

//更多
- (void)moreBtnClick{
    KDMoreWebController *mVC = [[KDMoreWebController alloc] init];
    [self pushViewController:mVC];
}

#pragma mark -- 初始化日期选择器
- (void)setupDatePickerView {
    // 遮罩
    UIView *darkView = [[UIView alloc] init];
    darkView.backgroundColor = ZFAlpColor(46, 49, 50, 0.6);
    darkView.frame = ZFSCREEN;
    [[UIApplication sharedApplication].keyWindow addSubview:darkView];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelBtnClicked)];
    [darkView addGestureRecognizer:tapGestureRecognizer];
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


#pragma mark - 其他方法
- (NSString *)getTimeStringWith:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    return dateStr;
}


// 添加刷新控件
-(void)setupRefresh {
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self queryTradeRecodeByDate:self.currentDate];
    }];
    [KDTableViewUtil setHeaderWith:header];
    self.tableView.mj_header = header;
    [self.tableView.mj_header beginRefreshing];
}


#pragma mark - 网络请求
- (void)queryTradeRecodeByDate:(NSString *)date {
    NSDictionary *dict = @{@"countryCode" : [ZFGlobleManager getGlobleManager].areaNum,
                           @"mobile" : [ZFGlobleManager getGlobleManager].userPhone,
                           @"sessionID" : [ZFGlobleManager getGlobleManager].sessionID,
                           @"month" :  [date stringByReplacingOccurrencesOfString:@"-" withString:@""],
                           @"txnType" : @"09",
                           };
    
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        self.tableView.emptyDataSetSource = self;
        self.tableView.emptyDataSetDelegate = self;
        
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) { // 提交成功
            [[MBUtils sharedInstance] dismissMB];
            
            self.dateArray = (NSMutableArray *)[NSArray yy_modelArrayWithClass:[KDCollectionDateModel class] json:[requestResult objectForKey:@"list"]];
//            BOOL isHaveData = NO;
            
            
            for (KDCollectionDateModel *model in self.dateArray) {
                if (model.dailyList.count) {
                    model.isExpanded = YES;
//                    isHaveData = YES;
                    break ;
                }
            }
            //没有数据的日期删掉
            for (NSInteger i = self.dateArray.count-1; i >= 0 ; i--) {
                KDCollectionDateModel *model = self.dateArray[i];
                DLog(@"count = %zd", model.dailyList.count);
                if (!model.dailyList.count) {
                    [self.dateArray removeObject:model];
                }
            }
            
            //列表里没有数据
//            if (!isHaveData) {
//                [self.dateArray removeAllObjects];
//            }
            
            // 清空消息，角标置零
            if ([[NSUserDefaults standardUserDefaults] boolForKey:UNREAD_MESSAGE]) {
                [self.tabBarController.tabBar hideBadgeOnItemIndex:1];
            }
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            if (self.dateArray) {            
                [self.dateArray removeAllObjects];
                [self.tableView reloadData];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 统一结束刷新
            [self.tableView.mj_header endRefreshing];
            [self.tableView reloadData];
        });
    } failure:^(id error) {
        //结束刷新
        [self.tableView.mj_header endRefreshing];
    }];
}



@end


