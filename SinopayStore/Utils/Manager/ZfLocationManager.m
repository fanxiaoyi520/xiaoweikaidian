//
//  LocationManager.m
//  LBSDemo
//
//  Created by 王德 on 2017/9/27.
//  Copyright © 2017年 王德. All rights reserved.
//

#import "ZFLocationManager.h"
#import <UIKit/UIKit.h>

@interface ZFLocationManager () <CLLocationManagerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, assign) CLAuthorizationStatus status;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *unCityCode;//银联地市编码
@property (nonatomic, copy) LocationBlock locationBlock;
@property (nonatomic, assign) BOOL isRequesting;

@end

static ZFLocationManager *instance = nil;

@implementation ZFLocationManager

+ (ZFLocationManager *)sharedManager {
    return [[ZFLocationManager alloc] init];
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [super allocWithZone:zone];
        }
    });
    return instance;
}

-(id)copyWithZone:(NSZone *)zone
{
    return instance;
}

-(id)mutableCopyWithZone:(NSZone *)zone
{
    return instance;
}

-(id)init
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ((instance = [super init])) {
            if (![CLLocationManager locationServicesEnabled]) {
                DLog(@"定位服务当前可能尚未打开，请设置打开！");
            }
            else {
                instance.locationManager = [[CLLocationManager alloc] init];
                instance.geocoder = [[CLGeocoder alloc]init];
                instance.locationManager.delegate = self;
                instance.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                instance.locationManager.distanceFilter = 2000;
            }
        }
    });
    return instance;
}

#pragma mark - Public Method
/** 开始定位 */
- (void)startLocation:(LocationBlock)locationBlock
{
    self.locationBlock = locationBlock;
    self.status = [CLLocationManager authorizationStatus];
    if (self.status == kCLAuthorizationStatusAuthorizedAlways || self.status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        //开始更新位置
        [self.locationManager startUpdatingLocation];
        if (self.locationBlock) {
            self.locationBlock(self.coordinate, @"位置获取中...");
        }
    }
    else {
        //请求允许权限
        [self requestLocatonAuthorization];
    }
}

/** 停止定位 */
- (void)stopLocation
{
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - Private Method
/** 请求定位权限 */
- (void)requestLocatonAuthorization {
    if (self.status == kCLAuthorizationStatusNotDetermined) {//未询问
        if ( [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)] )
        {
            [self.locationManager requestWhenInUseAuthorization];
        }
        else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
    else {
        [XLAlertController acWithMessage:NSLocalizedString(@"请您打开定位权限，否则无法使用此功能", nil) confirmBtnTitle:NSLocalizedString(@"设置", nil) confirmAction:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
    }
}

/** 打开定位设置 */
#pragma mark - CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations firstObject];
    self.coordinate = location.coordinate;
    NSLog(@"经度：%f,纬度：%f,海拔：%f,航向：%f,行走速度：%f",_coordinate.longitude, _coordinate.latitude, location.altitude, location.course, location.speed);

//    [self getUnionPayCityCode];//获取银联地市编码

    __weak typeof(self)weakself = self;
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *placemark = [placemarks firstObject];
        //根据需求解析不同的位置信息
        weakself.country = placemark.country;
        weakself.city = placemark.locality;
        NSLog(@"areasOfInterest:%@", placemark.areasOfInterest);
        NSLog(@"ISOcountryCode:%@", placemark.ISOcountryCode);
        //回传位置信息
        if (self.locationBlock) {
            self.locationBlock(self.coordinate, nil);
        }
    }];
    [self.locationManager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"授权状态 = %d", status);
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusNotDetermined ) {
        [self.locationManager stopUpdatingLocation];
        
        if (self.locationBlock) {
            self.locationBlock(self.coordinate, @"未知");
        }
    }
    else {
        [self.locationManager startUpdatingLocation];
        if (self.locationBlock) {
            self.locationBlock(self.coordinate, @"位置获取中...");
        }
    }
    self.status = status;
}



@end
