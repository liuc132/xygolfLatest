//
//  CustomTabBarController.m
//  xygolf
//
//  Created by LiuC on 16/3/30.
//  Copyright © 2016年 dreamer. All rights reserved.
//

#import "CustomMainViewController.h"
#import "UIView+Geometry.h"
#import "PersonalCenterViewController.h"
#import "YRSideViewController.h"
#import "AndyScrollView.h"


#define PREVPAGEVIEW_ALPHA 0.5f
#define ANIMATIONDURATION 0.3f
#define BACKDURATION 0.1f
#define PREVPAGEVIEWTAG 888
#define KEYWINDOW [[UIApplication sharedApplication] keyWindow]
#define KEYWINDOW_BOUNDS [[[UIApplication sharedApplication] keyWindow] bounds]
#define MAXMOVE 100


@interface CustomMainTabBarViewController ()<UIGestureRecognizerDelegate,UITabBarDelegate,UITabBarControllerDelegate,UIScrollViewDelegate>

@property (strong, nonatomic) PersonalCenterViewController *personalCenterViewController;
@property (assign, nonatomic) BOOL  showingPersonalVC;
@property (strong, nonatomic) YRSideViewController *sideViewController;

@property (assign, nonatomic) BOOL  showingPanel;

@property (nonatomic, assign) CGPoint preVelocity;
@property (nonatomic, strong) AndyScrollView *scroll;






@end

@implementation CustomMainTabBarViewController

- (void)viewDidLoad {
//    [self.view addSubview:self.scroll];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    //[self setUpTheView];
    
    
    
}

-(UIScrollView *)scroll
{
    if (!_scroll)
    {
        _scroll = [[AndyScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _scroll.contentSize = CGSizeMake(self.view.frame.size.width * 2, 0);
        _scroll.pagingEnabled = YES;
        _scroll.showsHorizontalScrollIndicator = NO;
        _scroll.delegate = self;
        _scroll.bounces = NO;
    }
    return _scroll;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    //    NSLog(@">>>>>>>>>%f",scrollView.contentOffset.x);
    if (scrollView.contentOffset.x <= 0) {
        self.scroll.pan.enabled = YES;
    }else if (scrollView.contentOffset.x >= self.view.frame.size.width)
    {
        self.scroll.pan.enabled = NO;
    }
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSLog(@"tabbar:%@ item:%ld",tabBar,(long)item.tag);
    
    
}


- (void)setUpTheView
{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//    self.personalCenterViewController = [storyboard instantiateViewControllerWithIdentifier:@"PersonalCenterViewController"];
//    self.personalCenterViewController.view.tag = 1;
//    
//    [self.view addSubview:self.personalCenterViewController.view];
//    [self addChildViewController:_personalCenterViewController];
//    
//    [_personalCenterViewController didMoveToParentViewController:self];
    
    [self setGesture];
}

- (void)setGesture
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRight:)];
    
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 1;
    
    panGesture.delegate = self;
    
    [self.view addGestureRecognizer:panGesture];
}

- (UIView *)getThePersonalCenterView
{
    if (_personalCenterViewController == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        self.personalCenterViewController = [storyboard instantiateViewControllerWithIdentifier:@"PersonalCenterViewController"];
        self.personalCenterViewController.view.tag = 2;
        
        //
        [self addChildViewController:_personalCenterViewController];
        [self.view addSubview:self.personalCenterViewController.view];
        
        [_personalCenterViewController didMoveToParentViewController:self];
        
        _personalCenterViewController.view.frame = CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        [self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
        
    }
    self.showingPersonalVC = YES;
    //
    UIView *view = self.personalCenterViewController.view;
    return view;
    
}

- (void)resetMainView
{
    if (_personalCenterViewController != nil) {
        [self.personalCenterViewController.view removeFromSuperview];
        _personalCenterViewController = nil;
        
        self.showingPersonalVC = NO;
    }
}


- (void)settingThePanelView
{
    //__weak typeof(self) weakSelf = self;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    PersonalCenterViewController *personalVC = [storyboard instantiateViewControllerWithIdentifier:@"PersonalCenterViewController"];
    
//    CustomMainViewController *mainCourseVC = [storyboard instantiateViewControllerWithIdentifier:@"CustomMainVC"];
    [self addChildViewController:personalVC];
    
    
    [self transitionFromViewController:self toViewController:personalVC duration:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
    } completion:^(BOOL finished) {
        if (finished) {
//            weakSelf = personalVC;
        }
        else
        {
            
        }
        
        
        
    }];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    self.navigationController.navigationBarHidden = YES;
}

- (void)showThePersonalCenter
{
    [UIView animateWithDuration:0.3 animations:^{
        
        
        
    } completion:^(BOOL finished) {
        
        
        
        
        
    }];
}

- (void)panRight:(UIPanGestureRecognizer *)sender
{
    [[[sender view] layer] removeAllAnimations];
    
    CGPoint translatedPoint = [sender translationInView:self.view];
    CGPoint velocity = [sender velocityInView:self.view];
    
    if (velocity.x < 0 && !_showingPersonalVC)
        return;
        
    //UIView *childView = nil;
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        
        if (velocity.x >= 6) {
            if (!_showingPersonalVC) {
                [self getThePersonalCenterView];
            }
        }
        else
            return;
        
//        [self.view sendSubviewToBack:childView];
//        [[sender view] bringSubviewToFront:childView];
        
        //[childView sendSubviewToBack:self.view];
//        [[sender ]]
    }
    
    
    CGPoint thePoint = self.view.frame.origin;
    
    NSLog(@"thePoint.x:%f",thePoint.x);
    if (thePoint.x < 0 && velocity.x < 0) {
//        self.view.transform = CGAffineTransformIdentity;
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        return;
    }
    
    CGPoint thePoint1 = self.view.frame.origin;
    
    NSLog(@"thePoint1.x:%f",thePoint1.x);
    
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (self.view.frame.origin.x >= 0 && velocity.x < 0)
        {
            [UIView animateWithDuration:0.2 animations:^{
                self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            
                [self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
            }];
        }
        
        NSLog(@"tranlatedPoint.x:%f",translatedPoint.x);
        
        if ((translatedPoint.x + self.view.frame.origin.x)  >= MAXMOVE) {
            [UIView animateWithDuration:0.2 animations:^{
                
            } completion:^(BOOL finished) {
                if (finished) {
                    NSLog(@"finished");
                    
                }
                
                
            }];
            
        }
        
        
    }
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        NSLog(@"frameWidth:%f theP.x:%f",self.view.frame.size.width,thePoint.x);
        
        
        if (self.view.frame.origin.x == 0 && velocity.x < 0) {
            [UIView animateWithDuration:0.2 animations:^{
                self.view.transform = CGAffineTransformIdentity;
                
            }];
            
            return;
        }
        if (thePoint.x >= (self.view.frame.size.width - 80) && velocity.x > 0) {
            return;
        }
        else if (self.view.frame.origin.x <= 0)
        {
            [UIView animateWithDuration:0.2 animations:^{
                self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            }];
        }
        _showingPanel = fabs([sender view].center.x - _personalCenterViewController.view.frame.size.width/2) > _personalCenterViewController.view.frame.size.width/2;
        
        // Allow dragging only in x-coordinates by only updating the x-coordinate with translation position.
        [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x, [sender view].center.y);
        [sender setTranslation:CGPointMake(0, 0) inView:self.view];
        
        // If you needed to check for a change in direction, you could use this code to do so.
        if(velocity.x*_preVelocity.x + velocity.y*_preVelocity.y > 0) {
            // NSLog(@"same direction");
        } else {
            // NSLog(@"opposite direction");
        }
        
        _preVelocity = velocity;
        
    }
    
}

- (void)movePanelRight//show the left
{
    UIView *childView = [self getThePersonalCenterView];
    [self.view sendSubviewToBack:childView];
    
    [UIView animateWithDuration:.25 animations:^{
        _personalCenterViewController.view.frame = CGRectMake(self.view.frame.size.width + 50, 0, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            _personalCenterViewController.view.tag = 1;
        }
    }];
}

- (void)moveToOriginalPosition
{
    [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _personalCenterViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
    } completion:^(BOOL finished) {
        if (finished) {
            [self resetMainView];
        }
        
    }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}



@end
