//
//  GetGPSLocationData.m
//  XunYing_Golf
//
//  Created by LiuC on 15/11/3.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "GetGPSLocationData.h"
#import <UIKit/UIKit.h>
#import "WeatherParse.h"


@interface GetGPSLocationData ()<CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *getGPSLocation;
@property (strong, nonatomic) CLLocation *oldGPSLocation;


@end

@implementation GetGPSLocationData

/**
 *  初始化GPS定位
 */
-(void)initGPSLocation
{
    //GPS初始化
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //    self.locationManager.allowsBackgroundLocationUpdates = YES;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
    {
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
            NSLog(@"ENTER requestAlwaysAuthorization");
        }
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9)
    {
        self.locationManager.allowsBackgroundLocationUpdates = YES;
    }
    if([CLLocationManager significantLocationChangeMonitoringAvailable] == YES)
    {
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
    
    [self.locationManager startUpdatingLocation];
}

/**
 *  在其他的类中获取到当前所获取到的GPS信息，并开启GPS更新
 *
 *  @return return value 当前所获取到的GPS信息
 */
-(CLLocation *)getCurLocation
{
    CLLocation *curLocation;
    
    [_locationManager startUpdatingLocation];
    //在此选择是传输实际的GPS数据还是模拟的数据
//    curLocation = self.getGPSLocation;
    
    if (_oldGPSLocation != _getGPSLocation) {
        _oldGPSLocation = _getGPSLocation;
    }
    
    curLocation = _oldGPSLocation;
    
    return curLocation;
}

#pragma -mark  didUpdateLocations
/**
 *  获取到更新的GPS信息的代理方法
 *
 *  @param manager   manager CLLocationManager
 *  @param locations locations 在缓存中获取到的GPS信息
 */
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
//    self.getGPSLocation = [locations lastObject];
    
    CLLocation *cacheLocation = [locations lastObject];
    NSDate *eventDate = cacheLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (fabs(howRecent) < 1.0) {
        //if the event is recent,do something with it.
        _getGPSLocation = cacheLocation;
        
        [_locationManager stopUpdatingLocation];
    }
}

/**
 *  停止GPS更新
 */
- (void)stopUpdateLocation
{
    [self.locationManager stopUpdatingLocation];
}

/**
 *  根据所提供的GPS地理信息，反编译查询出当前地区的areaID
 *
 *  @param currentLoaction currentLoaction 传入的GPS地理信息，类型为CLLocation
 *
 *  @return return value 返回的是查询出来的areaID
 */
- (NSString *)searchTheCityNameID:(CLLocation *)currentLoaction
{
//    __weak typeof(self) weakSelf = self;
    //
    __block NSString *cityID;
    //获取到当前的城市名称
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    //根据地理信息编译出地址信息
    [geoCoder reverseGeocodeLocation:currentLoaction completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        //
        if (placemarks.count) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            //获取城市
            //NSString *city = placemark.locality;
            //if (!city) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                //city = placemark.administrativeArea;
            //}
            
            //查询获取到areaID，默认设置成administrativeArea（省／四大直辖市）
            cityID = [WeatherParse getAreaIDbylocationName:placemark.administrativeArea];
            if (placemark.subLocality) {
                NSString *subLocalityAreaID;
                subLocalityAreaID = [WeatherParse getAreaIDbylocationName:placemark.subLocality];
                if (subLocalityAreaID) {
                    cityID = subLocalityAreaID;
                }
                else if(placemark.locality)
                {
                    NSString *localityAreaID;
                    localityAreaID = [WeatherParse getAreaIDbylocationName:placemark.locality];
                    if (localityAreaID) {
                        cityID = localityAreaID;
                    }
                }
            }
            
        }
        else if (error == nil && [placemarks count] == 0)
        {
            NSLog(@"No results were returned.");
        }
        else if (error != nil)
        {
            NSLog(@"An error occurred = %@", error);
        }
        
    }];
    
    return cityID;
}





@end
