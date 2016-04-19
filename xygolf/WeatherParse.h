//
//  WeatherParse.h
//  weatherForecastDemo
//
//  Created by LiuC on 16/3/24.
//  Copyright © 2016年 liuc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherParse : NSObject


/**
 *  查询当前天气ID所对应的天气所对应的中／英文名称
 *
 *  @param phenemenonID phenemenonID 当前天气的ID
 *
 *  @return return value 返回类型为NSMutableDictionary, 相应的中英文 中文名称:CNName 英文名称:ENName
 */
+ (NSMutableDictionary *)phenomenonParse:(NSString *)phenemenonID;

/**
 *  查询到areaid
 *
 *  @param areaName areaName 通过定位信息中所读取到的位置信息
 *
 *  @return return value 返回的是当前所定为到的位置的areaid
 */
+ (NSString *)getAreaIDbylocationName:(NSString *)areaName;

/**
 *  查询到当前所在位置的天气
 *
 *  @param areaID areaID 代表当前所在位置的区域ID
 *
 *  @return return value 返回当前位置的天气数据查询结果
 */
- (NSDictionary *)weatherInfoGet:(NSString *)areaID;




@end
