//
//  HoleFunctionChangeView.h
//  xygolf
//
//  Created by LiuC on 16/4/21.
//  Copyright © 2016年 dreamer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourseStateViewController.h"

@interface HoleFunctionChangeView : UIView



- (void)holeFunctionViewShow;
- (void)holeFunctionViewDismiss;

- (BOOL)holeFunctionViewisShowing;


@property (weak) id<CourseStateViewControllerDelegate> delegate;

@end
