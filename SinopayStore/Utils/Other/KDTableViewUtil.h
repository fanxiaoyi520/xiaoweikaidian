//
//  KDTableViewUtil.h
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/27.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJRefresh.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDTableViewUtil : NSObject

+ (void)setHeaderWith:(MJRefreshNormalHeader *)header;

+ (void)setFooterWith:(MJRefreshAutoNormalFooter *)footer;

+ (void)setTableView:(UITableView *)tableView header:(MJRefreshComponentRefreshingBlock)headerBlock;

+ (void)setTableView:(UITableView *)tableView footer:(MJRefreshComponentRefreshingBlock)footerBlock;

+ (void)setTableView:(UITableView *)tableView header:(MJRefreshComponentRefreshingBlock)headerBlock footer:(MJRefreshComponentRefreshingBlock)footerBlock;

+ (void)tableViewEndRefresh:(UITableView *)tableView;

+ (UITableView *)getTableViewWithFrame:(CGRect)frame vc:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
