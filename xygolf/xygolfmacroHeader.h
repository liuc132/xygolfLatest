//
//  xygolfmacroHeader.h
//  xygolf
//
//  Created by LiuC on 16/4/12.
//  Copyright © 2016年 dreamer. All rights reserved.
//

#ifndef xygolfmacroHeader_h
#define xygolfmacroHeader_h


#define ScreenWidth [[UIScreen mainScreen]bounds].size.width
#define ScreenHeight [[UIScreen mainScreen]bounds].size.height


/**
 *  访问接口定义
 */
#define xyMainURL           @"http://localhost:8089/"
#define xyLogInSubURL       @"user/mlogin"       //登录
#define xyRegSubURL         @"user/manager"      //注册role type:manager(调度/巡场)   caddy(球童)
#define xycaptcha           @"user/captcha"      //发送验证码






#endif /* xygolfmacroHeader_h */
