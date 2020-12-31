//
//  ZFTabBarViewController.m
//  SinopayStore
//
//  Created by Jellyfish on 2017/12/4.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFTabBarViewController.h"
#import "ZFNavigationController.h"
#import "KDQRCodeCollectionViewController.h"
#import "KDCollectionDetailsViewController.h"
#import "KDProfileViewController.h"

#import "KDCashierMainController.h"
#import "KDCashierProfileController.h"

@interface ZFTabBarViewController ()

@end

@implementation ZFTabBarViewController

#pragma mark - 生命周期
/**
 *  自定义UITabBarController
 */

- (instancetype)initWithTabbarType:(TabbarType)tabbarType{
    if (self = [super init]) {
        _tabbarType = tabbarType;
        if (_tabbarType == TabbarCashierType) {
            [self createCashierTabbar];
        } else {
            [self createMechantTabbar];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark 商户版
- (void)createMechantTabbar{
    KDQRCodeCollectionViewController *qrcode = [[KDQRCodeCollectionViewController alloc] init];
    [self addChildVc:qrcode Title:NSLocalizedString(@"我要收款", nil) Image:@"icon_shoukuan" selectedImage:@"icon_shoukuan_fill"];
    
    KDCollectionDetailsViewController *details = [[KDCollectionDetailsViewController alloc] init];
    [self addChildVc:details Title:NSLocalizedString(@"收款详情", nil) Image:@"icon_liushui" selectedImage:@"icon_liushui_fill"];
    
    KDProfileViewController *profile = [[KDProfileViewController alloc] init];
    [self addChildVc:profile Title:NSLocalizedString(@"基本资料", nil) Image:@"icon_mine" selectedImage:@"icon_mine_fill"];
}

#pragma mark 收银员版
- (void)createCashierTabbar{
    KDCashierMainController *cashierMain = [[KDCashierMainController alloc] init];
    [self addChildVc:cashierMain Title:NSLocalizedString(@"首页", nil) Image:@"icon_home" selectedImage:@"icon_home_fill"];
    
    KDCashierProfileController *profile = [[KDCashierProfileController alloc] init];
    [self addChildVc:profile Title:NSLocalizedString(@"我的", nil) Image:@"icon_my" selectedImage:@"icon_my_fill"];
}

#pragma mark - 方法
/**
 *  添加一个子控制器
 *
 *  @param childVc       子控制器
 *  @param title         名字
 *  @param image         图片
 *  @param selectedImage 选中时的图片
 */
- (void)addChildVc:(UIViewController *)childVc Title:(NSString *)title Image:(NSString *)image selectedImage:(NSString *)selectedImage {
    //设置子控制器的标题和图片
    // 同时设置tabbar和navigationBar的文字
    childVc.tabBarItem.title = title;
    childVc.tabBarItem.image = [UIImage imageNamed:image];
    childVc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 默认文字样式
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSFontAttributeName] = [UIFont fontWithName:@"Helvetica" size:12.0];
    textAttrs[NSForegroundColorAttributeName] = [UIColor grayColor];
    [childVc.tabBarItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    
    // 选中文字样式
    NSMutableDictionary *selectTextAttrs = [NSMutableDictionary dictionary];
    selectTextAttrs[NSFontAttributeName] = [UIFont fontWithName:@"Helvetica" size:12.0];
    selectTextAttrs[NSForegroundColorAttributeName] = MainThemeColor;
    [childVc.tabBarItem setTitleTextAttributes:selectTextAttrs forState:UIControlStateSelected];
    //    [childVc.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -3)];
    
    // 用自定义的导航控制器包装tabBarController每一个子控制器
    ZFNavigationController *navi = [[ZFNavigationController alloc] initWithRootViewController:childVc];
    
    // 添加为子控制器
    [self addChildViewController:navi];
}



@end
