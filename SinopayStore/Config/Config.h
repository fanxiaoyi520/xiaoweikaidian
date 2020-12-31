//
//  Config.h
//  SinopayStore
//
//  Created by Jellyfish on 2017/12/4.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#ifndef Config_h
#define Config_h

#define LOCAL_TEST           //测试环境
//#define PRODUCTION             //生产环境

/************************测试环境*****************************/
#if defined(LOCAL_TEST)
#define BASEURL @"https://utestapp.sinopayonline.com:8090/UGateWay/merAppService" // 测试
#define SettmentWebUrl @"https://utestapp.sinopayonline.com:8090/UGateWay/appGetManualSettle?q="//+商户号+yyyyMMddHHmmss(当时时间)+终端号
#define ReceiptsWebUrl @"http://test13.qtopay.cn/UGateWay/merchantReceiptServlet" ///小票网页
#define MoreTradeWebUrl @"http://test8.qtopay.cn/m/transQuery.html" ///更多交易网页

//代理测试
#define AgencyBaseUrl @"http://test8.qtopay.cn/server/appAgentRegister"
#define AgencyLoginUrl @"http://test8.qtopay.cn/server/appLogin" //代理登录接口
#define AgencyHomeUrl @"http://test8.qtopay.cn/m/home.html"  //代理主页接口
#define AgencyForgetUrl @"http://test8.qtopay.cn/m/verifyUser.html?userLoginLocation=app" //代理忘记密码
#define AgentMerChantURL @"http://test8.qtopay.cn/server/appRequestOsa"//新增商户osaos


/**************************生产环境***************************/
#elif defined(PRODUCTION)
#define BASEURL @"https://u.sinopayonline.com/UGateWay/merAppService"
#define SettmentWebUrl @"https://u.sinopayonline.com/UGateWay/appGetManualSettle?q="//+商户号+yyyyMMddHHmmss(当时时间)+终端号
#define ReceiptsWebUrl @"https://u.sinopayonline.com/UGateWay/merchantReceiptServlet" ///小票网页
#define MoreTradeWebUrl @"http://osaos.sinopayonline.com:8092/m/transQuery.html" ///更多交易网页


//代理生产
#define AgencyBaseUrl @"http://osaos.sinopayonline.com:8092/server/appAgentRegister"
#define AgencyLoginUrl @"http://osaos.sinopayonline.com:8092/server/appLogin二维码信息格式错误" //代理登录接口
#define AgencyHomeUrl @"http://osaos.sinopayonline.com:8092/m/home.html"  //代理主页接口
#define AgencyForgetUrl @"http://osaos.sinopayonline.com:8092/m/verifyUser.html?userLoginLocation=app" //代理忘记密码
#define AgentMerChantURL @"http://osaos.sinopayonline.com:8092/server/appRequestOsa"//新增商户osaos

#endif

// 极光推送  开发者账号
//公司级
#define JPUSH_APP_KEY @"b978d5269c51ee90282b81ca"

//企业级
//#define JPUSH_APP_KEY @"21ea6460efc6344d239b963a"

///appid
#define appstore_appid @"1357540748"

///bugly appid
#define Bugly_appid @"fe645f441d"


#endif /* Config_h */
