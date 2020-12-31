//
//  KDRMPayManageController.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/25.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDRMPayManageController.h"
#import "KDRMPassWordController.h"
#import "KDRMGetCodeController.h"
#import "KDRMCardListController.h"

@interface KDRMPayManageController ()

@end

@implementation KDRMPayManageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.naviTitle = NSLocalizedString(@"支付设置", nil);
    self.view.backgroundColor = GrayBgColor;
    [self createView];
}

- (void)createView{
    NSArray *titleArray = @[NSLocalizedString(@"银行卡管理", nil), NSLocalizedString(@"修改支付密码", nil), NSLocalizedString(@"忘记支付密码", nil)];
    
    for (NSInteger i = 0; i < titleArray.count; i++) {
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, i*60+10+IPhoneXTopHeight, SCREEN_WIDTH, 50)];
        backView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:backView];
        
        UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, backView.height)];
        titleL.text = titleArray[i];
        titleL.font = [UIFont systemFontOfSize:14];
        titleL.alpha = 0.8;
        [backView addSubview:titleL];
        
        UIImageView *iv = [[UIImageView alloc] init];
        iv.image = [UIImage imageNamed:@"list_right"];
        [iv sizeToFit];
        iv.center = CGPointMake(SCREEN_WIDTH-30, backView.height/2);
        [backView addSubview:iv];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, SCREEN_WIDTH, backView.height);
        btn.tag = i;
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:btn];
    }
}

- (void)clickBtn:(UIButton *)btn{
    NSInteger tag = btn.tag;
    DLog(@"%zd", tag);
    if (tag == 0) {//银行卡管理
        KDRMCardListController *clVC = [[KDRMCardListController alloc] init];
        [self pushViewController:clVC];
    }
    if (tag == 1) {//修改密码
        KDRMPassWordController *pwVC = [[KDRMPassWordController alloc] init];
        [self pushViewController:pwVC];
    }
    if (tag == 2) {//忘记密码
        KDRMGetCodeController *gcVC = [[KDRMGetCodeController alloc] init];
        gcVC.getCodeType = 1;
        [self pushViewController:gcVC];
    }
}

@end
