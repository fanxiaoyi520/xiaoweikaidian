//
//  ZFGlobleManager.m
//  SinopayStore
//
//  Created by 中付支付 on 2017/11/30.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFGlobleManager.h"

@implementation ZFGlobleManager

+ (instancetype)getGlobleManager{
    static dispatch_once_t onceToken;
    static ZFGlobleManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ZFGlobleManager alloc] init];
    });
    return manager;
}

- (UIImage *)headImage{
    NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"headImage%@", _userPhone]];
    _headImage = [UIImage imageWithData:imageData];
    
    if (!_headImage) {
        _headImage = [UIImage imageNamed:@"list_icon_head_portrait"];
    }
    return _headImage;
}

- (void)saveHeadImageWithUrl:(NSString *)urlStr{
    NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"headImage%@", _userPhone]];
    UIImage *savedImage = [UIImage imageWithData:imageData];
    
    if (savedImage) {//已经存在 不需要重新下载
        return;
    }
    NSData *data = [NSData dataWithContentsOfURL:[NSURL  URLWithString:urlStr]];
    //UIImage *image = [UIImage imageWithData:data];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:[NSString stringWithFormat:@"headImage%@", _userPhone]];
}


- (NSMutableArray *)getAreaNumArray{
    NSMutableArray *areaArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"areaNumArray"];
    _areaNumArray = areaArr;
    return areaArr;
}

#pragma mark - 保存和获取区号数组
- (void)saveAreaNumArray:(NSMutableArray *)areaNumArr{
    _areaNumArray = areaNumArr;
    [[NSUserDefaults standardUserDefaults] setObject:areaNumArr forKey:@"areaNumArray"];
}

#pragma mark - 保存和获取登录密码
- (void)saveLoginPwd:(NSString *)loginPwd{
    [self.myKeychainWrapper mySetObject:loginPwd forKey:(__bridge id)(kSecValueData)];
}

- (NSString *)getLoginPwd{
    return [self.myKeychainWrapper myObjectForKey:(__bridge id)(kSecValueData)];
}

- (KeychainWrapper *) myKeychainWrapper
{
    if (!_myKeychainWrapper) {
        _myKeychainWrapper = [[KeychainWrapper alloc]init];
    }
    return _myKeychainWrapper;
}

#pragma mark - 获取当前版本号
- (NSString *)getCurrentVersion{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDict));
    NSString *currVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    
    return currVersion;
}


// 获取币种
+ (NSString *)transformCurrencyNum2SymbolString:(NSString *) currencyNum
{
    NSString *symbolString = @"";
    switch ([currencyNum integerValue]) {
        case 156:
            symbolString = @"CNY";
            break;
        case 702:
            symbolString = @"SGD";
            break;
        case 344:
            symbolString = @"HKD";
            break;
        case 840:
            symbolString = @"USD";
            break;
        case 458:
            symbolString = @"MYR";
            break;
        default:
            break;
    }
    return symbolString;
}

- (NSArray *)stringToArray:(NSString *)jsonString{
    if ([jsonString isKindOfClass:[NSNull class]] || jsonString.length < 1) {
        return nil;
    }
    return [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
}

- (UIButton *)createRightBtn:(SEL)action view:(id)controller title:(NSString *)title{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    btn.frame = CGRectMake(SCREEN_WIDTH-120, IPhoneXStatusBarHeight, 100, IPhoneNaviHeight);
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.textColor = [UIColor whiteColor];
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    btn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [btn addTarget:controller action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (NSString *)getLocationArray:(NSArray *)locArray {
    CLPlacemark *placemark = [locArray objectAtIndex:0];
    //获取城市
    NSString *city = placemark.locality;
    if (!city) {
        //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
        city = placemark.administrativeArea;
    }
    NSLog(@"city = %@", city);//沈阳市
    NSLog(@"--%@",placemark.name);//黄河大道21号
    NSLog(@"++++%@",placemark.subLocality); //浑南区
    NSLog(@"country == %@",placemark.country);//中国
    NSLog(@"administrativeArea == %@",placemark.administrativeArea); //辽宁省
    NSString *addressStr = [NSString stringWithFormat:@"%@ %@ %@ %@",placemark.administrativeArea,city,placemark.subLocality,placemark.name];
    NSLog(@"administrativeArea == %@",addressStr);
    return addressStr;
}

- (BOOL)determineWhetherTheAPPOpensTheLocation {
    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] ==kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] ==kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] ==kCLAuthorizationStatusAuthorized)) {
        return YES;
    } else if ( [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ) {
        return NO;
    } else {
        return NO;
    }
}
@end
