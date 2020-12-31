//
//  ZFGlobleManager.h
//  SinopayStore
//
//  Created by 中付支付 on 2017/11/30.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFLoginViewController.h"
#import "KeychainWrapper.h"


@interface ZFGlobleManager : NSObject

+ (instancetype)getGlobleManager;

///登录页
@property (nonatomic, strong)ZFLoginViewController *loginVC;
///区号数组
@property (nonatomic, strong)NSMutableArray *areaNumArray;

///手机号
@property (nonatomic, strong)NSString *userPhone;
///手机区号
@property (nonatomic, strong)NSString *areaNum;
///手机唯一值
@property (nonatomic, strong)NSString *userKey;
///sessionid
@property (nonatomic, strong)NSString *sessionID;
///密钥
@property (nonatomic, strong)NSString *securityKey;
///临时session
@property (nonatomic, strong)NSString *tempSessionID;
///临时密钥
@property (nonatomic, strong)NSString *tempSecurityKey;
/// 认证状态 0已提交 1未提交
@property (nonatomic, strong)NSString *fillingStatus;
///商户名
@property (nonatomic, strong)NSString *merName;
///店铺名
@property (nonatomic, strong)NSString *merShortName;
///商户号
@property (nonatomic, strong)NSString *merID;
///终端号
@property (nonatomic, strong)NSString *terID;
///终端号2
@property (nonatomic, strong)NSString *termCode;
///邮箱
@property (nonatomic, strong)NSString *email;
///商户交易币种
@property (nonatomic, strong)NSString *merTxnCurr;

///经办人
@property (nonatomic, strong)NSString *perSonCharge;

///登录状态 1 小微登录  2 收银员登录
@property (nonatomic, assign)NSInteger loginStatus;

// 判断是否需要刷新可提现金额
@property (nonatomic, assign)BOOL isRWA;

// 判断是否需要刷新银行卡列表
@property (nonatomic, assign)BOOL isChanged;

///代理商注册类型 0 登录页注册  1 登录后注册
@property (nonatomic, assign)NSInteger agentAddType;

@property (nonatomic, strong) KeychainWrapper *myKeychainWrapper;
///头像
@property (nonatomic, strong)UIImage *headImage;

/**
 新增参数
 */
// 支付宝总开关
@property (nonatomic, strong)NSString *alipayTotalSwitch;
// 银联总开关
@property (nonatomic, strong)NSString *unionpayTotalSwitch;
// 银联二维码被扫开关
@property (nonatomic, strong)NSString *unionpayMicro;
// 银联二维码主扫开关
@property (nonatomic, strong)NSString *unionpayScan;
// 银联二维码静态二维码开关
@property (nonatomic, strong)NSString *unionpayStatic;
// 支付宝主扫开关
@property (nonatomic, strong)NSString *alipayScan;
// 支付宝被扫开关
@property (nonatomic, strong)NSString *alipayMicro;
// 撤销开关
@property (nonatomic, strong)NSString *channleCannel;
@property (nonatomic, strong)NSString *location;
///获取区号数组
- (NSMutableArray *)getAreaNumArray;

///保存登录密码
- (void)saveLoginPwd:(NSString *)loginPwd;
///获取登录密码
- (NSString *)getLoginPwd;

///保存区号数组
- (void)saveAreaNumArray:(NSMutableArray *)areaNumArr;

///通过URL保存用户头像
- (void)saveHeadImageWithUrl:(NSString *)urlStr;

///获取当前版本号
- (NSString *)getCurrentVersion;

+ (NSString *)transformCurrencyNum2SymbolString:(NSString *)currencyNum;

- (NSArray *)stringToArray:(NSString *)jsonString;

- (UIButton *)createRightBtn:(SEL)action view:(id)controller title:(NSString *)title;
//获取定位反编码结果
- (NSString *)getLocationArray:(NSArray *)locArray;
// 是否打开定位
- (BOOL)determineWhetherTheAPPOpensTheLocation;
@end
