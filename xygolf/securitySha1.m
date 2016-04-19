//
//  securitySha1.m
//  weatherForecastDemo
//
//  Created by LiuC on 16/3/24.
//  Copyright © 2016年 liuc. All rights reserved.
//

#import "securitySha1.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#import "Base64.h"

@interface securitySha1 ()

@end

@implementation securitySha1

/**
 *  将publicKey以及privateKey进行加密
 *
 *  @param public_key public_key 生成的publicKey
 *
 *  @return return value 返回publickey以及privatekey经过加密算法之后的结果
 */
- (NSString *) hmacSha1:(NSString*)public_key{
    NSString* private_key;
    private_key = WeatherPrivateKey;
    
    NSData* secretData = [private_key dataUsingEncoding:NSUTF8StringEncoding];
    NSData* stringData = [public_key dataUsingEncoding:NSUTF8StringEncoding];
    
    const void* keyBytes = [secretData bytes];
    const void* dataBytes = [stringData bytes];
    
    ///#define CC_SHA1_DIGEST_LENGTH   20          /* digest length in bytes */
    void* outs = malloc(CC_SHA1_DIGEST_LENGTH);
    
    CCHmac(kCCHmacAlgSHA1, keyBytes, [secretData length], dataBytes, [stringData length], outs);
    
    // Soluion 1
    NSData* signatureData = [NSData dataWithBytesNoCopy:outs length:CC_SHA1_DIGEST_LENGTH freeWhenDone:YES];
    
    return [signatureData base64EncodedString];
    
}
/**
 *  加密过后的key通过urlencode编码之后的结果
 *
 *  @param _key _key 经过加密算法之后获得的key
 *
 *  @return return value 将加密之后的key通过urlencode编码
 */
- (NSString *)stringByEncodingURLFormat:(NSString*)_key{
    
    NSString *encodedString = nil;
    encodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)_key, nil, (CFStringRef) @"!$&'()*+,-./:;=?@_~%#[]", kCFStringEncodingUTF8);
    //由于ARC的存在，这里的转换需要添加__bridge
    return encodedString;
    
}
/*
 http://open.weather.com.cn/data/?areaid=101010200&type=forecast_f&date=201211281030&appid=1234567890
 */
/**
 *  构建并返回publicKey
 *
 *  @param areaid areaid 区域ID
 *  @param type   type 请求返回的天气数据类型
 *  @param date   date 当前设备的日期
 *
 *  @return return value 返回publicKey
 */
- (NSString *)GetPublicKey:(NSString *)areaid type:(NSString *)type date:(NSString *)date
{
    NSString *pubKey;
    //
    pubKey = [NSString stringWithFormat:@"%@areaid=%@&type=%@&date=%@&appid=%@",WeatherMainURL,areaid,type,date,WeatherAppId];
    
    return pubKey;
}
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
- (NSString *)constructWeatherAPI:(NSString *)areaid type:(NSString *)type date:(NSString *)date key:(NSString *)encodeKey
{
    NSString *reqAPI;
    NSString *appId;
    appId = WeatherAppId;
    
    reqAPI = [NSString stringWithFormat:@"%@areaid=%@&type=%@&date=%@&appid=%@&key=%@",WeatherMainURL,areaid,type,date,[appId substringToIndex:6],encodeKey];
    
    return reqAPI;
}
/**
 *  获取当前设备的时间
 *
 *  @return 返回的格式是:yyyyMMddHHmm
 */
- (NSString *)getCurDate
{
    //current device date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmm"];
    NSString *curDate = [formatter stringFromDate:[NSDate date]];
    //
    return curDate;
}

/**
 *  返回当前时间，时间的格式为HH-MM(小时－分钟)
 *
 *  @return return value 当前设备的时间，时间格式为HH-MM
 */
- (NSString *)getCurTime_HM
{
    NSDateFormatter *date_formatter = [[NSDateFormatter alloc] init];
    [date_formatter setDateFormat:@"HHmm"];
    NSString *curDateHourMinute = [date_formatter stringFromDate:[NSDate date]];
    
    return curDateHourMinute;
}


@end
