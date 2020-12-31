//
//  KDAddAgentBranchBankController.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/1/3.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDAddAgentBranchBankController.h"

@interface KDAddAgentBranchBankController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

/** tableView */
@property (nonatomic, weak) UITableView *tableView;
/** 搜索框 */
@property(nonatomic, weak) UISearchBar *searchBar;
/** 搜索框是否处于编辑状态 */
@property(nonatomic, assign) BOOL searchBarActive;

//满足搜索条件的数组
@property (strong, nonatomic)NSMutableArray  *searchList;
/** 数据源 */
@property(nonatomic, strong) NSMutableArray *dataSource;

///显示需要的key
@property (nonatomic, strong)NSString *showKey;

@end

@implementation KDAddAgentBranchBankController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.naviTitle = NSLocalizedString(@"请选择分行", nil);
    [self setupTableView];
    [self setupSearchBar];
    if (_searchType == 1) {
        _showKey = @"branchName";
        [self getBranchBank];
    } else {
        _showKey = @"bankNameInEnglish";
        [self getBank];
    }
    self.view.backgroundColor = GrayBgColor;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.searchBar endEditing:YES];
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 搜索框使用的时候，就是点击了搜索框的时候
    if (self.searchBarActive) {
        return self.searchList.count;
    }
    // 搜索框未使用的时候
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"MYCELL";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.textColor = [UIColor grayColor];
    // 搜索框使用的时候
    NSDictionary *dict;
    if (self.searchBarActive) {
        if (indexPath.row < _searchList.count) {
            dict = _searchList[indexPath.row];
        }
    } else {
        if (_dataSource.count > indexPath.row) {
            dict = _dataSource[indexPath.row];
        }
    }
    cell.textLabel.text = [dict objectForKey:_showKey];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.searchBar endEditing:YES];
    
    NSDictionary *dict ;
    if (self.searchBarActive) {
        if (_searchList.count > indexPath.row) {
            dict = _searchList[indexPath.row];
        }
    } else {
        if (_dataSource.count > indexPath.row) {
            dict = _dataSource[indexPath.row];
        }
    }
    
    if (dict) {
        _block(dict);
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [_tableView reloadData];
    }
}

#pragma mark - 搜索框相关
- (void)setupSearchBar {
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, IPhoneXTopHeight)];
    searchBar.placeholder = NSLocalizedString(@"请输入分行名进行查询", nil);;
    searchBar.delegate = self;
    searchBar.translucent = NO;
    searchBar.barTintColor = GrayBgColor;
    searchBar.layer.borderWidth = 2.0;
    searchBar.layer.borderColor = [GrayBgColor CGColor];
    searchBar.barStyle = UIBarStyleDefault;
    [self.view addSubview:searchBar];
    self.searchBar = searchBar;
    self.tableView.tableHeaderView = searchBar;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    for (id obj in [searchBar subviews]) {
        if ([obj isKindOfClass:[UIView class]]) {
            for (id obj2 in [obj subviews]) {
                if ([obj2 isKindOfClass:[UIButton class]]) {
                    UIButton *btn = (UIButton *)obj2;
                    btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
                    [btn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
                }
            }
        }
    }
    return YES;
}

// 编辑文字改变的回调
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    DLog(@"textDidChange--%@", searchText);
    if (self.searchList != nil) {
        [self.searchList removeAllObjects];
    }
    
    _searchList = [[NSMutableArray alloc] init];
    
    if (searchText.length > 0) {
        self.searchBarActive = YES;
        for (NSDictionary *dict in _dataSource) {
            
            if ([[[dict objectForKey:_showKey] lowercaseString] containsString:[searchText lowercaseString]]) {
                [_searchList addObject:dict];
            }
        }
    } else {
        self.searchBarActive = NO;
    }
    
    [self.tableView reloadData];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar endEditing:YES];
}

#pragma mark - 获取数据
- (void)getBranchBank{
    _dataSource = [[NSMutableArray alloc] init];
    
    NSDictionary *dict = @{
                           @"bankCode":_bankCode,
                           TxnType : @"09"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine agentPostWithParams:dict success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"00"]) {
            NSArray *array = [[ZFGlobleManager getGlobleManager] stringToArray:[requestResult objectForKey:@"branchBank"]];
            self.dataSource = [NSMutableArray arrayWithArray:array];
            [self.tableView reloadData];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark 获取银行
- (void)getBank{
    NSDictionary *dict = @{
                           @"countryCode":_countryCode,
                           TxnType:@"08"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine agentPostWithParams:dict success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"00"]) {
            NSArray *array = [[ZFGlobleManager getGlobleManager] stringToArray:[requestResult objectForKey:@"mainBank"]];
            self.dataSource = [NSMutableArray arrayWithArray:array];
            [self.tableView reloadData];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

@end
