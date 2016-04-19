//
//  RegisterTwoViewController.m
//  xygolf
//
//  Created by LiuC on 16/3/28.
//  Copyright © 2016年 dreamer. All rights reserved.
//

#import "RegisterTwoViewController.h"
#import "AFHTTPSessionManager.h"
#import "AFNetworkReachabilityManager.h"

@interface RegisterTwoViewController ()<UIGestureRecognizerDelegate>


@property (strong, nonatomic) AFHTTPSessionManager *httpManager;
@property (strong, nonatomic) AFNetworkReachabilityManager *reachabilityManager;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *numberCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *courseCodeTextField;

- (IBAction)logInButton:(UIButton *)sender;


@end

@implementation RegisterTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /**
     *  隐藏导航栏
     */
    self.navigationController.navigationBarHidden = YES;
    //
    self.httpManager = [AFHTTPSessionManager manager];
    self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [_reachabilityManager startMonitoring];
    
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //
    UITapGestureRecognizer *tapDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTheKeyboard:)];
    tapDismiss.numberOfTouchesRequired = 1;
    tapDismiss.delegate = self;
    [self.view addGestureRecognizer:tapDismiss];
    
}

- (void)dismissTheKeyboard:(UITapGestureRecognizer *)sender
{
    [_nameTextField resignFirstResponder];
    [_courseCodeTextField resignFirstResponder];
    [_numberCodeTextField resignFirstResponder];
}

#pragma mark Responding to keyboard events
- (void)keyboardWillShow:(NSNotification *)notification {
    __weak typeof(self) weakSelf = self;
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    NSDictionary *userInfo = [notification userInfo];
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    UIView *fatherView;
    if ([self.nameTextField isFirstResponder]) {
        fatherView = self.nameTextField.superview;
    }
    else if ([self.numberCodeTextField isFirstResponder])
    {
        fatherView = self.numberCodeTextField.superview;
    }
    else if ([self.courseCodeTextField isFirstResponder])
    {
        fatherView = self.courseCodeTextField.superview;
    }
    
    
    CGFloat firstresViewHeight = fatherView.frame.origin.y + fatherView.frame.size.height;
    CGFloat keyBoardTopYPosition = keyboardRect.origin.y;
    
    CGFloat moveYlength = keyBoardTopYPosition - firstresViewHeight;
    
    if (moveYlength >= 0) {
        [UIView animateWithDuration:0.4 animations:^{
            weakSelf.view.transform = CGAffineTransformIdentity;
        }];
        return;
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0, moveYlength);
        
        weakSelf.view.transform = transform;
        
    }];
    
    
}
- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    //    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
    
    [UIView animateWithDuration:0.4 animations:^{
        self.view.transform = CGAffineTransformIdentity;
        
    }];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)logInButton:(UIButton *)sender {
    if (![_reachabilityManager isReachable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络异常，请检查网络设置" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    //此处进行注册
    
    
    
    
    
    
}
@end
