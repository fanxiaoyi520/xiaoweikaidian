//
//  KDCashierMoreLanguageController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/1/3.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDCashierMoreLanguageController.h"
#import "NSBundle+Language.h"
#import "ZFTabBarViewController.h"

@interface KDCashierMoreLanguageController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, assign)NSInteger defaultIndex;
@property (nonatomic, assign)NSInteger originIndex;

@end

@implementation KDCashierMoreLanguageController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.naviTitle = NSLocalizedString(@"语言设置", nil);
    [self createView];
}

- (void)createView{
    //1 英语  2 汉语繁体 3 简体中文
    NSString *language = [NetworkEngine getCurrentLanguage];
    _defaultIndex = 0;
    if ([language isEqualToString:@"1"]) {//英语
        _defaultIndex = 2;
    }
    if ([language isEqualToString:@"2"]) {//繁体
        _defaultIndex = 1;
    }
    //记住原来的语言
    _originIndex = _defaultIndex;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightBtn.frame = CGRectMake(SCREEN_WIDTH-130, IPhoneXStatusBarHeight, 110, IPhoneNaviHeight);
    [rightBtn setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [rightBtn addTarget:self action:@selector(completeBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightBtn];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = GrayBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:_tableView];
}

- (void)completeBtn{
    if (_defaultIndex == _originIndex) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    NSString *language = @"zh-Hans";
    if (_defaultIndex == 1) {
        language = @"zh-Hant";
    }
    if (_defaultIndex == 2) {
        language = @"en";
    }
    [NSBundle setLanguage:language];
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:language, nil] forKey:@"AppleLanguages"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CHANGE_LANGUAGE object:nil];
    
    [self replaceTabVC];
}

- (void)replaceTabVC{
    ZFTabBarViewController *tabVC = [[ZFTabBarViewController alloc] initWithTabbarType:TabbarCashierType];
    tabVC.selectedIndex = 1;
    tabVC.tabBarController.tabBar.translucent = NO;
    // 动画
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.rootViewController = tabVC;
    UIView *toView;
    UIView *fromView;
    UIViewAnimationOptions option = UIViewAnimationOptionTransitionCrossDissolve;
    [UIView transitionWithView:window
                      duration:1.0f
                       options:option
                    animations:^ {
                        [fromView removeFromSuperview];
                        [window addSubview:toView];
                    }
                    completion:nil];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 20;
    }
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    NSString *str = @"简体中文";
    if (indexPath.section == 1) {
        str = @"繁體中文";
    }
    if (indexPath.section == 2) {
        str = @"English";
    }
    cell.textLabel.text = str;
    
    if (indexPath.section == _defaultIndex) {
        UIImageView *selectImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-40, 15, 20, 20)];
        selectImage.image = [UIImage imageNamed:@"other_select_language"];
        [cell addSubview:selectImage];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _defaultIndex = indexPath.section;
    [_tableView reloadData];
}

@end
