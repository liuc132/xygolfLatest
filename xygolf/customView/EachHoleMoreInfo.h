//
//  EachHoleMoreInfo.h
//  xygolf
//
//  Created by LiuC on 16/4/17.
//  Copyright © 2016年 dreamer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EachHoleMoreInfo : UINavigationBar



@property (nonatomic, readonly) NSInteger   groupCount;

- (void)holeDetailDismiss;
- (void)holeDetailShow;


@end
