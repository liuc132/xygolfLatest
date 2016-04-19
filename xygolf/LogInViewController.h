//
//  ViewController.h
//  xygolf
//
//  Created by LiuC on 16/3/23.
//  Copyright © 2016年 dreamer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TencentOpenAPI/TencentOAuth.h"
#import "TencentOpenAPI/TencentApiInterface.h"


#define TXQQApp_key     @"w5nNonRtpA0OGLtA"
#define TXQQAppID       @"1105290842"

@interface LogInViewController : UIViewController<TencentSessionDelegate>


@end

