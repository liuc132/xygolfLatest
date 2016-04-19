//
//  securitySha1.h
//  weatherForecastDemo
//
//  Created by LiuC on 16/3/24.
//  Copyright © 2016年 liuc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WeatherMainURL      @"http://open.weather.com.cn/data/?"
#define WeatherAppId        @"171f679e45af0fe7"
#define WeatherPrivateKey   @"90cb25_SmartWeatherAPI_e7d2b19"

@interface securitySha1 : NSObject



/**
 *  将publicKey以及privateKey进行加密
 *
 *  @param public_key public_key 生成的publicKey
 *
 *  @return return value 返回publickey以及privatekey经过加密算法之后的结果
 */
- (NSString *) hmacSha1:(NSString*)public_key;

/**
 *  加密过后的key通过urlencode编码之后的结果
 *
 *  @param _key _key 经过加密算法之后获得的key
 *
 *  @return return value 将加密之后的key通过urlencode编码
 */
- (NSString *)stringByEncodingURLFormat:(NSString*)_key;

/**
 *  构建并返回publicKey
 *
 *  @param areaid areaid 区域ID
 *  @param type   type 请求返回的天气数据类型
 *  @param date   date 当前设备的日期
 *
 *  @return return value 返回publicKey
 */
- (NSString *)GetPublicKey:(NSString *)areaid type:(NSString *)type date:(NSString *)date;

/**
 *  构建访问天气的完整API
 *
 *  @param areaid    areaid 区域ID
 *  @param type      type 获取天气的类型
 *  @param date      date 当前设备的日期（yymmddhhmm）
 *  @param encodeKey encodeKey 经过加密算法，得到的key
 *
 *  @return return value 完整的API地址
 */
- (NSString *)constructWeatherAPI:(NSString *)areaid type:(NSString *)type date:(NSString *)date key:(NSString *)encodeKey;
/**
 *  获取当前设备的时间
 *
 *  @return 返回的格式是:yyyyMMddHHmm
 */
- (NSString *)getCurDate;

/**
 *  返回当前时间，时间的格式为HH-MM(小时－分钟)
 *
 *  @return return value 当前设备的时间，时间格式为HH-MM
 */
- (NSString *)getCurTime_HM;

@end
