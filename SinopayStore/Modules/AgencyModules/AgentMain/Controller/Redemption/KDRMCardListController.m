//
//  KDRMCardListController.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/25.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDRMCardListController.h"
#import "KDRMCardListCell.h"
#import "UIScrollView+EmptyDataSet.h"
#import "KDTableViewUtil.h"

@interface KDRMCardListController ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray <KDRedemptionCardModel *> *dataArray;
@property (nonatomic, assign)NSInteger currentPage;

@end

@implementation KDRMCardListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.naviTitle = NSLocalizedString(@"银行卡管理", nil);
    _dataArray = [[NSMutableArray alloc] init];
    [self getData];
    [self createView];
}

- (void)createView{
    
    _tableView = [KDTableViewUtil getTableViewWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight) vc:self];
    [self.view addSubview:_tableView];
}

#pragma mark - tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    KDRMCardListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardListCell"];
    if (!cell) {
        cell = (KDRMCardListCell *)[[[NSBundle mainBundle] loadNibNamed:@"KDRMCardListCell" owner:self options:nil] firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row < _dataArray.count) {
        cell.model = _dataArray[indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < _dataArray.count && _isChoose) {
        _block(_dataArray[indexPath.row]);
        [self.navigationController popViewControllerAnimated:YES];
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
    return -100;
}

#pragma mark 获取数据
- (void)getData{
    NSDictionary *dict = @{
                           @"currentLoginUser":[NSString stringWithFormat:@"%@%@", [ZFGlobleManager getGlobleManager].areaNum, [ZFGlobleManager getGlobleManager].userPhone],
                           TxnType:@"20"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine agentPostWithParams:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"00"]) {
            [[MBUtils sharedInstance] dismissMB];
            NSArray *array = [requestResult objectForKey:@"cardList"];
            [_dataArray removeAllObjects];
            for (NSDictionary *dict in array) {
                KDRedemptionCardModel *model = [[KDRedemptionCardModel alloc] init];
                [model setValuesForKeysWithDictionary:dict];
                [_dataArray addObject:model];
            }
            
            [self.tableView reloadData];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}
@end
