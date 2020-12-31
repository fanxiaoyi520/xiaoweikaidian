//
//  Definition.h
//  SinopayStore
//
//  Created by Jellyfish on 2017/12/4.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#ifndef Definition_h
#define Definition_h


//获取屏幕 宽度、高度
#define ZFSCREEN [UIScreen mainScreen].bounds
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

// 屏幕适配
#define IPhoneXStatusBarHeight (SCREEN_HEIGHT == 812.0 ? 44 : 20) // 状态栏高度
#define IPhoneXTopHeight (SCREEN_HEIGHT == 812.0 ? 88 : 64)    // 顶部高度
#define IPhoneNaviHeight 44 // 导航栏高度


// RGB颜色
#define ZFColor(R, G, B) [UIColor colorWithRed:(R)/255.0 green:(G)/255.0 blue:(B)/255.0 alpha:1.0]
// RGB颜色
#define ZFAlpColor(R, G, B, A) [UIColor colorWithRed:(R)/255.0 green:(G)/255.0 blue:(B)/255.0 alpha:A]

/// rgb颜色转换（16进制->10进制）
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


// APP主题颜色(蓝)
#define MainThemeColor UIColorFromRGB(0x236BBF)

// 灰色背景颜色
#define GrayBgColor UIColorFromRGB(0xF6F6F6)

#define MainFontColor MainThemeColor


#define AUTODISMISSTIME 1.5 // 菊花文字提示消失时间
#define AUTOTIPDISMISSTIME 1.0 // 成功提示图片文字消失时间
#define AUTOFAILEDTIPDISMISSTIME 1.5 // 失败提示图片文字消失时间


///网络请求时菊花
#define NetRequestText NSLocalizedString(@"加载中", @"加载中")
///网络请求失败
#define NetRequestError NSLocalizedString(@"网络请求失败", nil)
///代理商注册功能接口号字段
#define TxnType @"txnType"

/// 3DES的iv
#define TRIPLEDES_IV @"01234567"
/// 代理3deskey
#define AgencyTripledesKey @"cEUWaXrhXjjONO3NsxPK5Umw"

///网络是否可用key
#define NETWORK_ISOK @"networkStatus"

///改变语言通知
#define CHANGE_LANGUAGE @"change_langeage"


#define Alias_DeviceID [[[[UIDevice currentDevice] identifierForVendor] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""]

///银联扫码枪二维码
#define UPOP_QRCODE_KEY [NSString stringWithFormat:@"upop_qrCode_key%@", [ZFGlobleManager getGlobleManager].userPhone]
///云闪付二维码
#define UNIONPay_QRCODE_KEY [NSString stringWithFormat:@"unionpay_qrCode_key%@", [ZFGlobleManager getGlobleManager].userPhone]

///所属商户
#define CASHIER_MERCHANTS_NAME [NSString stringWithFormat:@"CASHIER_MERCHANTS_NAME%@", [ZFGlobleManager getGlobleManager].userPhone]
///商户号
#define CASHIER_MERCHANTS_MERID [NSString stringWithFormat:@"CASHIER_MERCHANTS_MERID%@", [ZFGlobleManager getGlobleManager].userPhone]

///推送过来的交易id
#define PUSH_ORDERID [NSString stringWithFormat:@"push_orderId%@", [ZFGlobleManager getGlobleManager].userPhone]
///未读信息标志
#define UNREAD_MESSAGE [NSString stringWithFormat:@"unread_message%@", [ZFGlobleManager getGlobleManager].userPhone]
///推送过来的撤销流水号
#define TRANS_Number [NSString stringWithFormat:@"trans_number%@", [ZFGlobleManager getGlobleManager].userPhone]

///仅英文
#define LimitEnglish @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

#ifdef DEBUG // 处于开发阶段
#define DLog(...) NSLog(__VA_ARGS__)
#else // 处于发布阶段
#define DLog(...)
#endif


// 自定义宏字符串
#define ScanQRCodeFormat @"https://u.sinopayonline.com/UGateWay/cashier?m="

/**
    正式
 */
#define ALIPAYANDUNIONPAY [[ZFGlobleManager getGlobleManager].alipayTotalSwitch isEqualToString:@"open"] && [[ZFGlobleManager getGlobleManager].unionpayTotalSwitch isEqualToString:@"open"]
#define ONLIALIPAY [[ZFGlobleManager getGlobleManager].alipayTotalSwitch isEqualToString:@"open"] && ![[ZFGlobleManager getGlobleManager].unionpayTotalSwitch isEqualToString:@"open"]
#define ONLIUNIONPAY ![[ZFGlobleManager getGlobleManager].alipayTotalSwitch isEqualToString:@"open"] && [[ZFGlobleManager getGlobleManager].unionpayTotalSwitch isEqualToString:@"open"]

/**
    测试 支付宝
*/
//#define ONLIALIPAY [[ZFGlobleManager getGlobleManager].alipayTotalSwitch isEqualToString:@"open"] && [[ZFGlobleManager getGlobleManager].unionpayTotalSwitch isEqualToString:@"open"]
//#define ALIPAYANDUNIONPAY [[ZFGlobleManager getGlobleManager].alipayTotalSwitch isEqualToString:@"open"] && ![[ZFGlobleManager getGlobleManager].unionpayTotalSwitch isEqualToString:@"open"]
//#define ONLIUNIONPAY ![[ZFGlobleManager getGlobleManager].alipayTotalSwitch isEqualToString:@"open"] && [[ZFGlobleManager getGlobleManager].unionpayTotalSwitch isEqualToString:@"open"]

/**
    测试 云闪付
*/
//#define ONLIUNIONPAY [[ZFGlobleManager getGlobleManager].alipayTotalSwitch isEqualToString:@"open"] && [[ZFGlobleManager getGlobleManager].unionpayTotalSwitch isEqualToString:@"open"]
//#define ONLIALIPAY [[ZFGlobleManager getGlobleManager].alipayTotalSwitch isEqualToString:@"open"] && ![[ZFGlobleManager getGlobleManager].unionpayTotalSwitch isEqualToString:@"open"]
//#define ALIPAYANDUNIONPAY ![[ZFGlobleManager getGlobleManager].alipayTotalSwitch isEqualToString:@"open"] && [[ZFGlobleManager getGlobleManager].unionpayTotalSwitch isEqualToString:@"open"]
#endif /* Definition_h */
