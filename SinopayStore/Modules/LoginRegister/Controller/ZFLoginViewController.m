//
//  ZFLoginViewController.m
//  SinopayStore
//
//  Created by 中付支付 on 2017/11/30.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFLoginViewController.h"
#import "ZFTabBarViewController.h"
#import "KDRegisterViewController.h"
#import "JPUSHService.h"
#import <CommonCrypto/CommonDigest.h>

#import "KDForgetPWController.h"
#import "KDAuthenticateViewController.h"
#import "KDCashierRigisterController.h"
#import "XLSwitchBtn.h"
#import "UniversallyUniqueIdentifier.h"
#import "KDAgencyHomeController.h"
#import "KDAddMerGetCodeController.h"
#import "ZFNavigationController.h"
#import "KDAddMerGetCodeController.h"

///收银员商户登陆加前缀
#define MerchantCashierPrefix @"syy"

@interface ZFLoginViewController () <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

///区号 手机号背景
@property (nonatomic, strong)UIView *textFieldBack;
///用户名
@property (nonatomic, strong)UITextField *userTextField;
///区号
@property (nonatomic, strong)ZFBaseTextField *areaTextField;
///收银员账号
@property (nonatomic, strong)ZFBaseTextField *cashierTextField;
///柜台号
@property (nonatomic, strong)ZFBaseTextField *counterTextField;
///代理号
//@property (nonatomic, strong)ZFBaseTextField *agencyTextField;
///切换手机号/收银员账号登录 按钮
@property (nonatomic, strong)UIButton *changeBtn;
///改变登陆按钮的底部视图
@property (nonatomic, strong)UIView *changeBtnBack;

/// 支持的手机号码国家/地区代码
@property(nonatomic,strong) NSMutableArray *areaArray;
///区域选择
@property(nonatomic,strong) UIPickerView *pickerView;
///区域工具栏
@property(nonatomic,strong) UIToolbar *toolbar;

@property (nonatomic, strong) NSString *securityKey;
@property (nonatomic, strong) NSString *tempSessionID;

///
@property (nonatomic, strong)UIButton *registerBtn;
@property (nonatomic, strong)UIButton *loginBtn;
@property (nonatomic, strong)UIButton *codeLoginBtn;
@property (nonatomic, strong)UIButton *forgetBtn;
@property (nonatomic, strong)UIImageView *topImageView;

@property (nonatomic, strong)UIButton *cancelBtn;
@property (nonatomic, strong)UIButton *confirmBtn;

/** 切换按钮背景视图 */
@property(nonatomic, weak) UIView *switchView;
/** 登录类型按钮 */
@property (nonatomic, weak) UIButton *currentSelectedBtn;

///登录类型
@property (nonatomic, assign)TabbarType tabbarType;

@property (nonatomic, strong) NSString *alias;
@property (nonatomic, assign)NSInteger aliasCount;

@end

@implementation ZFLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //默认商户类型
    _tabbarType = [[NSUserDefaults standardUserDefaults] integerForKey:@"loginTypeBtn"];
    if (!_tabbarType) {
        _tabbarType = TabbarMerchantType;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadInfo) name:CHANGE_LANGUAGE object:nil];
    [self createView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //登录状态置为0
    [ZFGlobleManager getGlobleManager].loginStatus = 0;
}

#pragma mark 改变语言 重新加载数据
- (void)reloadInfo{
//    _topImageView.image = [UIImage imageNamed:NSLocalizedString(@"pic_signin_logo_chinese", @"登录顶部图片")];
    _userTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"请输入手机号", nil) attributes:@{NSForegroundColorAttributeName: ZFAlpColor(255, 255, 255, 0.8)}];
    _pwdTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"请输入密码", nil) attributes:@{NSForegroundColorAttributeName: ZFAlpColor(255, 255, 255, 0.8)}];
    [_loginBtn setTitle:NSLocalizedString(@"登录", nil) forState:UIControlStateNormal];
    [_registerBtn setTitle:NSLocalizedString(@"商户注册", nil) forState:UIControlStateNormal];
    if (_tabbarType == TabbarCashierType) {
        [_registerBtn setTitle:NSLocalizedString(@"收银员注册", nil) forState:UIControlStateNormal];
    }
    [_forgetBtn setTitle:NSLocalizedString(@"忘记密码", nil) forState:UIControlStateNormal];
    [_cancelBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [_confirmBtn setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
    
    [_switchView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setupSwitchBtn];
    
    _cashierTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"收银员账号", nil) attributes:@{NSForegroundColorAttributeName: ZFAlpColor(255, 255, 255, 0.8)}];
    _counterTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"请输入POS号", nil) attributes:@{NSForegroundColorAttributeName: ZFAlpColor(255, 255, 255, 0.8)}];
    [_changeBtn setTitle:NSLocalizedString(@"使用账号登陆", nil) forState:UIControlStateNormal];
    [_changeBtn setTitle:NSLocalizedString(@"使用手机号登陆", nil) forState:UIControlStateSelected];
    
    [self getCountryCode:2];
}

#pragma mark - 初始化视图
- (void)createView {
    // 渐变背景图片
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:ZFSCREEN];
    bgView.userInteractionEnabled = YES;
    bgView.image = [UIImage imageNamed:@"pic_signin_background"];
    [self.view addSubview:bgView];
    CGFloat diffHeight = 0;
    if (SCREEN_HEIGHT < 580) {//适配5s
        diffHeight = 20;
    }
    _topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3, IPhoneXTopHeight-diffHeight, SCREEN_WIDTH/3, SCREEN_WIDTH/3-diffHeight)];
    _topImageView.image = [UIImage imageNamed:@"pic_signin_logo_chinese"];
    [bgView addSubview:_topImageView];
    
    // 切换按钮背景视图
    UIView *switchView = [[UIView alloc] initWithFrame:CGRectMake(20, _topImageView.bottom+30, SCREEN_WIDTH-40, 40)];
    [bgView addSubview:switchView];
    self.switchView = switchView;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, switchView.bottom-3, SCREEN_WIDTH-40, 3)];
    lineView.layer.cornerRadius = 3.0f;
    lineView.backgroundColor = ZFAlpColor(255, 255, 255, 0.2);
    [bgView addSubview:lineView];
    
    // 切换按钮
    [self setupSwitchBtn];
    
    //区号 手机号背景
    _textFieldBack = [[UIView alloc] initWithFrame:CGRectMake(20, switchView.bottom+25, SCREEN_WIDTH-40, 40)];
    _textFieldBack.backgroundColor = ZFColor(104, 183, 212);
    _textFieldBack.layer.cornerRadius = 5;
    [bgView addSubview:_textFieldBack];
    
    //区号
    _areaTextField = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    _areaTextField.text = @"+86";
    _areaTextField.textColor = [UIColor whiteColor];
    _areaTextField.backgroundColor = ZFColor(104, 183, 212);
    _areaTextField.textAlignment = NSTextAlignmentLeft;
    _areaTextField.delegate = self;
    [_textFieldBack addSubview:_areaTextField];
    
    UIButton *telBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15, 40)];
    [telBtn setImage:[UIImage imageNamed:@"icon_tel_drop"] forState:UIControlStateNormal];
    [telBtn setImage:[UIImage imageNamed:@"icon_tel_drop"] forState:UIControlStateSelected];
    _areaTextField.rightViewMode = UITextFieldViewModeAlways;
    _areaTextField.rightView = telBtn;
    
    //手机号
    _userTextField = [[UITextField alloc] initWithFrame:CGRectMake(_areaTextField.right+5, _areaTextField.y, _textFieldBack.width-_areaTextField.width-5, 40)];
    _userTextField.textColor = [UIColor whiteColor];
    _userTextField.font = [UIFont systemFontOfSize:17.0];
    _userTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"请输入手机号", nil) attributes:@{NSForegroundColorAttributeName: ZFAlpColor(255, 255, 255, 0.8)}];
    _userTextField.delegate = self;
    _userTextField.keyboardType = UIKeyboardTypeNumberPad;
    _userTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_textFieldBack addSubview:_userTextField];
    //手机号
    NSString *phoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"];
    _userTextField.text = phoneNum;
    
    NSString *areaNum = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"areaNum%@", phoneNum]];
    if (areaNum) {
        _areaTextField.text = areaNum;
    }
    
    //收银员账号
    _cashierTextField = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(20, switchView.bottom+25, SCREEN_WIDTH-40, 40)];
    _cashierTextField.textColor = [UIColor whiteColor];
    _cashierTextField.font = [UIFont systemFontOfSize:17];
    _cashierTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"收银员账号", nil) attributes:@{NSForegroundColorAttributeName: ZFAlpColor(255, 255, 255, 0.8)}];
    _cashierTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _cashierTextField.keyboardType = UIKeyboardTypeEmailAddress;
    _cashierTextField.delegate = self;
    _cashierTextField.hidden = YES;
    _cashierTextField.backgroundColor = ZFColor(104, 183, 212);
    [_cashierTextField limitTextLength:20];
    [self.view addSubview:_cashierTextField];
    
    //代理账号
//    _agencyTextField = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(20, switchView.bottom+25, SCREEN_WIDTH-40, 40)];
//    _agencyTextField.textColor = [UIColor whiteColor];
//    _agencyTextField.font = [UIFont systemFontOfSize:17];
//    _agencyTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Osas代理账号", nil) attributes:@{NSForegroundColorAttributeName: ZFAlpColor(255, 255, 255, 0.8)}];
//    _agencyTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
//    _agencyTextField.keyboardType = UIKeyboardTypeEmailAddress;
//    _agencyTextField.delegate = self;
//    _agencyTextField.hidden = YES;
//    _agencyTextField.backgroundColor = ZFColor(104, 183, 212);
//    [_agencyTextField limitTextLength:20];
//    [self.view addSubview:_agencyTextField];
    
    //密码
    _pwdTextField = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(_textFieldBack.x, _textFieldBack.bottom+10, _textFieldBack.width, _textFieldBack.height)];
    _pwdTextField.textColor = [UIColor whiteColor];
    _pwdTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"请输入密码", nil) attributes:@{NSForegroundColorAttributeName: ZFAlpColor(255, 255, 255, 0.8)}];
    _pwdTextField.font = [UIFont systemFontOfSize:17.0];
    _pwdTextField.backgroundColor = ZFColor(104, 183, 212);
    _pwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _pwdTextField.delegate = self;
    _pwdTextField.secureTextEntry = YES;
    _pwdTextField.returnKeyType = UIReturnKeyDone;
    _pwdTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_pwdTextField limitTextLength:6];
    
    // 显示密码
    UIView *rightView = [[UIView alloc] init];
    rightView.size = CGSizeMake(34, 24);
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 24, 24);
    [btn addTarget:self action:@selector(showOrHidPwd:) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:[UIImage imageNamed:@"showpassword_no"] forState:UIControlStateNormal];
    [rightView addSubview:btn];
    _pwdTextField.rightViewMode = UITextFieldViewModeAlways;
    _pwdTextField.rightView = rightView;
    [bgView addSubview:_pwdTextField];
    
    
    //柜台号
    _counterTextField = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(_pwdTextField.x, _pwdTextField.bottom+20, _pwdTextField.width, _pwdTextField.height)];
    _counterTextField.textColor = [UIColor whiteColor];
    _counterTextField.font = [UIFont systemFontOfSize:17];
    _counterTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"请输入POS号", nil) attributes:@{NSForegroundColorAttributeName: ZFAlpColor(255, 255, 255, 0.8)}];
    _counterTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _counterTextField.keyboardType = UIKeyboardTypeEmailAddress;
    _counterTextField.delegate = self;
    _counterTextField.hidden = YES;
    _counterTextField.backgroundColor = ZFColor(104, 183, 212);
    [_counterTextField limitTextLength:20];
    [self.view addSubview:_counterTextField];
    
    //登录
    _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH-40, 40);
    _loginBtn.center = CGPointMake(SCREEN_WIDTH/2, _pwdTextField.bottom+50);
    _loginBtn.layer.cornerRadius = 5.0;
    _loginBtn.layer.borderWidth = 1.0;
    _loginBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    [_loginBtn setTitle:NSLocalizedString(@"登录", nil) forState:UIControlStateNormal];
    [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginBtn setTitleColor:ZFAlpColor(255, 255, 255, 0.7) forState:UIControlStateHighlighted];
    _loginBtn.backgroundColor = [UIColor clearColor];
    [_loginBtn addTarget:self action:@selector(clickLoginBtn) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:_loginBtn];
    
    //注册按钮
    _registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _registerBtn.frame = CGRectMake(30, _loginBtn.bottom+20, 140, 30);
    [_registerBtn setTitle:NSLocalizedString(@"商户注册", nil) forState:UIControlStateNormal];
    if (_tabbarType == TabbarCashierType) {
        [_registerBtn setTitle:NSLocalizedString(@"收银员注册", nil) forState:UIControlStateNormal];
    }
    if (_tabbarType == TabbarAgencyType) {
        [_registerBtn setTitle:NSLocalizedString(@"代理注册", nil) forState:UIControlStateNormal];
    }
    _registerBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_registerBtn setTitleColor:ZFAlpColor(255, 255, 255, 0.7) forState:UIControlStateHighlighted];
    _registerBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_registerBtn addTarget:self action:@selector(clickRegisterBtn) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:_registerBtn];
    
    //忘记密码
    _forgetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _forgetBtn.frame =  CGRectMake(SCREEN_WIDTH-150, _loginBtn.bottom+20, 120, 30);
    [_forgetBtn setTitle:NSLocalizedString(@"忘记密码", nil) forState:UIControlStateNormal];
    _forgetBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _forgetBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_forgetBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_forgetBtn setTitleColor:ZFAlpColor(255, 255, 255, 0.7) forState:UIControlStateHighlighted];
    [_forgetBtn addTarget:self action:@selector(forgetPwdBtn) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:_forgetBtn];
    
    //底部两条横线
    _changeBtnBack = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-80+diffHeight, SCREEN_WIDTH, 30)];
    [self.view addSubview:_changeBtnBack];
    
    UIView *leftLine = [[UIView alloc] initWithFrame:CGRectMake(40, 15, 50, 1)];
    leftLine.backgroundColor = [UIColor whiteColor];
    leftLine.alpha = 0.7;
    [_changeBtnBack addSubview:leftLine];
    
    UIView *rightLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-90, leftLine.y, 50, 1)];
    rightLine.backgroundColor = [UIColor whiteColor];
    rightLine.alpha = 0.7;
    [_changeBtnBack addSubview:rightLine];
    
    //切换手机号收银员账号登录按钮
    _changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _changeBtn.frame = CGRectMake(90, 0, SCREEN_WIDTH-180, 30);
    _changeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_changeBtn setTitle:NSLocalizedString(@"使用账号登陆", nil) forState:UIControlStateNormal];
    [_changeBtn setTitle:NSLocalizedString(@"使用手机号登陆", nil) forState:UIControlStateSelected];
    [_changeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_changeBtn addTarget:self action:@selector(changeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_changeBtnBack addSubview:_changeBtn];
    _changeBtn.selected = _tabbarType == TabbarMerchantCashierType;
    
    [self changeView];
    
    _areaArray = [[NSMutableArray alloc] init];
    _areaArray = [[ZFGlobleManager getGlobleManager] getAreaNumArray];
    
    if (_tabbarType == TabbarMerchantCashierType) {
        [self checkAutoLogin];
    } else {
        [self getCountryCode:1];
    }
    [self createPickView];
}

- (void)changeBtnClick{
    _changeBtn.selected = !_changeBtn.selected;
    _tabbarType = _changeBtn.selected ? TabbarMerchantCashierType:TabbarMerchantType;
    [self changeView];
    _pwdTextField.text = @"";
}

- (void)setupSwitchBtn {
    
    for (int i = 0; i < 3; i++) {
        XLSwitchBtn *loginTypeBtn = [[XLSwitchBtn alloc] init];
        NSString *title = @"";
        loginTypeBtn.tag = i;
        if (i == 0) {
            title = NSLocalizedString(@"商户", nil);
            if (_tabbarType == TabbarMerchantType || _tabbarType == TabbarMerchantCashierType) {
                loginTypeBtn.selected = YES;
                self.currentSelectedBtn = loginTypeBtn;
            }
        } else if (i == 1) {
            if (_tabbarType == TabbarCashierType) {
                loginTypeBtn.selected = YES;
                self.currentSelectedBtn = loginTypeBtn;
            }
            title = NSLocalizedString(@"收银员", nil);;
        } else {
            if (_tabbarType == TabbarAgencyType) {
                loginTypeBtn.selected = YES;
                self.currentSelectedBtn = loginTypeBtn;
            }
            title = NSLocalizedString(@"代理", nil);
        }
        
        loginTypeBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [loginTypeBtn setTitle:title forState:UIControlStateNormal];
        [loginTypeBtn setTitleColor:ZFAlpColor(255, 255, 255, 0.6) forState:UIControlStateNormal];
        [loginTypeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [loginTypeBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [loginTypeBtn setBackgroundImage:[UIImage imageNamed:@"pic_white_line"] forState:UIControlStateSelected];
        loginTypeBtn.frame = CGRectMake(i*(self.switchView.width)*0.33, 0, (self.switchView.width)*0.33, 40);
        [loginTypeBtn addTarget:self action:@selector(loginTypeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.switchView addSubview:loginTypeBtn];
    }
}

//显示/隐藏输入框
- (void)changeView{
    _registerBtn.hidden = NO;
//    _agencyTextField.hidden = YES;
//    _textFieldBack.hidden = YES;
    _cashierTextField.hidden = YES;
    _counterTextField.hidden = YES;
    _changeBtnBack.hidden = YES;
    _loginBtn.center = CGPointMake(SCREEN_WIDTH/2, _pwdTextField.bottom+50);
    
    _pwdTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_pwdTextField limitTextLength:6];
    
    if (_tabbarType == TabbarMerchantType || _tabbarType == TabbarCashierType) {//商户手机号登陆、收银员登陆
        _textFieldBack.hidden = NO;
        if (_tabbarType == TabbarMerchantType) {
            _changeBtnBack.hidden = NO;
        }
    }
    
    if (_tabbarType == TabbarMerchantCashierType) {
        _cashierTextField.hidden = NO;
        _counterTextField.hidden = NO;
        _changeBtnBack.hidden = NO;
        _loginBtn.center = CGPointMake(SCREEN_WIDTH/2, _pwdTextField.bottom+110);
    }
    
    if (_tabbarType == TabbarAgencyType) {
//        _agencyTextField.hidden = NO;
        _registerBtn.hidden = YES;
        _pwdTextField.keyboardType = UIKeyboardTypeEmailAddress;
        [_pwdTextField limitTextLength:20];
    }
    
    _registerBtn.y = _loginBtn.bottom+20;
    _forgetBtn.y =  _loginBtn.bottom+20;
}

- (void)createPickView{
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 220)];
    self.pickerView.backgroundColor = [UIColor whiteColor];
    
    // 代理
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    UIView *toolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    toolView.backgroundColor = GrayBgColor;
    
    _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
    [_cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_cancelBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [_cancelBtn addTarget:self action:@selector(hidePickView) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:_cancelBtn];
    
    _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-80, 0, 80, 44)];
    [_confirmBtn setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
    [_confirmBtn addTarget:self action:@selector(hidePickView) forControlEvents:UIControlEventTouchUpInside];
    [_confirmBtn setTitleColor:MainThemeColor forState:UIControlStateNormal];
    _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [toolView addSubview:_confirmBtn];
    
    self.areaTextField.delegate = self;
    self.areaTextField.inputView = _pickerView;
    self.areaTextField.inputAccessoryView = toolView;
    self.areaTextField.tintColor = [UIColor clearColor];
}

- (void)hidePickView{
    [_areaTextField resignFirstResponder];
}

- (void)showOrHidPwd:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [btn setBackgroundImage:[UIImage imageNamed:@"showpassword_yes"] forState:UIControlStateNormal];
        _pwdTextField.secureTextEntry = NO;
    } else {
        [btn setBackgroundImage:[UIImage imageNamed:@"showpassword_no"] forState:UIControlStateNormal];
        _pwdTextField.secureTextEntry = YES;
    }
}

#pragma mark 获取手机区号
- (void)getCountryCode:(NSInteger)flag{
    
    NSDictionary *parameters = @{@"txnType": @"15"};
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            NSArray *countryArr = [requestResult objectForKey:@"list"];
            NSMutableArray *areaArray = [[NSMutableArray alloc] init];
            
            NSString *language = [NetworkEngine getCurrentLanguage];
            NSString *languageDesc = @"chnDesc";//简体
            if ([language isEqualToString:@"1"]) {
                languageDesc = @"engDesc";//英文
            }
            if ([language isEqualToString:@"2"]) {
                languageDesc = @"fonDesc";//繁体
            }
            
            for (NSDictionary *dict in countryArr) {
                NSString *str = [NSString stringWithFormat:@"%@+%@", [dict objectForKey:languageDesc], [dict objectForKey:@"countryCode"]];
                [areaArray addObject:str];
            }
            _areaArray = areaArray;
            
            //把区号保存到本地 防止下次无网络列表空白
            [[ZFGlobleManager getGlobleManager] saveAreaNumArray:_areaArray];
            
            [_pickerView reloadAllComponents];
            NSString *countryStr = [NSString stringWithFormat:@"+%@", [[_areaArray[0] componentsSeparatedByString:@"+"] lastObject]];
            NSString *phoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"];
            NSString *areaNum = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"areaNum%@", phoneNum]];
            if (areaNum) {
                countryStr = areaNum;
            }
            _areaTextField.text = countryStr;
            
            if (flag == 1) {
                [self checkAutoLogin];
            }
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark 检测是否可以自动登录
- (void)checkAutoLogin{
    NSString *phoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"];
    NSString *cashierNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"cashierNum"];
//    NSString *agencyNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"agencyNum"];
    
    NSString *pwdStr = [[ZFGlobleManager getGlobleManager] getLoginPwd];
    NSString *areaNum = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"areaNum%@", phoneNum]];
    
    NSString *counterNum = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"counterCode%@", cashierNum]];
    
    if (_tabbarType == TabbarMerchantCashierType) {
        _cashierTextField.text = cashierNum;
        _pwdTextField.text = pwdStr;
        _counterTextField.text = counterNum;
        
        if (phoneNum && pwdStr && pwdStr.length == 6 && counterNum) {
            [self getTempSessionID];
        }
        return;
    }
    
    if (_tabbarType == TabbarAgencyType) {
//        _agencyTextField.text = agencyNum;
        _areaTextField.text = areaNum;
        _userTextField.text = phoneNum;
        _pwdTextField.text = pwdStr;
        return;
    }
    
    if (phoneNum && pwdStr && pwdStr.length == 6 && areaNum) {
        _areaTextField.text = areaNum;
        _userTextField.text = phoneNum;
        _pwdTextField.text = pwdStr;
        
        [self getTempSessionID];
    }
}


#pragma mark ----- 点击方法
// 选择登录类型
- (void)loginTypeBtnClicked:(UIButton *)sender {
    
    if (sender != self.currentSelectedBtn) {
        self.currentSelectedBtn.selected = NO;
        self.currentSelectedBtn = sender;
    } else {
        return;
    }
    self.currentSelectedBtn.selected = YES;
    
    _pwdTextField.text = @"";
    
    NSInteger tag = sender.tag;
    
    if (tag == 0) {
        [_registerBtn setTitle:NSLocalizedString(@"商户注册", nil) forState:UIControlStateNormal];
        _tabbarType = _changeBtn.selected ? TabbarMerchantCashierType:TabbarMerchantType;
    } else if (tag == 1) {
        [_registerBtn setTitle:NSLocalizedString(@"收银员注册", nil) forState:UIControlStateNormal];
        _tabbarType = TabbarCashierType;
    } else {
        [_registerBtn setTitle:NSLocalizedString(@"代理注册", nil) forState:UIControlStateNormal];
        _tabbarType = TabbarAgencyType;
    }
    [self changeView];
}

#pragma mark 登录
- (void)clickLoginBtn{
    [self.view endEditing:YES];
    
    //代理登录
    if (_tabbarType == TabbarAgencyType) {
        [self agencyLoginRequest];
        return;
    }
    
    [self getTempSessionID];
}

#pragma mark 注册
- (void)clickRegisterBtn{
    //test
//    KDAuthenticateViewController *aVC = [[KDAuthenticateViewController alloc] init];
//    [self pushViewController:aVC];
//    return;
    DLog(@"click register");
    if (_tabbarType == TabbarCashierType) {//收银员注册
        KDCashierRigisterController *cashierVC = [[KDCashierRigisterController alloc] init];
        [self pushViewController:cashierVC];
    } else if (_tabbarType == TabbarAgencyType) {//代理商注册
        [ZFGlobleManager getGlobleManager].agentAddType = 0;
        KDAddMerGetCodeController *addAgentVC = [[KDAddMerGetCodeController alloc] init];
        addAgentVC.codeType = 2;
        [self pushViewController:addAgentVC];
    } else {//商户注册
        KDRegisterViewController *regiVC = [[KDRegisterViewController alloc] init];
        [self pushViewController:regiVC];
    }
}

#pragma mark 忘记密码
- (void)forgetPwdBtn{
    if (_tabbarType == TabbarAgencyType) {
        KDAddMerGetCodeController *gcVC = [[KDAddMerGetCodeController alloc] init];
        gcVC.codeType = 1;
        [self pushViewController:gcVC];
        
//        KDAgencyFogetPWController *afpVC = [[KDAgencyFogetPWController alloc] init];
//        [self pushViewController:afpVC];
        return;
    }
    
    if (_tabbarType == TabbarCashierType) {
        KDForgetPWController *forgetVC = [[KDForgetPWController alloc] init];
        forgetVC.forgetType = 1;
        [self pushViewController:forgetVC];
        
//        KDCashierForgetPWController *cashierVC = [[KDCashierForgetPWController alloc] init];
//        [self pushViewController:cashierVC];
    } else {
        KDForgetPWController *forgetVC = [[KDForgetPWController alloc] init];
        [self pushViewController:forgetVC];
    }
}

#pragma mark 校验信息
-(BOOL)userInputIsRight{
    NSString *moblie = self.userTextField.text;
    NSString *password = self.pwdTextField.text;
    
    if (_tabbarType == TabbarMerchantCashierType) {
        if (_cashierTextField.text.length < 1) {
            [[MBUtils sharedInstance] showMBFailedWithText:NSLocalizedString(@"请输入收银员账号", nil) inView:self.view];
            return NO;
        }
        if (password.length == 0) {
            [[MBUtils sharedInstance] showMBFailedWithText:NSLocalizedString(@"请输入密码", nil) inView:self.view];
            return NO;
        }
        if(password.length != 6){
            [[MBUtils sharedInstance] showMBFailedWithText:NSLocalizedString(@"密码输入错误", nil) inView:self.view];
            return NO;
        }
        if (_counterTextField.text.length < 1) {
            [[MBUtils sharedInstance] showMBFailedWithText:NSLocalizedString(@"请输入POS号", nil) inView:self.view];
            return NO;
        }
        
        return YES;
    }
    
    if (_tabbarType == TabbarAgencyType) {
//        NSString *agency = _agencyTextField.text;
        if (_areaTextField.text.length < 1) {
            [[MBUtils sharedInstance] showMBFailedWithText:NSLocalizedString(@"请选择区号", nil) inView:self.view];
            return NO;
        }
        
        if (moblie.length < 1) {
            [[MBUtils sharedInstance] showMBFailedWithText:NSLocalizedString(@"请输入Osas代理账号", nil) inView:self.view];
            return NO;
        }
        
        if (password.length == 0) {
            [[MBUtils sharedInstance] showMBFailedWithText:NSLocalizedString(@"请输入密码", nil) inView:self.view];
            return NO;
        }
        
        return YES;
    }
    
    //防止复制通讯录里面的号码出现bug
    moblie = [moblie stringByReplacingOccurrencesOfString:@"\\p{Cf}" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, moblie.length)];
    moblie = [moblie stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.userTextField.text = moblie;
    
    NSString *errorMessage = @"";
    if (_areaTextField.text.length < 1) {
        errorMessage = NSLocalizedString(@"请选择区号", nil);
        [[MBUtils sharedInstance] showMBFailedWithText:errorMessage inView:self.view];
        return NO;
    }
    
    if (!moblie || moblie.length == 0) {
        errorMessage = NSLocalizedString(@"请输入手机号", nil);
        [[MBUtils sharedInstance] showMBFailedWithText:errorMessage inView:self.view];
        return NO;
    }
    
    if (moblie.length > 11 || moblie.length < 7) {
        errorMessage = NSLocalizedString(@"手机号码有误", nil);
        [[MBUtils sharedInstance] showMBFailedWithText:errorMessage inView:self.view];
        return NO;
    }
    
    if (password.length == 0) {
        errorMessage = NSLocalizedString(@"请输入密码", nil);
        [[MBUtils sharedInstance] showMBFailedWithText:errorMessage inView:self.view];
        return NO;
    }
    
    if(password.length != 6){
        errorMessage = NSLocalizedString(@"密码输入错误", nil);
        [[MBUtils sharedInstance] showMBFailedWithText:errorMessage inView:self.view];
        return NO;
    }
    
    return YES;
}

#pragma mark 获取临时sessionID
- (void)getTempSessionID{
    if (![self userInputIsRight]) {
        return;
    }
    
    NSString *countryCode = [[_areaTextField.text componentsSeparatedByString:@"+"] lastObject];
    
    NSString *userNum = _userTextField.text;
    
    NSString *txnType = @"01";
    if (_tabbarType == TabbarCashierType) {
        txnType = @"36";
    }
    
    if (_tabbarType == TabbarMerchantCashierType) {
        countryCode = @"86";
        userNum = [NSString stringWithFormat:@"%@%@", MerchantCashierPrefix, _cashierTextField.text];
    }
    
    NSDictionary *dict = @{@"countryCode":countryCode,
                           @"mobile":userNum,
                           @"txnType":txnType
                           };
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
//            [[MBUtils sharedInstance] dismissMB];
            [ZFGlobleManager getGlobleManager].tempSessionID = [requestResult objectForKey:@"sessionID"];
            NSString *tempSecurityKey = [[HBRSAHandler sharedInstance] decryptWithPrivateKey:[requestResult objectForKey:@"securityKey"]];
            [ZFGlobleManager getGlobleManager].tempSecurityKey = tempSecurityKey;
            
            [self loginRequest];
            
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark 登录
- (void)loginRequest{
    NSString *countryCode = [[_areaTextField.text componentsSeparatedByString:@"+"] lastObject];
    
    //用户名 手机号或收银员号
    NSString *userNum = _userTextField.text;
    //柜台号
    NSString *counterNum = @"";
    
    if (_tabbarType == TabbarMerchantCashierType) {
        countryCode = @"86";
        userNum = [NSString stringWithFormat:@"%@%@", MerchantCashierPrefix, _cashierTextField.text];
        counterNum = _counterTextField.text;
    }
    
    NSString *tempSecurityKey = [ZFGlobleManager getGlobleManager].tempSecurityKey;
    NSString *encryPwd = [TripleDESUtils getEncryptWithString:_pwdTextField.text keyString:tempSecurityKey ivString:TRIPLEDES_IV];
    
    NSString *MD5Data = [[HBRSAHandler sharedInstance] encryptWithPublicKey:tempSecurityKey];
    MD5Data = [MD5Data stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    MD5Data = [MD5Data stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    _alias = [self MD5ForLower32Bate:[_userTextField.text stringByAppendingString:Alias_DeviceID]];
    
    NSString *txnType = @"04";
    if (_tabbarType == TabbarCashierType) {
        txnType = @"39";
    }
    
    NSDictionary *dict = @{@"countryCode":countryCode,
                           @"mobile":userNum,
                           @"sessionID":[ZFGlobleManager getGlobleManager].tempSessionID,
                           @"password":encryPwd,
                           @"MD5Data":MD5Data,
                           @"alias":_alias,
                           @"counterCode":counterNum,
                           @"txnType":txnType
                           };
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] dismissMB];
            [ZFGlobleManager getGlobleManager].sessionID = [requestResult objectForKey:@"sessionID"];
            // 此处的处理与获取临时securityKey时不同，此处使用3DES解密，解密的key为tempSecurityKey）
            NSString *securityKey = [TripleDESUtils getDecryptWithString:[requestResult objectForKey:@"securityKey"] keyString: tempSecurityKey ivString: TRIPLEDES_IV];
            [ZFGlobleManager getGlobleManager].securityKey = securityKey;
            [ZFGlobleManager getGlobleManager].sessionID = [requestResult objectForKey:@"sessionID"];
            [ZFGlobleManager getGlobleManager].areaNum = countryCode;
            [ZFGlobleManager getGlobleManager].userPhone = userNum;
            [ZFGlobleManager getGlobleManager].fillingStatus = [requestResult objectForKey:@"fillingStatus"];
            [ZFGlobleManager getGlobleManager].merName = [requestResult objectForKey:@"merName"];
            [ZFGlobleManager getGlobleManager].merShortName = [requestResult objectForKey:@"merShortName"];
            [ZFGlobleManager getGlobleManager].merID = [requestResult objectForKey:@"merID"];
            [ZFGlobleManager getGlobleManager].terID = [requestResult objectForKey:@"terID"];
            [ZFGlobleManager getGlobleManager].termCode = [requestResult objectForKey:@"termCode"];
            [ZFGlobleManager getGlobleManager].email = [requestResult objectForKey:@"email"];
            [ZFGlobleManager getGlobleManager].merTxnCurr = [requestResult objectForKey:@"merTxnCurr"];
            
            [ZFGlobleManager getGlobleManager].alipayTotalSwitch = [requestResult objectForKey:@"alipayTotalSwitch"];
            [ZFGlobleManager getGlobleManager].unionpayTotalSwitch = [requestResult objectForKey:@"unionpayTotalSwitch"];
            [ZFGlobleManager getGlobleManager].unionpayScan = [requestResult objectForKey:@"unionpayScan"];
            [ZFGlobleManager getGlobleManager].unionpayMicro = [requestResult objectForKey:@"unionpayMicro"];
            [ZFGlobleManager getGlobleManager].unionpayStatic = [requestResult objectForKey:@"unionpayStatic"];
            [ZFGlobleManager getGlobleManager].alipayScan = [requestResult objectForKey:@"alipayScan"];
            [ZFGlobleManager getGlobleManager].alipayMicro = [requestResult objectForKey:@"alipayMicro"];
            [ZFGlobleManager getGlobleManager].channleCannel = [requestResult objectForKey:@"channleCannel"];
            
            [self saveUserInfo];
            [self jumpToMain];
            _aliasCount = 0;
            [self setAliasWithAlias:_alias];
        } else {
            //登录错误清除密码
            [[ZFGlobleManager getGlobleManager] saveLoginPwd:@""];
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark 代理登录
- (void)agencyLoginRequest{
    if (![self userInputIsRight]) {
        return;
    }
    NSString *countryCode = [[_areaTextField.text componentsSeparatedByString:@"+"] lastObject];
    NSString *userName = _userTextField.text;//_agencyTextField.text;
    NSString *password = _pwdTextField.text;
    
    password = [TripleDESUtils getEncryptWithString:password keyString:AgencyTripledesKey ivString:TRIPLEDES_IV];
    
    NSDictionary *dict = @{
                           @"areaCode" : countryCode,
                           @"userName" : userName,
                           @"passWord" : password
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine postWtihURL:AgencyLoginUrl parmas:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [ZFGlobleManager getGlobleManager].areaNum = countryCode;
            [ZFGlobleManager getGlobleManager].userPhone = userName;
            NSString *perSonCharge = [requestResult objectForKey:@"perSonCharge"];
            [ZFGlobleManager getGlobleManager].perSonCharge = perSonCharge;
            KDAgencyHomeController *ahVC = [[KDAgencyHomeController alloc] init];
            ahVC.areaNum = countryCode;
            ahVC.agencyNum = userName;
            ahVC.password = _pwdTextField.text;
            ahVC.block = ^(BOOL isClean) {
                if (isClean) {
                    _pwdTextField.text = @"";
                    [[ZFGlobleManager getGlobleManager] saveLoginPwd:@""];
                }
            };
            ZFNavigationController *nav = [[ZFNavigationController alloc] initWithRootViewController:ahVC];
            [self presentViewController:nav animated:YES completion:nil];
            [self saveUserInfo];
            [[MBUtils sharedInstance] dismissMB];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark 保存信息
- (void)saveUserInfo{
    
    if (_tabbarType == TabbarMerchantCashierType) {//收银员商户信息
        [[NSUserDefaults standardUserDefaults] setObject:_cashierTextField.text forKey:@"cashierNum"];
        //柜台号
        [[NSUserDefaults standardUserDefaults] setObject:_counterTextField.text forKey:[NSString stringWithFormat:@"counterCode%@", _cashierTextField.text]];
    } else if (_tabbarType == TabbarAgencyType){//代理登录
//        [[NSUserDefaults standardUserDefaults] setObject:_agencyTextField.text forKey:@"agencyNum"];
        [[NSUserDefaults standardUserDefaults] setObject:[ZFGlobleManager getGlobleManager].userPhone forKey:@"userPhoneNum"];
        //区号
        [[NSUserDefaults standardUserDefaults] setObject:_areaTextField.text forKey:[NSString stringWithFormat:@"areaNum%@", _userTextField.text]];
    } else {//商户或收银员信息
        [[NSUserDefaults standardUserDefaults] setObject:[ZFGlobleManager getGlobleManager].userPhone forKey:@"userPhoneNum"];
        //区号
        [[NSUserDefaults standardUserDefaults] setObject:_areaTextField.text forKey:[NSString stringWithFormat:@"areaNum%@", _userTextField.text]];
    }
    [[ZFGlobleManager getGlobleManager] saveLoginPwd:_pwdTextField.text];
    
    //登录类型
    [[NSUserDefaults standardUserDefaults] setInteger:_tabbarType forKey:@"loginTypeBtn"];
}

#pragma mark - 其他方法
#pragma mark 跳转到主页
- (void)jumpToMain{
    //设置登录状态
    if (_tabbarType == TabbarMerchantType || _tabbarType == TabbarMerchantCashierType) {
        [ZFGlobleManager getGlobleManager].loginStatus = 1;
    } else {
        [ZFGlobleManager getGlobleManager].loginStatus = 2;
    }
    
    ZFTabBarViewController *tabVC = [[ZFTabBarViewController alloc] initWithTabbarType:_tabbarType];
    tabVC.tabBarController.tabBar.translucent = NO;
    // 动画
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //window.rootViewController = [[ZFNavigationController alloc] initWithRootViewController:[[ZFMainViewController alloc] init]];
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

- (NSString *)MD5ForLower32Bate:(NSString *)str{
    //要进行UTF8的转码
    const char* input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    return digest;
}

// 注册别名
- (void)setAliasWithAlias:(NSString *)alias {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [JPUSHService setAlias:alias completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
            if (iResCode == 0) {
                DLog(@"别名设置成功--%@", iAlias);
            } else {
                if (_aliasCount < 2) {//设置不成功时再次请求
                    [self setAliasWithAlias:alias];
                    _aliasCount++;
                }
            }
        } seq:0];
    });
}

#pragma mark textfield delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == _areaTextField) {
        if (![ZFGlobleManager getGlobleManager].areaNumArray || [ZFGlobleManager getGlobleManager].areaNumArray.count == 0) {
            [self getCountryCode:2];
            return NO;
        }
    }
    return YES;
}

// return按钮
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self clickLoginBtn];
    return YES;
}


#pragma mark - pickview delegate
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _areaArray.count;
}

- (NSInteger) numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return _areaArray.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.view.bounds.size.width;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if (!view) {
        view = [[UIView alloc] init];
    }
    UILabel *textlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    textlabel.textAlignment = NSTextAlignmentCenter;
    textlabel.text = _areaArray[row];
    textlabel.font = [UIFont systemFontOfSize:19];
    [view addSubview:textlabel];
    return view;
}

// didSelectRow
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.areaTextField.text = [NSString stringWithFormat:@"+%@", [[_areaArray[row] componentsSeparatedByString:@"+"] lastObject]];
}

@end
