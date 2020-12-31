//
//  KDSettmentSetController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/4/28.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDSettmentSetController.h"

@interface KDSettmentSetController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)UITableView *tableView;

@end

@implementation KDSettmentSetController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.whiteNavTitle = NSLocalizedString(@"结算设置", nil);
    [self createView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
}

- (void)createView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = GrayBgColor;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:_tableView];
}

#pragma mark tableviewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    NSString *str = NSLocalizedString(@"按比例结算", nil);
    NSString *imageName = @"settment_icon_bili";
    if (indexPath.row == 1) {
        str = NSLocalizedString(@"按交易金额结算", nil);
        imageName = @"settment_icon_jine";
    }
    cell.textLabel.text = str;
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.myBlock(indexPath.row+1);
    [self.navigationController popViewControllerAnimated:YES];
}


@end
