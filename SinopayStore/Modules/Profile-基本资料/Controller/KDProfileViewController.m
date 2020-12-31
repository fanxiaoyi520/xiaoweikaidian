//
//  KDProfileViewController.m
//  SinopayStore
//
//  Created by Jellyfish on 2017/12/4.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "KDProfileViewController.h"
#import "KDMerchantInfoViewController.h"
#import "ZFChangeLanguageController.h"
#import "KDOtherViewController.h"
#import "KDChangePWController.h"
#import "KDSettmentInfoViewController.h"
#import "KDPromoteWebController.h"
#import "KDCashierListController.h"

@interface KDProfileViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSArray *dataArray;
@property (nonatomic, strong)NSArray *imageArray;

///头像
@property (nonatomic, strong)UIImageView *headImage;
///商户名
@property (nonatomic, strong)UILabel *nameLabel;

@property (nonatomic, assign)NSInteger loginType;

@end

@implementation KDProfileViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    _loginType = [[NSUserDefaults standardUserDefaults] integerForKey:@"loginTypeBtn"];
    
    [self createHeadView];
    [self createView];
    [self setHomeNaviTitle:NSLocalizedString(@"基本资料", nil)];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _nameLabel.text = [ZFGlobleManager getGlobleManager].merName;
}

- (void)createHeadView{
    UIView *headBack = [[UIView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, 80)];
    headBack.backgroundColor = MainThemeColor;
    [self.view addSubview:headBack];
    
    _headImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 16, 48, 48)];
    _headImage.image = [UIImage imageNamed:@"list_icon_head_portrait"];
    [headBack addSubview:_headImage];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headImage.right+20, 0, SCREEN_WIDTH-_headImage.width-60, 80)];
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.font = [UIFont systemFontOfSize:15];
//    _nameLabel.text = @"Hello World";
    [headBack addSubview:_nameLabel];
    
    UIImageView *rightImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-37, 0, 17, 17)];
    rightImage.centerY = headBack.height/2;
    rightImage.image = [UIImage imageNamed:@"list_right"];
    [headBack addSubview:rightImage];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushToMerchInfo)];
    [headBack addGestureRecognizer:tap];
}

- (void)pushToMerchInfo{
    KDMerchantInfoViewController *mivc = [[KDMerchantInfoViewController alloc] init];
    [self pushViewController:mivc];
}

- (void)createView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight+80, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight-80) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = GrayBgColor;
    _tableView.scrollEnabled = NO;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:_tableView];
}

#pragma mark - UITableViewDataSource UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
        return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.imageView.image = [UIImage imageNamed:self.imageArray[indexPath.row]];
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DLog(@"%zd", indexPath.row);
    NSInteger index = indexPath.row;
    
    if (index == 0) {//修改密码
        KDChangePWController *pwVC = [[KDChangePWController alloc] init];
        [self pushViewController:pwVC];
    }
    if (_loginType == 2 && index > 0) {
        index += 1;
    }
    if (index == 1) {//收银员录入
        KDCashierListController *clVC = [[KDCashierListController alloc] init];
        [self pushViewController:clVC];
    }
    if (index == 2) {//推广有奖
        KDPromoteWebController *pwVC = [[KDPromoteWebController alloc] init];
        [self pushViewController:pwVC];
    }
    if (index == 3) {//多语言
        ZFChangeLanguageController *chVC = [[ZFChangeLanguageController alloc] init];
        [self pushViewController:chVC];
    }
    if (index == 4) {//其他
        KDOtherViewController *otVC = [[KDOtherViewController alloc] init];
        [self pushViewController:otVC];
    }
}

// 设置分割线偏移
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

#pragma mark - 懒加载
- (NSArray *)dataArray{
    //商户登录显示“收银员管理”
    _dataArray = [NSArray arrayWithObjects:NSLocalizedString(@"修改密码", nil), NSLocalizedString(@"推广有奖", nil), NSLocalizedString(@"多语言", nil),  NSLocalizedString(@"其他", nil), nil];
    if (_loginType == 0) {
        _dataArray = [NSArray arrayWithObjects:NSLocalizedString(@"修改密码", nil), NSLocalizedString(@"收银员管理", nil), NSLocalizedString(@"推广有奖", nil), NSLocalizedString(@"多语言", nil), NSLocalizedString(@"其他", nil), nil];
    }
    return _dataArray;
}

- (NSArray *)imageArray {
    if (!_imageArray) {
        _imageArray = [NSArray arrayWithObjects:@"list_password", @"list_popularize", @"list_languages", @"list_about", nil];
        if (_loginType == 0) {
            _imageArray = [NSArray arrayWithObjects:@"list_password", @"list_shouyinyuan", @"list_popularize", @"list_languages", @"list_about", nil];
        }
    }
    
    return _imageArray;
}

@end
