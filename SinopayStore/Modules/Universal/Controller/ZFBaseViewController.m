//
//  ZFBaseViewController.m
//  StatePay
//
//  Created by Jellyfish on 17/3/13.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

typedef void (^SaveImageBlock)(UIButton *sender);
@interface ZFBaseViewController () <UIGestureRecognizerDelegate>

@property (nonatomic ,copy)SaveImageBlock saveImageBlock;
@end

@implementation ZFBaseViewController


#pragma mark -- 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    // 添加向右滑动返回上一级页面手势
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setHidden:YES];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    // 子类没设置的话默认导航栏背景颜色:灰色
    //    [self.navigationController.navigationBar setBarTintColor:MainThemeColor];
    // 设置:基础页面统一隐藏导航栏下面的横线
    //    self.navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    //    // 默认隐藏导航栏下面的横线
    //    self.navBarHairlineImageView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.navigationController.viewControllers.count > 1) {
        // 添加向右滑动返回上一级页面手势
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    } else {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

#pragma mark -- 初始化方法
- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -- 给子类提供的方法
- (void)pushViewController:(UIViewController *)vc {
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)setNaviTitle:(NSString *)naviTitle {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, IPhoneXTopHeight)];
    bgView.backgroundColor = MainThemeColor;
    [self.view addSubview:bgView];
    // 返回按钮
    UIButton *closeBtn = [UIButton new];
    closeBtn.frame = CGRectMake(15, IPhoneXStatusBarHeight+(IPhoneNaviHeight-22)/2, 22, 22);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"icon_nav_return"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:closeBtn];
    
    // title
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(SCREEN_WIDTH*0.2, IPhoneXStatusBarHeight, SCREEN_WIDTH*0.6, IPhoneXTopHeight-IPhoneXStatusBarHeight);
    titleLabel.text = naviTitle;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:titleLabel];
}

- (void)setHomeNaviTitle:(NSString *)naviTitle {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, IPhoneXTopHeight)];
    bgView.backgroundColor = MainThemeColor;
    [self.view addSubview:bgView];
    
    // title
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(SCREEN_WIDTH*0.2, IPhoneXStatusBarHeight, SCREEN_WIDTH*0.6, IPhoneXTopHeight-IPhoneXStatusBarHeight);
    titleLabel.text = naviTitle;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    if ([naviTitle isEqualToString:NSLocalizedString(@"- 奖励金 -", nil)]) {
        titleLabel.font = [UIFont systemFontOfSize:18.0];
    }
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:titleLabel];
}

- (void)setWhiteNavTitle:(NSString *)whiteNavTitle{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, IPhoneXTopHeight)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    // 返回按钮
    UIButton *closeBtn = [UIButton new];
    closeBtn.frame = CGRectMake(15, IPhoneXStatusBarHeight+(IPhoneNaviHeight-22)/2, 22, 22);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"nav_return_black"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:closeBtn];
    
    // title
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(SCREEN_WIDTH*0.2, IPhoneXStatusBarHeight, SCREEN_WIDTH*0.6, IPhoneXTopHeight-IPhoneXStatusBarHeight);
    titleLabel.text = whiteNavTitle;
//    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:titleLabel];
}

- (void)setNaviAndRightTitle:(NSString *)naviTitle {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, IPhoneXTopHeight)];
    bgView.backgroundColor = MainThemeColor;
    [self.view addSubview:bgView];
    // 返回按钮
    UIButton *closeBtn = [UIButton new];
    closeBtn.frame = CGRectMake(15, IPhoneXStatusBarHeight+(IPhoneNaviHeight-22)/2, 22, 22);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"icon_nav_return"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:closeBtn];
    
    // title
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(SCREEN_WIDTH*0.2, IPhoneXStatusBarHeight, SCREEN_WIDTH*0.6, IPhoneXTopHeight-IPhoneXStatusBarHeight);
    titleLabel.text = naviTitle;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:titleLabel];
}

- (void)setNaviAndRightTitle:(NSString *)naviTitle rightBlock:(void (^)(UIButton *sender))rightBlock {
    self.saveImageBlock = rightBlock;
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, IPhoneXTopHeight)];
    bgView.backgroundColor = MainThemeColor;
    [self.view addSubview:bgView];
    // 返回按钮
    UIButton *closeBtn = [UIButton new];
    closeBtn.frame = CGRectMake(15, IPhoneXStatusBarHeight+(IPhoneNaviHeight-22)/2, 22, 22);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"icon_nav_return"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:closeBtn];
    
    // title
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(SCREEN_WIDTH*0.2, IPhoneXStatusBarHeight, SCREEN_WIDTH*0.6, IPhoneXTopHeight-IPhoneXStatusBarHeight);
    titleLabel.text = naviTitle;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:titleLabel];
    
    CGFloat width = [self getStringHeightWithText:NSLocalizedString(@"保存图片", nil) font:[UIFont systemFontOfSize:14] viewHeight:14];
    UIButton *rightBtn = [UIButton new];
    rightBtn.frame = CGRectMake(SCREEN_WIDTH-width-20, IPhoneXStatusBarHeight+(IPhoneNaviHeight-22)/2, width, 22);
    [rightBtn setTitle:NSLocalizedString(@"保存图片", nil) forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(savaImageAction:) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [bgView addSubview:rightBtn];
}

- (void)savaImageAction:(UIButton *)sender
{
    if (self.saveImageBlock) {
        self.saveImageBlock(sender);
    }
}

- (CGFloat)getStringHeightWithText:(NSString *)text font:(UIFont *)font viewHeight:(CGFloat)height {
    NSDictionary *attrs = @{NSFontAttributeName :font};
    CGSize maxSize = CGSizeMake(MAXFLOAT, height);
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGSize size = [text boundingRectWithSize:maxSize options:options attributes:attrs context:nil].size;
    return  ceilf(size.width);
}
@end
