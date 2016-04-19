//
//  ViewController.m
//  xygolf
//
//  Created by LiuC on 16/3/23.
//  Copyright © 2016年 dreamer. All rights reserved.
//

#import "LogInViewController.h"
#import "AFURLRequestSerialization.h"
#import "AFHTTPSessionManager.h"
#import "AFNetworkReachabilityManager.h"
#import "xygolfmacroHeader.h"

@interface LogInViewController ()<UIGestureRecognizerDelegate>

@property (strong, nonatomic) TencentOAuth *theTencentOAuth;

@property (strong, nonatomic) AFHTTPSessionManager *afnetworkingManager;
@property (strong, nonatomic) AFNetworkReachabilityManager *reachabilityManager;





@property (weak, nonatomic) IBOutlet UITextField *accountInputText;
@property (weak, nonatomic) IBOutlet UITextField *passwordInputText;


- (IBAction)forgetPassword:(UIButton *)sender;

- (IBAction)LogInButton:(UIButton *)sender;

- (IBAction)RegisterNewUser:(UIButton *)sender;

- (IBAction)tencentQQSignIn:(UIButton *)sender;
- (IBAction)tencentWeChatSignIn:(UIButton *)sender;
- (IBAction)sinaWeiBoSignIn:(UIButton *)sender;






@end

@implementation LogInViewController



- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBarHidden = YES;
    //
    self.afnetworkingManager = [AFHTTPSessionManager manager];
    
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
    
    //修改placeholder的字体颜色
    [_accountInputText setValue:[UIColor colorWithRed:20/255.0 green:138/255.0 blue:89/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    [_accountInputText addObserver:self forKeyPath:@"account" options:NSKeyValueObservingOptionNew context:nil];
    
    [_passwordInputText setValue:[UIColor colorWithRed:20/255.0 green:138/255.0 blue:89/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"account"]) {
        NSLog(@"enter and change=====%@",change);
    }
    
    
    
}


- (void)dismissTheKeyboard:(UITapGestureRecognizer *)sender
{
    [_accountInputText resignFirstResponder];
    [_passwordInputText resignFirstResponder];
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
    if ([self.accountInputText isFirstResponder]) {
        fatherView = self.accountInputText;
    }
    else if ([self.passwordInputText isFirstResponder])
    {
        fatherView = self.passwordInputText;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //
    self.navigationController.navigationBarHidden = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)TXQQSignInProcess
{
    //permission
    NSArray* permissions = [NSArray arrayWithObjects:
                            kOPEN_PERMISSION_GET_USER_INFO,
                            kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                            kOPEN_PERMISSION_ADD_SHARE,
                            nil];
    _theTencentOAuth = [[TencentOAuth alloc] initWithAppId:TXQQAppID andDelegate:self];
    [_theTencentOAuth authorize:permissions inSafari:NO];
    
}

- (void)tencentDidLogin
{
    NSLog(@"登录成功");
//    _labelTitle.text = @"登录完成";
    
    if (_theTencentOAuth.accessToken && 0 != [_theTencentOAuth.accessToken length])
    {
        //  记录登录用户的OpenID、Token以及过期时间
//        _labelAccessToken.text = __tencentOAuth.accessToken;
        NSLog(@"accessToken:%@",_theTencentOAuth.accessToken);
        
    }
    else
    {
//        _labelAccessToken.text = @"登录不成功 没有获取accesstoken";
        NSLog(@"登录不成功 没有获取accesstoken");
        
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled) {
        NSLog(@"用户取消登录");
    }
    else
    {
        NSLog(@"登录失败");
    }
}

- (void)tencentDidNotNetWork
{
    NSLog(@"tencent 无网络连接");
}


- (IBAction)accountInputConfirm:(UIButton *)sender {
    
    
    
}

- (IBAction)forgetPassword:(UIButton *)sender {
    
    
}


- (IBAction)LogInButton:(UIButton *)sender {
    [self performSegueWithIdentifier:@"toMainViewController" sender:nil];
    return;
    /*
    if (![_reachabilityManager isReachable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络异常,请检查网络是否连接" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    NSString *account = self.accountInputText.text;
    NSString *passwd = self.passwordInputText.text;
    
    
    NSDictionary *logInParam = @{@"username":account,@"passwd":passwd};
    //
    [_afnetworkingManager GET:@"http://192.168.1.139:8080/user/clogin" parameters:logInParam progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObj:%@",responseObject);
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error:%@",error.localizedDescription);
        NSLog(@"des=============:%@",error.description);
        NSLog(@"localizedDescription=============:%@",error.localizedDescription);
        
        NSString *afa;
        NSData *data = [afa dataUsingEncoding:NSUTF8StringEncoding];
        
        [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
    }];
    */
    
}

- (IBAction)RegisterNewUser:(UIButton *)sender {
//    [self performSegueWithIdentifier:@"toRegisterView" sender:nil];
    
}

//- (IBAction)registerButton:(UIButton *)sender {
//    
//    if (![_reachabilityManager isReachable]) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络异常,请检查网络是否连接" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
//        [alert show];
//        return;
//    }
////    //
////    NSDictionary *registerParam = @{@"username":@"15730216180",@"passwd":@"123456",@"code":@"755001"};
////    //
////    [_afnetworkingManager POST:@"http://192.168.1.128:8089/user/manager" parameters:registerParam progress:^(NSProgress * _Nonnull uploadProgress) {
////        
////        
////        
////    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
////        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
////        
////        NSLog(@"respond:%@",resultDic);
////        
////        
////    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
////        NSLog(@"err:%@",error.localizedDescription);
////        
////        
////    }];
//    
//}

- (IBAction)tencentQQSignIn:(UIButton *)sender {
    [self TXQQSignInProcess];
    
    
}

- (IBAction)tencentWeChatSignIn:(UIButton *)sender {
    
    
    
}

- (IBAction)sinaWeiBoSignIn:(UIButton *)sender {
    
    
}
@end
