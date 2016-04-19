//
//  customAlertView.h
//  xygolf
//
//  Created by LiuC on 16/4/16.
//  Copyright © 2016年 dreamer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface customAlertView : UINavigationBar

@property (nonatomic, readonly) UILabel *label;
@property (nonatomic, readonly) UIImageView *backImageView;
@property (nonatomic, readonly) UIButton *firstbutton;
@property (nonatomic, readonly) UIButton *secondbutton;

- (void) show;
- (void) dismiss;



@end
