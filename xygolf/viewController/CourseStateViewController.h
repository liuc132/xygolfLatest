//
//  CourseViewController.h
//  xygolf
//
//  Created by LiuC on 16/3/30.
//  Copyright © 2016年 dreamer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>


@protocol CourseStateViewControllerDelegate <NSObject>

- (void)removeTheGraphics;

@end


@interface CourseStateViewController : UIViewController

@end
