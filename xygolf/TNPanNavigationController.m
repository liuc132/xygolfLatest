//
//  TNPanNavigationController.m
//  TNPanNavigationControllerDemo
//
//  Created by TaonanShen on 15/4/14.
//  Copyright (c) 2015年 Tenney. All rights reserved.
//

#define PREVPAGEVIEW_ALPHA 0.5f
#define ANIMATIONDURATION 0.3f
#define BACKDURATION 0.1f
#define PREVPAGEVIEWTAG 888
#define KEYWINDOW [[UIApplication sharedApplication] keyWindow]
#define KEYWINDOW_BOUNDS [[[UIApplication sharedApplication] keyWindow] bounds]
#define MAXMOVE 100

#import "TNPanNavigationController.h"
#import "LogInViewController.h"

@interface TNPanNavigationController ()
{
    NSMutableArray *_screenShots; //截屏图片数组
}

@end

@implementation TNPanNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self initWithRootViewController:[[LogInViewController alloc] init]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        _screenShots = [NSMutableArray array];
        UIPanGestureRecognizer *panGestureRecognizer =
        [[UIPanGestureRecognizer alloc]initWithTarget:self
                                               action:@selector(handlePanGesture:)];
        [self.view addGestureRecognizer:panGestureRecognizer];
    }
    return self;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer{
    if (self.viewControllers.count <= 1) {
        return;
    }
    
    UIView *prevPageView = [KEYWINDOW viewWithTag:PREVPAGEVIEWTAG];
    if (!prevPageView) {
        prevPageView       = [_screenShots lastObject];
        prevPageView.alpha = PREVPAGEVIEW_ALPHA;
        [KEYWINDOW insertSubview:prevPageView
                         atIndex:0];

    }
    CGPoint translation = [panGestureRecognizer translationInView:self.view];
    if (translation.x > 0) {
        [self.view setTransform:CGAffineTransformMakeTranslation(translation.x, 0)];
        float alpha = MIN(1.0, PREVPAGEVIEW_ALPHA + translation.x / CGRectGetWidth(KEYWINDOW_BOUNDS) * (1 - PREVPAGEVIEW_ALPHA));
        prevPageView.alpha = alpha;
    }
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (translation.x > MAXMOVE) {
            [self popViewControllerWithSelfAnimation:YES];
        }
        else{
            [self backToOriginal];
        }
    }
    
    
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    UIView *prevPageView = [KEYWINDOW viewWithTag:PREVPAGEVIEWTAG];
    if (prevPageView) {
        [prevPageView removeFromSuperview];
    }
    prevPageView = [[UIImageView alloc]initWithImage:[self getCurrentScreenShot]];
    prevPageView.tag = PREVPAGEVIEWTAG;
    [_screenShots addObject:prevPageView];
    [super pushViewController:viewController animated:animated];
    
}

-(void)popViewControllerWithSelfAnimation:(BOOL)animated{
    if (self.viewControllers.count <= 1) {
        return;
    }
    UIView *prevPageView = [KEYWINDOW viewWithTag:PREVPAGEVIEWTAG];
    if (!prevPageView) {
        prevPageView = [_screenShots lastObject];
        prevPageView.alpha = PREVPAGEVIEW_ALPHA;
        [KEYWINDOW insertSubview:prevPageView
                         atIndex:0];
        
    }
    [UIView animateWithDuration:ANIMATIONDURATION
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(KEYWINDOW_BOUNDS), 0);
                         prevPageView.alpha = 1.0f;
    }
                     completion:^(BOOL finished) {
                         [super popViewControllerAnimated:NO];
                         self.view.transform = CGAffineTransformMakeTranslation(0, 0);
                         [prevPageView removeFromSuperview];
                         [_screenShots removeLastObject];
    }];
}

- (void)backToOriginal{
    UIView *prevPageView = [_screenShots lastObject];
    prevPageView.alpha   = PREVPAGEVIEW_ALPHA;
    [UIView animateWithDuration:BACKDURATION
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.transform = CGAffineTransformMakeTranslation(0, 0);
                         prevPageView.alpha = PREVPAGEVIEW_ALPHA;

    }
                     completion:^(BOOL finished) {
        
    }];
}

//获取截屏图片
- (UIImage *)getCurrentScreenShot{
    
    UIGraphicsBeginImageContextWithOptions(KEYWINDOW_BOUNDS.size, NO, 0.0);
    [KEYWINDOW.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}



@end
