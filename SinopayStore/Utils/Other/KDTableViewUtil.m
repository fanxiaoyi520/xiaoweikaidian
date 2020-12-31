//
//  KDTableViewUtil.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/27.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDTableViewUtil.h"

@implementation KDTableViewUtil

+ (void)setHeaderWith:(MJRefreshNormalHeader *)header{
    [header setTitle:NSLocalizedString(@"下拉刷新数据", nil) forState:MJRefreshStateIdle];
    [header setTitle:NSLocalizedString(@"松开立即刷新", nil) forState:MJRefreshStatePulling];
    [header setTitle:NSLocalizedString(@"正在加载", nil) forState:MJRefreshStateRefreshing];
    header.lastUpdatedTimeLabel.hidden = NO;
    header.stateLabel.font = [UIFont systemFontOfSize:13.0];
    [header isAutomaticallyChangeAlpha];
}

+ (void)setFooterWith:(MJRefreshAutoNormalFooter *)footer{
    [footer setTitle:NSLocalizedString(@"上拉加载更多数据", nil) forState:MJRefreshStateIdle];
    [footer setTitle:NSLocalizedString(@"正在加载", nil) forState:MJRefreshStateRefreshing];
    [footer setTitle:NSLocalizedString(@"加载完毕", nil) forState:MJRefreshStateNoMoreData];
    footer.stateLabel.font = [UIFont systemFontOfSize:13.0];
    footer.automaticallyHidden = NO;
    footer.automaticallyRefresh = YES;
}

+ (UITableView *)getTableViewWithFrame:(CGRect)frame vc:(UIViewController *)vc{
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    tableView.backgroundColor = UIColorFromRGB(0xf6f6f6);
    tableView.delegate = vc;
    tableView.dataSource = vc;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    return tableView;
}

+ (void)setTableView:(UITableView *)tableView header:(MJRefreshComponentRefreshingBlock)headerBlock{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:headerBlock];
    [self setHeaderWith:header];
    tableView.mj_header = header;
}

+ (void)setTableView:(UITableView *)tableView footer:(MJRefreshComponentRefreshingBlock)footerBlock{
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:footerBlock];
    [self setFooterWith:footer];
    tableView.mj_footer = footer;
    // 开始隐藏
    [tableView.mj_footer setHidden:YES];
}

+ (void)setTableView:(UITableView *)tableView header:(MJRefreshComponentRefreshingBlock)headerBlock footer:(MJRefreshComponentRefreshingBlock)footerBlock{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:headerBlock];
    [self setHeaderWith:header];
    tableView.mj_header = header;
    
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:footerBlock];
    [self setFooterWith:footer];
    tableView.mj_footer = footer;
    // 开始隐藏
    [tableView.mj_footer setHidden:YES];
}

+ (void)tableViewEndRefresh:(UITableView *)tableView{
    [tableView.mj_header endRefreshing];
    [tableView.mj_footer endRefreshing];
}

@end
