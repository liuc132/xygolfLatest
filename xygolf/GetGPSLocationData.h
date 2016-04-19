//
//  GetGPSLocationData.h
//  XunYing_Golf
//
//  Created by LiuC on 15/11/3.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GetGPSLocationData : NSObject

/**
 *  初始化GPS定位
 */
-(void)initGPSLocation;

/**
 *  在其他的类中获取到当前所获取到的GPS信息，并开启GPS更新
 *
 *  @return return value 当前所获取到的GPS信息
 */
-(CLLocation *)getCurLocation;

/**
 *  停止GPS更新
 */
- (void)stopUpdateLocation;

/**
 *  根据所提供的GPS地理信息，反编译查询出当前地区的areaID
 *
 *  @param currentLoaction currentLoaction 传入的GPS地理信息，类型为CLLocation
 *
 *  @return return value 返回的是查询出来的areaID
 */
- (NSString *)searchTheCityNameID:(CLLocation *)currentLoaction;


@end
