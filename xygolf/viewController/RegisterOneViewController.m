//
//  RegisterOneViewController.m
//  xygolf
//
//  Created by LiuC on 16/3/28.
//  Copyright © 2016年 dreamer. All rights reserved.
//

#import "RegisterOneViewController.h"
#import "AFHTTPSessionManager.h"
#import "AFNetworkReachabilityManager.h"
#import "customAlertView.h"

@interface RegisterOneViewController ()<UIGestureRecognizerDelegate>
{
    customAlertView *cusAlert;
    UIView *defaultBackView;
}



@property (strong, nonatomic) AFHTTPSessionManager *afhttpManager;
@property (strong, nonatomic) AFNetworkReachabilityManager *reachabilityManager;


@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UITextField *msgCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;



@property (weak, nonatomic) IBOutlet UIButton *getCheckMsgOrWait;


- (IBAction)getCheckMsgCode:(UIButton *)sender;





@end

@implementation RegisterOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor yellowColor], [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6],[UIFont fontWithName:@"" size:24.0],nil]];
//    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    //
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_logRegister.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backToLogInView)];
    self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
    
    [self.navigationItem setLeftBarButtonItem:leftBarButton];
    
    //
    [_mobileTextField setValue:[UIColor colorWithRed:194/255.0 green:225/255.0 blue:210/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    [_msgCodeTextField setValue:[UIColor colorWithRed:194/255.0 green:225/255.0 blue:210.0/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    [_passwordTextField setValue:[UIColor colorWithRed:194.0/255.0 green:225.0/255.0 blue:210.0/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    [_confirmPasswordTextField setValue:[UIColor colorWithRed:194.0/255.0 green:225.0/255.0 blue:210.0/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    
    //
    self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [_reachabilityManager startMonitoring];
    
//    self.afhttpManager = [AFHTTPSessionManager manager];
//    self.getCheckMsgOrWait.titleLabel.text = @"获取验证码";
//    self.getCheckMsgOrWait.titleLabel.textColor = [UIColor blueColor];
//    self.getCheckMsgOrWait.enabled = YES;
//    
//    self.msgCodeTextField.placeholder = @"获取验证码...";
    
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //
    UITapGestureRecognizer *tapDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTheKeyboard:)];
    tapDismiss.numberOfTouchesRequired = 1;
    tapDismiss.delegate = self;
    [self.view addGestureRecognizer:tapDismiss];
    
}

- (void)backToLogInView
{
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //
    self.navigationController.navigationBarHidden = NO;
    
}

- (void)dismissTheKeyboard:(UITapGestureRecognizer *)sender
{
    [_mobileTextField resignFirstResponder];
    [_msgCodeTextField resignFirstResponder];
    [_getCheckMsgOrWait resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_confirmPasswordTextField resignFirstResponder];
    
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
    if ([self.mobileTextField isFirstResponder]) {
        fatherView = self.mobileTextField.superview;
    }
    else if ([self.msgCodeTextField isFirstResponder])
    {
        fatherView = self.msgCodeTextField.superview;
    }
    else if ([self.passwordTextField isFirstResponder])
    {
        fatherView = self.passwordTextField.superview;
    }
    else if ([self.confirmPasswordTextField isFirstResponder])
    {
        fatherView = self.confirmPasswordTextField.superview;
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

-(void)startTime{
    __block int timeout=59; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置 特别注明：UI的改变一定要在主线程中进行
                
//                _getCheckMsgOrWait.titleLabel.textColor = [UIColor blueColor];
                
                [_getCheckMsgOrWait setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                
                [_getCheckMsgOrWait setTitle:@"重新发送" forState:UIControlStateNormal];
                _getCheckMsgOrWait.userInteractionEnabled = YES;
                _msgCodeTextField.placeholder = @"输入验证码";
                
                [self.view setNeedsDisplay];
            });
        }else{
            //            int minutes = timeout / 60;
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
//                NSLog(@"____%@",strTime);
                [_getCheckMsgOrWait setTitle:[NSString stringWithFormat:@"%@秒后重发",strTime] forState:UIControlStateNormal];
                _getCheckMsgOrWait.userInteractionEnabled = NO;
                
            });
            timeout--;
            
        }
    });
    dispatch_resume(_timer);
    
}

- (BOOL)validateMobile:(NSString *)mobileNum

{
    
    /**
     
     * 手机号码
     
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     
     * 联通：130,131,132,152,155,156,185,186
     
     * 电信：133,1349,153,180,189
     
     */
    
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    
    /**
     
     10         * 中国移动：China Mobile
     
     11         * 134[0-8],135,136,137,138,139,150,151,152,157,158,159,182,187,188  147,183
     
     12         */
    
    NSString * CM = @"^1(34[0-8]|(3[5-9]|47|5[0-27-9]|8[2378])\\d)\\d{7}$";
    
    /**
     
     15         * 中国联通：China Unicom
     
     16         * 130,131,132,155,156,185,186
     
     17         */
    
    NSString * CU = @"^1(3[0-2]|5[56]|76|8[56])\\d{8}$";
    
    /**
     
     20         * 中国电信：China Telecom
     
     21         * 133,1349,153,180,189
     
     22         */
    
    NSString * CT = @"^1((33|53|77|8[019])[0-9]|349)\\d{7}$";
    
    /**
     
     25         * 大陆地区固话及小灵通
     
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     
     27         * 号码：七位或八位
     
     28         */
    
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",MOBILE];
    
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CM];
    
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CU];
    
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CT];
    
    if(([regextestmobile evaluateWithObject:mobileNum] == YES)
       
       || ([regextestcm evaluateWithObject:mobileNum] == YES)
       
       || ([regextestct evaluateWithObject:mobileNum] == YES)
       
       || ([regextestcu evaluateWithObject:mobileNum] == YES))
        
    {
        return YES;
    }
    
    else
        
    {
        return NO;
    }
    
}

- (IBAction)getCheckMsgCode:(UIButton *)sender {
    NSString *theMobileNum = _mobileTextField.text;
    
    if (![self validateMobile:theMobileNum] ||  (theMobileNum.length <= 10)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"输入号码有误" message:nil delegate:self
                                              cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    if (![_reachabilityManager isReachable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络异常，请检查网络设置" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    
    
    [_getCheckMsgOrWait setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.msgCodeTextField.placeholder = @"正在发送验证码...";
    //
    UIColor *waitMsgtheColor = [UIColor lightGrayColor];
    
    [_getCheckMsgOrWait setTitleColor:waitMsgtheColor forState:UIControlStateNormal];
    [self startTime];
    //3AA7E0
    NSString *registerMobileNum = self.mobileTextField.text;
    
    NSDictionary *getCheckCodeParam = @{@"mobile":@"15730216180",@"smstype":@"0"};
    
    
    
    
    if ([registerMobileNum length] == 11) {
        //
        [_afhttpManager GET:@"http://192.168.1.128:8089/user/captcha" parameters:getCheckCodeParam progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"responseObject:%@",responseObject);
//            NSDictionary *theCodeDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
//            NSLog(@"code:%@",theCodeDic);
            
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error:%@",error.localizedDescription);
            
            
        }];
        
        
        
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"手机号码输入有误" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
    }
    
    
    
}
//
//- (IBAction)showTheCode:(UIButton *)sender {
//    BOOL NoshowCodeEnable = !self.passwordTextField.secureTextEntry;
//    self.passwordTextField.secureTextEntry = NoshowCodeEnable;
//    self.confirmPasswordTextField.secureTextEntry = NoshowCodeEnable;
//    //
//    if (NoshowCodeEnable) {
//        [_showTheCodeButton setTitle:@"显示密码" forState:UIControlStateNormal];
//    }
//    else
//    {
//        [_showTheCodeButton setTitle:@"隐藏密码" forState:UIControlStateNormal];
//    }
//}

- (IBAction)registerNewUser:(UIButton *)sender {
    //
    defaultBackView = [[UIView alloc] initWithFrame:self.view.bounds];
    [defaultBackView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    [self.view addSubview:defaultBackView];
    //
    cusAlert = [[customAlertView alloc] initWithFrame:CGRectMake(0, 0, 300, 190)];
    [self.view addSubview:cusAlert];
    
    cusAlert.label.text = @"注册成功";
    cusAlert.backImageView.image = [UIImage imageNamed:@"regSuccess_logRegister.png"];
    [cusAlert.firstbutton setTitle:@"进入应用" forState:UIControlStateNormal];
    [cusAlert.firstbutton addTarget:self action:@selector(enterMainMap) forControlEvents:UIControlEventTouchUpInside];
    [cusAlert.firstbutton.titleLabel setTextColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]];
    [cusAlert.firstbutton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [cusAlert.firstbutton setBackgroundColor:[UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1.0]];
    
    [cusAlert.secondbutton setTitle:@"完善资料" forState:UIControlStateNormal];
    [cusAlert.secondbutton addTarget:self action:@selector(finishPersonalInfo) forControlEvents:UIControlEventTouchUpInside];
    [cusAlert.secondbutton.titleLabel setTextColor:[UIColor colorWithRed:10/255.0 green:126/255.0 blue:81/255.0 alpha:1.0]];
    
    [cusAlert show];
    
    
    
    
    /*
    NSString *Thecode = self.msgCodeTextField.text;
    //
    NSDictionary *registerParam = @{@"username":@"15730216180",@"passwd":@"123456",@"code":Thecode};
    //
    [_afhttpManager POST:@"http://192.168.1.128:8089/user/manager" parameters:registerParam progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        
//        NSLog(@"respond:%@",resultDic);
        NSLog(@"");
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"err:%@",error.localizedDescription);
        
        
    }];
     */
}

- (void)enterMainMap
{
    NSLog(@"进入主页面");
    [cusAlert dismiss];
    
    [UIView animateWithDuration:0.5f animations:^{
        [defaultBackView removeFromSuperview];
    }];
    
}

- (void)finishPersonalInfo
{
    NSLog(@"完善个人信息");
    [cusAlert dismiss];
    
    [UIView animateWithDuration:0.5f animations:^{
        [defaultBackView removeFromSuperview];
    }];
}


@end
