//
//  WeatherParse.m
//  weatherForecastDemo
//
//  Created by LiuC on 16/3/24.
//  Copyright © 2016年 liuc. All rights reserved.
//

#import "WeatherParse.h"
#import "securitySha1.h"

@interface WeatherParse ()


@end


@implementation WeatherParse


/**
 *  查询当前天气ID所对应的天气所对应的中／英文名称
 *
 *  @param phenemenonID phenemenonID 当前天气的ID
 *
 *  @return return value 返回类型为NSMutableDictionary, 相应的中英文 中文名称:CNName 英文名称:ENName
 */
+ (NSMutableDictionary *)phenomenonParse:(NSString *)phenemenonID
{
    //(NSString *CNName,NSString *EngName)
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    //获取到天气现象的plist
    NSString *phenomenonPlistPath = [[NSBundle mainBundle] pathForResource:@"Weather_phenomenonID" ofType:@"plist"];
    NSDictionary *phenomenonDic = [[NSDictionary alloc] initWithContentsOfFile:phenomenonPlistPath];
    
    NSString *curPhenomenon_CNName;
    NSString *curPhenomenon_ENName;
    
    curPhenomenon_CNName = phenomenonDic[phenemenonID][0];
    curPhenomenon_ENName = phenomenonDic[phenemenonID][1];
    //
    [result setObject:curPhenomenon_CNName forKey:@"CNName"];
    [result setObject:curPhenomenon_ENName forKey:@"ENName"];
    
    return result;
}

/**
 *  获取到风力，风速的中英文名
 *
 *  @param windPowerID     windPowerID 需要查询的风力的ID
 *  @param windDirectionID windDirectionID 需要查询的风向的ID
 *
 *  @return return value 返回风力的中英文名，以及风向的中英文名
 */
+ (NSMutableDictionary *)windPowerAndDirectionParse:(NSString *)windPowerID direction:(NSString *)windDirectionID
{
    //(NSString *CNName,NSString *EngName)
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    //获取到天气现象的plist
    NSString *phenomenonPlistPath = [[NSBundle mainBundle] pathForResource:@"weather_windDirectionID" ofType:@"plist"];
    NSDictionary *windPowerAndDirectionDic = [[NSDictionary alloc] initWithContentsOfFile:phenomenonPlistPath];
    
    NSString *curPhenomenon_CNWindPower;
    NSString *curPhenomenon_ENWindPower;
    
    NSString *curPhenomenon_CNWindDirection;
    NSString *curPhenomenon_ENWindDirection;
    //windPower
    curPhenomenon_CNWindPower = windPowerAndDirectionDic[@"windPower"][windPowerID][0];
    curPhenomenon_ENWindPower = windPowerAndDirectionDic[@"windPower"][windPowerID][1];
    //windDirection
    curPhenomenon_ENWindDirection = windPowerAndDirectionDic[@"windDirection"][windDirectionID][0];
    curPhenomenon_CNWindDirection = windPowerAndDirectionDic[@"windDirection"][windDirectionID][1];
    //
    [result setObject:curPhenomenon_CNWindPower forKey:@"CNWindPower"];
    [result setObject:curPhenomenon_ENWindPower forKey:@"ENWindPower"];
    
    [result setObject:curPhenomenon_CNWindDirection forKey:@"CNWindDirection"];
    [result setObject:curPhenomenon_ENWindDirection forKey:@"ENWindDirection"];
    
    return result;
}

/**
 *  查询到areaid
 *
 *  @param areaName areaName 通过定位信息中所读取到的位置信息
 *
 *  @return return value 返回的是当前所定为到的位置的areaid
 */
+ (NSString *)getAreaIDbylocationName:(NSString *)areaName
{
    NSString *theAreaID;
    //
    NSString *areaIDPlistPath = [[NSBundle mainBundle] pathForResource:@"areaID" ofType:@"plist"];
    
    NSArray *areaIDArray = [[NSArray alloc] initWithContentsOfFile:areaIDPlistPath];
    //进行查询
    for (NSDictionary *areaDic in areaIDArray) {
        NSString *areaNameAsPrefix = areaDic[@"NAMECN"];
//        NSLog(@"%@",areaNameAsPrefix);
        if ([areaName hasPrefix:areaNameAsPrefix]) {
            theAreaID = areaDic[@"AREAID"];
            break;//查到之后就直接退出查询
        }
        
    }
    //
    
    return theAreaID;
}

/**
 *  查询到当前所在位置的天气
 *
 *  @param areaID areaID 代表当前所在位置的区域ID
 *
 *  @return return value 返回当前位置的天气数据查询结果
 */
- (NSDictionary *)weatherInfoGet:(NSString *)areaID
{
    NSMutableDictionary *weatherResult;
    //
    //中国气象数据
    securitySha1 *securitySha = [[securitySha1 alloc] init];
    
    NSString *curDevDate = [securitySha getCurDate];
    
    NSString *curDateHHMM = [securitySha getCurTime_HM];
    
    NSString *publicKey = [securitySha GetPublicKey:areaID type:@"forecast_v" date:curDevDate];
    
    NSString *base64Sha1_Key = [securitySha hmacSha1:publicKey];
    
    NSString *urlencode_key = [securitySha stringByEncodingURLFormat:base64Sha1_Key];
    
    NSString *weatherAPI = [securitySha constructWeatherAPI:areaID type:@"forecast_v" date:curDevDate key:urlencode_key];
    
    //
    
    NSURL *urlCH = [NSURL URLWithString:weatherAPI];
    
    NSMutableURLRequest *reqCH = [NSMutableURLRequest requestWithURL:urlCH];
    [reqCH setHTTPMethod:@"GET"];
    //    [req setHTTPBody:[@"Post body" dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse   *responseCH;
    NSError             *errorCH;
    NSData *dataCH = [NSURLConnection sendSynchronousRequest:reqCH
                                           returningResponse:&responseCH
                                                       error:&errorCH];
    NSDictionary *dicCH = [NSJSONSerialization JSONObjectWithData:dataCH options:NSJSONReadingMutableLeaves error:nil];
    
    
    NSDictionary *phenomenonResult;
    
    /**
     *  因为返回的参数中，在晚上18:00之后，会将白天的数据给清空掉，所以在此处添加了判断；同样的对于其他的气象数据也是一样的
     */
    if (([curDateHHMM integerValue] >= 1800) || ([curDateHHMM integerValue] <= 600)) {
        phenomenonResult = [WeatherParse phenomenonParse:[dicCH[@"f"][@"f1"] firstObject][@"fb"]];
    }
    else
    {
        phenomenonResult = [WeatherParse phenomenonParse:[dicCH[@"f"][@"f1"] firstObject][@"fa"]];
    }
    //在这里组装查询结果的数据
    NSLog(@"---%@",phenomenonResult);
    
    return weatherResult;
}

@end
