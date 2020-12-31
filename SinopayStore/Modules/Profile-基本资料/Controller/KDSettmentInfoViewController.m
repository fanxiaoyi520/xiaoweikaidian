//
//  KDSettmentInfoViewController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/4/27.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDSettmentInfoViewController.h"
#import "KDSettmentCardCell.h"
#import "KDSettmentSetController.h"
#import "KDAddSettmentCardController.h"
#import "KDAmountSettmentController.h"

@interface KDSettmentInfoViewController ()<UITableViewDelegate, UITableViewDataSource, SettmentCellDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *dataArray;
///结算类型 1 按比例   2 按交易金额
@property (nonatomic, assign)NSInteger settmentType;
///按比例结算选择的比例
@property (nonatomic, assign)NSInteger selectRate;
///按金额结算输入的金额
@property (nonatomic, strong)NSString *amount;
///按金额结算时金额类型
@property (nonatomic, assign)NSInteger amountType;
///选择更改的银行卡
@property (nonatomic, strong)KDSettmentCardModel *selectCard;

///pick遮罩
@property (nonatomic, strong)UIView *darkView;
///pick容器
@property (nonatomic, strong)UIView *contentView;

@end

@implementation KDSettmentInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.whiteNavTitle = NSLocalizedString(@"结算信息", nil);
    [self createView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
}

- (void)createView{
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightBtn.frame = CGRectMake(SCREEN_WIDTH-120, IPhoneXStatusBarHeight, 110, IPhoneNaviHeight);
    [rightBtn setTitle:NSLocalizedString(@"设置", nil) forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [rightBtn addTarget:self action:@selector(clickSetBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightBtn];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = GrayBgColor;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    [self createPickerView];
}

- (void)createPickerView{
    // 遮罩
    UIView *darkView = [[UIView alloc] init];
    darkView.alpha = 0.6;
    darkView.backgroundColor = ZFColor(46, 49, 50);
    darkView.frame = ZFSCREEN;
    darkView.hidden = YES;
    [self.view addSubview:darkView];
    self.darkView = darkView;
    
    // 容器视图
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 225)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    self.contentView = contentView;
    
    // 取消按钮
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];;
    cancelBtn.backgroundColor = [UIColor clearColor];
    [cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:cancelBtn];
    
    // 提示文字
    UILabel *tiplabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4, 0, SCREEN_WIDTH*0.75, 44)];
    tiplabel.text = NSLocalizedString(@"请设置结算比例", nil);
    tiplabel.textColor = UIColorFromRGB(0x313131);
    tiplabel.textAlignment = NSTextAlignmentCenter;
    tiplabel.font = [UIFont boldSystemFontOfSize:17.0];
    [contentView addSubview:tiplabel];
    
    // 确定按钮
    UIButton *ctBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-80, 0, 80, 44)];;
    ctBtn.backgroundColor = [UIColor clearColor];
    [ctBtn setTitleColor:MainThemeColor forState:UIControlStateNormal];
    [ctBtn setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    ctBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [ctBtn addTarget:self action:@selector(ctBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:ctBtn];
    
    // 分割线
    UIView *spliteView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, 1)];
    spliteView.backgroundColor = GrayBgColor;
    [contentView addSubview:spliteView];
    
    // 选择器
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 45, SCREEN_WIDTH, 200)];
    pickerView.backgroundColor = [UIColor whiteColor];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    [contentView addSubview:pickerView];
}

#pragma mark - tabledelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 145*(SCREEN_HEIGHT/667);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 50;
    
    if (_dataArray.count < 2) {
        return 20;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"settmentCell";
    KDSettmentCardCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[KDSettmentCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.settmentCardModel = [[KDSettmentCardModel alloc] init];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    footView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *addImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 16, 16)];
    addImage.image = [UIImage imageNamed:@"icon_addbank"];
    addImage.centerY = footView.height/2;
    [footView addSubview:addImage];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(addImage.right+10, 0, SCREEN_WIDTH-addImage.right-30, footView.height)];
    label.text = NSLocalizedString(@"添加银行卡", nil);
    label.font = [UIFont systemFontOfSize:15];
    label.alpha = 0.8;
    [footView addSubview:label];
    
    UIImageView *rightImage = [[UIImageView alloc] initWithFrame:CGRectMake(footView.width-40, 15, 20, 20)];
    rightImage.image = [UIImage imageNamed:@"icon_right_black"];
    [footView addSubview:rightImage];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
    [addBtn addTarget:self action:@selector(addBankCard) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:addBtn];
    return footView;
}

#pragma mark - pickView代理
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 10;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return SCREEN_WIDTH;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

// 选中的方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _selectRate = row;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    //设置分割线的颜色
    for(UIView *singleLine in pickerView.subviews)
    {
        if (singleLine.frame.size.height < 1)
        {
            singleLine.backgroundColor = ZFAlpColor(0, 0, 0, 0.3);
        }
    }
    //设置文字的属性
    UILabel *genderLabel = [UILabel new];
    genderLabel.textAlignment = NSTextAlignmentCenter;
    genderLabel.text = [NSString stringWithFormat:@"%ld%%", (row+1)*10];
    genderLabel.font = [UIFont systemFontOfSize:22.0];
    
    return genderLabel;
}

#pragma mark - SettmentCellDelegate
//更改结算类型
- (void)clickSetBtn{
    //    if (_dataArray.count < 2) {
    //        [XLAlertController acWithTitle:NSLocalizedString(@"请再添加一个结算账户后重试", nil) msg:@"" confirmBtnTitle:NSLocalizedString(@"确定", nil) cancleBtnTitle:NSLocalizedString(@"取消", nil) confirmAction:^(UIAlertAction *action) {
    //            KDAddSettmentCardController *ascVC = [[KDAddSettmentCardController alloc] init];
    //            [self pushViewController:ascVC];
    //        }];
    //    } else {
    KDSettmentSetController *ssVC = [[KDSettmentSetController alloc] init];
    ssVC.myBlock = ^(NSInteger settmentType) {
        DLog(@"%ld", (long)settmentType);
        if (settmentType != _settmentType) {
            _settmentType = settmentType;
            [_tableView reloadData];
        }
    };
    [self pushViewController:ssVC];
    //    }
    
}

//修改结算比例或金额
- (void)clickChangeBtnWith:(NSString *)tag{
    if (_settmentType == 1) {//按比例
        self.darkView.hidden = NO;
        [UIView animateWithDuration:0.5f animations:^{
            self.contentView.y = SCREEN_HEIGHT-225;
        }];
    }
    
    if (_settmentType == 2) {//按金额
        KDAmountSettmentController *asVC = [[KDAmountSettmentController alloc] init];
        asVC.amountBlock = ^(NSString *amount, NSInteger amountType) {
            DLog(@"amount=%@  type=%zd", amount, amountType);
        };
        [self pushViewController:asVC];
    }
    
}

//添加结算银行卡
- (void)addBankCard{
    KDAddSettmentCardController *ascVC = [[KDAddSettmentCardController alloc] init];
    [self pushViewController:ascVC];
}

// 取消选择
- (void)cancelBtnClicked {
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.contentView.y = SCREEN_HEIGHT;
                     }
                     completion:^(BOOL finished){
                         self.darkView.hidden = YES;
                     }];
}

// 确定选择
- (void)ctBtnClicked {
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.contentView.y = SCREEN_HEIGHT;
                     }
                     completion:^(BOOL finished){
                         self.darkView.hidden = YES;
                     }];
}

@end
