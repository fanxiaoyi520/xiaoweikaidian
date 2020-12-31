//
//  KDSearchBBNViewController.m
//  SinopayStore
//
//  Created by Jellyfish on 2017/12/11.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "KDSearchBBNViewController.h"

@interface KDSearchBBNViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

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

@end

@implementation KDSearchBBNViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"请选择分行", nil);
    [self setupTableView];
    [self setupSearchBar];
    [self getData];
    self.view.backgroundColor = GrayBgColor;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.searchBar endEditing:YES];
}

// 数据源
- (void)getData{
    _dataSource = [[NSMutableArray alloc] init];
    
    NSDictionary *dict = @{@"bankCode":_bankCode,
                           @"txnType" : @"19"};
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] dismissMB];
            NSArray *list = [requestResult objectForKey:@"list"];
            for (NSDictionary *dict in list) {
                KDBranchBankModel *model = [[KDBranchBankModel alloc] init];
                model.branchNum = [dict objectForKey:@"branchNum"];
                model.branchName = [dict objectForKey:@"branchName"];
                [_dataSource addObject:model];
            }
            
            [_tableView reloadData];
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
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
    KDBranchBankModel *model;
    if (self.searchBarActive) {
        if (indexPath.row < _searchList.count) {
            model = _searchList[indexPath.row];
        }
    } else {
        if (_dataSource.count > indexPath.row) {
            model = _dataSource[indexPath.row];
        }
    }
    cell.textLabel.text = model.branchName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.searchBar endEditing:YES];
    
    KDBranchBankModel *model ;
    if (self.searchBarActive) {
        if (_searchList.count > indexPath.row) {
            model = _searchList[indexPath.row];
        }
    } else {
        if (_dataSource.count > indexPath.row) {
            model = _dataSource[indexPath.row];
        }
    }
    
    if (model) {
        _block(model);
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
        for (KDBranchBankModel *model in _dataSource) {
        
            if ([[model.branchName lowercaseString] containsString:[searchText lowercaseString]]) {
                [_searchList addObject:model];
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

@end
