//
//  LocationManager.h
//  LBSDemo
//
//  Created by 王德 on 2017/9/27.
//  Copyright © 2017年 王德. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^LocationBlock)(CLLocationCoordinate2D coordinate, NSString *error);
@interface ZFLocationManager : NSObject

@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong, readonly) NSString *country;
@property (nonatomic, strong, readonly) NSString *city;
@property (nonatomic, strong, readonly) NSString *unCityCode;//银联地市编码

+ (ZFLocationManager *)sharedManager;

/**
 开始定位

 @param locationBlock 定位结果回调
 */
- (void)startLocation:(LocationBlock)locationBlock;


/**
 停止定位
 */
- (void)stopLocation;



@end
