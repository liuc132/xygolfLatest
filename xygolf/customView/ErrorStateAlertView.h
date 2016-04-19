//
//  ErrorStateAlertView.h
//  xygolf
//
//  Created by LiuC on 16/4/19.
//  Copyright © 2016年 dreamer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ErrorStateAlertView : UIView

@property (nonatomic, readonly) UILabel     *errStateLabel;
//@property (nonatomic, readonly) UIView      *errStateBackView;

- (void)showErrorStateAlertDuration;



@end
