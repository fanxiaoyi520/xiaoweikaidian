//
//  KDCashierListController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/5/24.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDCashierListController.h"
#import "KDCashierInfoModel.h"
#import "KDAddCashierController.h"
#import "KDTableViewUtil.h"

@interface KDCashierListController ()<UIScrollViewDelegate>

@property (nonatomic, strong)UIScrollView *scrollView;
@property (nonatomic, strong)NSMutableArray *dataArray;

@end

@implementation KDCashierListController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.naviTitle = NSLocalizedString(@"收银员管理", nil);
    [self createBaseView];
}

- (void)createBaseView{
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightBtn.frame = CGRectMake(SCREEN_WIDTH-130, IPhoneXStatusBarHeight, 110, IPhoneNaviHeight);
    [rightBtn setTitle:NSLocalizedString(@"录入", nil) forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [rightBtn addTarget:self action:@selector(clickAddBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightBtn];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight)];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.backgroundColor = GrayBgColor;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    [self setupRefresh];
    [_scrollView.mj_header beginRefreshing];
}

- (void)createView{
    
    [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setupRefresh];
    
    if (_dataArray.count == 0) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-120)/2, 80, 120, 120)];
        imageView.image = [UIImage imageNamed:@"pic_shouyinyuan_grey"];
        [_scrollView addSubview:imageView];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, imageView.bottom+20, SCREEN_WIDTH-40, 40)];
        tipLabel.numberOfLines = 2;
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.font = [UIFont systemFontOfSize:14];
        tipLabel.alpha = 0.6;
        tipLabel.text = NSLocalizedString(@"暂无收银员账号，点击右上角“录入”进行添加", nil);
        tipLabel.adjustsFontSizeToFitWidth = YES;
        [_scrollView addSubview:tipLabel];
        return;
    }
    
    CGFloat width = (SCREEN_WIDTH-55)/2;
    NSInteger count = _dataArray.count;
    
    for (NSInteger i = 0; i < count; i++) {
        KDCashierInfoModel *model = _dataArray[i];
        CGFloat x = i % 2 == 0 ? 20:width+35;
        CGFloat y = (i / 2)*(width + 20)+20;
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, width)];
        backView.backgroundColor = [UIColor whiteColor];
        backView.layer.cornerRadius = 10;
        backView.clipsToBounds = YES;
        [_scrollView addSubview:backView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, width*0.125, width*0.375, width*0.375)];
        imageView.centerX = width/2;
        imageView.image = [UIImage imageNamed:@"pic_shouyinyuan_blue"];
        [backView addSubview:imageView];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.bottom+10, width, 17)];
        nameLabel.font = [UIFont systemFontOfSize:15];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.adjustsFontSizeToFitWidth = YES;
        nameLabel.text = model.userName;
        [backView addSubview:nameLabel];
        
        UIImageView *bottomImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, width-width*0.22, width, width*0.22)];
        bottomImage.image = [UIImage imageNamed:@"rectangle_2"];
        [backView addSubview:bottomImage];
        
        UIButton *bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        bottomBtn.frame = bottomImage.frame;
        bottomBtn.tag = i;
        [bottomBtn setImage:[UIImage imageNamed:@"icon_delete_small"] forState:UIControlStateNormal];
        [bottomBtn setImage:[UIImage imageNamed:@"icon_delete_small"] forState:UIControlStateHighlighted];
        [bottomBtn addTarget:self action:@selector(deldetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:bottomBtn];
    }
    
    CGFloat height = (count/2 + count%2)*(width+20)+20;
    if (height < _scrollView.height) {
        height = _scrollView.height + 20;
    }
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, height);
}

-(void)setupRefresh {
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getData];
    }];
    [KDTableViewUtil setHeaderWith:header];
    _scrollView.mj_header = header;
}

- (void)getData{
    _dataArray = [[NSMutableArray alloc] init];
    
    NSDictionary *dict = @{@"countryCode":[ZFGlobleManager getGlobleManager].areaNum,
                           @"mobile":[ZFGlobleManager getGlobleManager].userPhone,
                           @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                           @"txnType":@"65"
                           };
    
//    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        [_scrollView.mj_header endRefreshing];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] dismissMB];
            NSArray *listArr = [requestResult objectForKey:@"list"];
            for (NSDictionary *dict in listArr) {
                KDCashierInfoModel *cashierModel = [[KDCashierInfoModel alloc] init];
                [cashierModel setValuesForKeysWithDictionary:dict];
                [_dataArray addObject:cashierModel];
            }
            [self createView];
            
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        [_scrollView.mj_header endRefreshing];
    }];
}

- (void)clickAddBtn{
    KDAddCashierController *acVC = [[KDAddCashierController alloc] init];
    acVC.block = ^(BOOL isReload) {
        if (isReload) {
            [self getData];
        }
    };
    [self pushViewController:acVC];
}

- (void)deldetBtnClick:(UIButton *)btn{
    DLog(@"%zd", btn.tag);
    
    // 初始化
    UIAlertController *alertDialog = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"确认删除", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self deleteCashierWith:btn.tag];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // 取消按键
    }];
    
    // 添加操作（顺序就是呈现的上下顺序）
    [alertDialog addAction:confirm];
    [alertDialog addAction:cancelAction];
    
    // 呈现警告视图
    [self presentViewController:alertDialog animated:YES completion:nil];
}

- (void)deleteCashierWith:(NSInteger)tag{
    if (tag >= _dataArray.count) {
        return;
    }
    KDCashierInfoModel *model = _dataArray[tag];
    NSString *userName = model.userName;
    
    NSDictionary *dict = @{@"countryCode":[ZFGlobleManager getGlobleManager].areaNum,
                           @"mobile":[ZFGlobleManager getGlobleManager].userPhone,
                           @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                           @"cashierName":userName,
                           @"txnType":@"66"
                           };
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] dismissMB];
            
            [_dataArray removeObjectAtIndex:tag];
            
            [self createView];
            
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    DLog(@"--%.f", scrollView.contentOffset.y);
//    if (scrollView.contentOffset.y < -120) {
//        [_scrollView.mj_header beginRefreshing];
//    }
//}

@end
