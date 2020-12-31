//
//  KDAgencyHomeController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/7/31.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDAgencyHomeController.h"
#import "KDAddMerGetCodeController.h"
#import "KDAgentChangePWController.h"
#import "KDRedemptionManageController.h"
#import "BezierController.h"
#import "KDAgentTableViewController.h"

@interface KDAgencyHomeController ()

@end

@implementation KDAgencyHomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNav];
    [self createView];
}

- (void)setupNav{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, IPhoneXTopHeight)];
    bgView.backgroundColor = MainThemeColor;
    [self.view addSubview:bgView];
    
    //退出按钮
    UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    exitBtn.frame = CGRectMake(SCREEN_WIDTH-80, IPhoneXStatusBarHeight, 60, IPhoneXTopHeight-IPhoneXStatusBarHeight);
    exitBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    exitBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [exitBtn setTitle:NSLocalizedString(@"退出登录", nil) forState:UIControlStateNormal];
    [exitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [exitBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:exitBtn];
}

- (void)createView{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight)];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.backgroundColor = UIColorFromRGB(0xf6f6f6);
    [self.view addSubview:scrollView];
    
    CGFloat bottom = 0;
    CGFloat Width = (SCREEN_WIDTH-55)/2;
    CGFloat height = Width;
    NSArray *titleArray = @[@"新增商户", @"商户列表", @"新增代理", @"代理列表", @"交易查询", @"代理分润查询", @"修改密码"];
    NSArray *imageArray = @[@"icon_add_mer", @"icon_shanghu", @"icon_add_agent", @"icon_shanghu", @"icon_jiaoyi", @"icon_fenrun", @"pic_mima"];
    NSArray *tagArray = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6"];
    
    if ([[ZFGlobleManager getGlobleManager].userPhone isEqualToString:@"17512098051"]) {
        titleArray = @[@"商户列表", @"代理列表", @"交易查询", @"代理分润查询", @"修改密码"];
        imageArray = @[@"icon_shanghu", @"icon_shanghu", @"icon_jiaoyi", @"icon_fenrun", @"pic_mima"];
        tagArray = @[@"1", @"3", @"4", @"5", @"6"];
    }
    
    for (NSInteger i = 0; i < titleArray.count; i++) {
        CGFloat x = (Width+15)*(i%2) + 20;
        CGFloat y = (height+30)*(i/2)+20;
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(x, y, Width, height)];
        backView.layer.cornerRadius = 5;
        backView.clipsToBounds = YES;
        backView.backgroundColor = [UIColor whiteColor];
        [scrollView addSubview:backView];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.size = CGSizeMake(Width/3, Width/3);
        imageView.center = CGPointMake(Width/2, height/2-20);
        imageView.image = [UIImage imageNamed:imageArray[i]];
        [backView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.bottom+15, Width, 20)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.text = titleArray[i];
        [backView addSubview:label];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, Width, height);
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = [tagArray[i] integerValue];
        [backView addSubview:btn];
        
        bottom = y+height;
    }
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, bottom+20);
}

- (void)clickBtn:(UIButton *)btn{
    DLog(@"%zd", btn.tag);
    NSInteger tag = btn.tag;
    if (tag == 0) {//新增商户
        KDAddMerGetCodeController *amVC = [[KDAddMerGetCodeController alloc] init];
        [self pushViewController:amVC];
    }
    if (tag == 1) {//商户列表
        KDAgentTableViewController *atVC = [[KDAgentTableViewController alloc] init];
        atVC.tableType = 0;
        [self pushViewController:atVC];
    }
    if (tag == 2) {//新增代理
        KDAddMerGetCodeController *addVC = [[KDAddMerGetCodeController alloc] init];
        [ZFGlobleManager getGlobleManager].agentAddType = 1;
        addVC.codeType = 2;
        [self pushViewController:addVC];
    }
    if (tag == 3) {//代理列表
        KDAgentTableViewController *atVC = [[KDAgentTableViewController alloc] init];
        atVC.tableType = 1;
        [self pushViewController:atVC];
    }
    if (tag == 4) {//交易查询
        KDAgentTableViewController *atVC = [[KDAgentTableViewController alloc] init];
        atVC.tableType = 2;
        [self pushViewController:atVC];
    }
    if (tag == 5) {//代理分润
        KDAgentTableViewController *atVC = [[KDAgentTableViewController alloc] init];
        atVC.tableType = 3;
        [self pushViewController:atVC];
    }
    if (tag == 6) {//修改密码
        KDAgentChangePWController *cpwVC = [[KDAgentChangePWController alloc] init];
        [self pushViewController:cpwVC];
    }
//    if (tag == 7) {//提现管理
//        KDRedemptionManageController *rmVC = [[KDRedemptionManageController alloc] init];
//        [self pushViewController:rmVC];
//    }
    
    if (btn.tag == 777) {
//        BezierController *bzVC = [[BezierController alloc] init];
//        [self pushViewController:bzVC];
    }
}

- (void)close{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"退出登录", nil) message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.block(YES);
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:confirm];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
