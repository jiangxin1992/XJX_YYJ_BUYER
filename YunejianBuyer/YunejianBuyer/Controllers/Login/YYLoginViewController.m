//
//  YYLoginViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/5.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYLoginViewController.h"

#import "AppDelegate.h"

#import "CommonMacro.h"
#import "RegexKitLite.h"

#import "ESSAAES.h"
#import "ESSABase64.h"
#import "CommonHelper.h"
#import "YYUserApi.h"

#import "MBProgressHUD.h"
#import "YYUser.h"

#import "Masonry.h"
#import "YYVerifyBuyerViewController.h"
#import "YYForgetPasswordViewController.h"
#import "YYRegisterViewController.h"
#import "YYRspStatusAndMessage.h"
#import "YYUserModel.h"
#import "YYYellowPanelManage.h"
#import "MLInputDodger.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "YYServerURLApi.h"
#import "LanguageManager.h"

static CGFloat animateDuration = 0.3;
static CGFloat viewMargin = 0;


@interface YYLoginViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoTxtImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoTopLayoutConstraint;

@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginViewTopLayoutConstraint;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIView *verificationCodeView;//验证码所在视图
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *verificationCodeButton;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *forgetPasswordButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginButtonTopLayoutConstraint;

@property (nonatomic,assign) CGFloat logoHeightLayoutConstantDefault;//
@property (nonatomic,assign) CGFloat loginViewTopLayoutConstantDefault;//103
@property (nonatomic,assign) CGFloat loginViewMaxYDefault;//

@property (nonatomic,assign) CGFloat keyBoardHeight;
@property (nonatomic,assign) CGFloat verificationCodeViewHeight;

@property (nonatomic,assign) BOOL verificationCodeViewShouldHidden;//验证码是否该隐藏


@property(nonatomic,strong)UITableView *userTableView;//历史账号
@property(nonatomic,strong)NSMutableArray *usersList;
@property(nonatomic,strong)NSMutableArray *filterUsersList;
@end

@implementation YYLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _verificationCodeTextField.placeholder = NSLocalizedString(@"输入验证码",nil);

    _loginButton.layer.cornerRadius = 2.5;
    _verificationCodeButton.layer.cornerRadius = 2.5;
    _loginButton.layer.masksToBounds = YES;
    _verificationCodeButton.layer.masksToBounds = YES;
   
    //bottom 42+44 loginView  240  loinimg 217 logintxtimg 103  top 10
    float logoheight = SCREEN_HEIGHT - 240 - 10 -44 -42;
    logoheight = MIN(logoheight, 218+100);
    float scalRate = logoheight/(218+100);
    float logoimgheight = scalRate*218;
    float logotxtimgheight = scalRate*100;
    [_logoImageView setConstraintConstant:logoimgheight forAttribute:NSLayoutAttributeHeight];
    [_logoTxtImageView setConstraintConstant:logotxtimgheight forAttribute:NSLayoutAttributeHeight];
    _loginViewTopLayoutConstraint.constant = logotxtimgheight;
    float loginViewWidth = SCREEN_WIDTH *0.76;
    [_loginView setConstraintConstant:loginViewWidth forAttribute:NSLayoutAttributeWidth];
    
    self.usernameTextField.placeholder = NSLocalizedString(@"登录邮箱", nil);
    self.passwordTextField.placeholder = NSLocalizedString(@"登录密码", nil);
    [self.loginButton setTitle:NSLocalizedString(@"登　录", nil) forState:UIControlStateNormal];
    [self.registerButton setTitle:NSLocalizedString(@"注册 YCO BUYER 账户", nil) forState:UIControlStateNormal];
    
    _verificationCodeViewShouldHidden = YES;
    _verificationCodeView.hidden = _verificationCodeViewShouldHidden;
    
    self.verificationCodeViewHeight = 60;//;_verificationCodeView.frame.size.height;
    self.logoHeightLayoutConstantDefault = logoimgheight;
    self.loginViewTopLayoutConstantDefault = logotxtimgheight;
    self.loginViewMaxYDefault = -1;
    UIGestureRecognizer *aGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tabPiece:)];
    aGesture.delegate = self;
    [self.view addGestureRecognizer:aGesture];
    
    
    
    [_verificationCodeButton addTarget:self action:@selector(verificationCodeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_loginButton addTarget:self action:@selector(loginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    if(YYDEBUG){
        _usernameTextField.delegate = self;
        _userTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:({
                CGRect frame = CGRectMake(CGRectGetMinX(self.usernameTextField.frame), CGRectGetMaxY(self.usernameTextField.frame), CGRectGetWidth(self.usernameTextField.frame), 150);
                frame;
            })];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.hidden = YES;
            tableView.backgroundColor = [UIColor clearColor];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView;
        });
        [_usernameTextField.superview addSubview:_userTableView];
        
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageLogin];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageLogin];
}

- (NSString *)trimWhitespaceOfStr:(NSString *)string{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (IBAction)verificationCodeButtonClicked:(id)sender{
    [self updateVerificationCode];
}

//更新验证码
- (void)updateVerificationCode{
    _verificationCodeButton.enabled = NO;
    
    WeakSelf(ws);
    
    [YYUserApi getCaptchaWithBlock:^(NSData *imageData, NSError *error) {
        ws.verificationCodeButton.enabled = YES;
        if (imageData) {
            if (!error
                && imageData
                && [imageData length] > 0) {
                UIImage *image = [UIImage imageWithData:imageData];
                [ws.verificationCodeButton setImage:image forState:UIControlStateNormal];
                //[self.view registerAsDodgeViewForMLInputDodger];

            }
        }else{
            [YYToast showToastWithTitle:NSLocalizedString(@"获取验证码失败",nil) andDuration:kAlertToastDuration];
        }
    }];
    
}

- (void)enterMainIndexPage{
    _usernameTextField.text = @"";
    _passwordTextField.text = @"";
    _verificationCodeTextField.text = @"";
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate enterMainIndexPage];
}


- (void)loginByEmail:(NSString *)email password:(NSString *)password verificationCode:(NSString *)verificationCode{
    
    if (![YYCurrentNetworkSpace isNetwork]) {
        [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
        return;
    }
    WeakSelf(ws);
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    verificationCode = verificationCode&&[verificationCode length]?verificationCode:nil;
    
    [YYUserApi loginWithUsername:email password:md5(password) verificationCode:verificationCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYUserModel *userModel, NSError *error) {
     //   NSLog(@"test login %@, %@",rspStatusAndMessage.status,rspStatusAndMessage.message);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        //rspStatusAndMessage.status = kCode305;
        if (rspStatusAndMessage.status == kCode406) {
            //需要输验证码
            [ws updateVerificationCode];
            _verificationCodeViewShouldHidden = NO;
            
            if (!_verificationCodeViewShouldHidden
                && _verificationCodeView.hidden) {
                _verificationCodeView.hidden = _verificationCodeViewShouldHidden;
                _loginButtonTopLayoutConstraint.constant += (viewMargin+_verificationCodeViewHeight);
                
                [UIView animateWithDuration:animateDuration animations:^{
                    [_loginButton layoutIfNeeded];
                    [_registerButton layoutIfNeeded];
                    [_forgetPasswordButton layoutIfNeeded];
                }];
                
                //[_weakSelf moveViewWhenKeyboardIsShow];
            }
            
        }else if (rspStatusAndMessage.status == kCode100 || rspStatusAndMessage.status == kCode1000){
            if([userModel.type integerValue]!= kBuyerStorUserType){
                [YYToast showToastWithView:self.view title:NSLocalizedString(@"当前账户不是买手店身份",nil)  andDuration:kAlertToastDuration];
                return ;
            }
            YYUser *user = [YYUser currentUser];
            NSString *checkStatus = nil;
            if(userModel.checkStatus){
                checkStatus = [userModel.checkStatus stringValue];
            }
            [user saveUserWithEmail:email username:userModel.name password:password userType:[userModel.type intValue] userId:userModel.id logo:userModel.logo status:[userModel.authStatus stringValue] checkStatus:checkStatus];
            if(YYDEBUG){
                if(_usersList ==nil){
                    _usersList = [[NSMutableArray alloc] init];
                }
                
                BOOL isContains = YES;
                for (NSArray *curuser in _usersList) {
                    if([curuser[0] isEqualToString:user.email]){
                        //[curuser setValue:password forKeyPath:@"1"];
                        isContains = NO;
                        break;
                    }
                }
                if(isContains)
                [_usersList addObject:@[user.email,user.name,user.password]];
                BOOL iskeyedarchiver= [NSKeyedArchiver archiveRootObject:_usersList toFile:getUsersStorePath()];
                if(iskeyedarchiver){
                    NSLog(@"archive success ");
                }
            }
            
            //进入首页
            [ws enterMainIndexPage];
            if(rspStatusAndMessage.status == kCode1000 || [user.status integerValue] == kCode305){
                CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:rspStatusAndMessage.message message:nil needwarn:YES delegate:nil cancelButtonTitle:NSLocalizedString(@"下一次再说",nil) otherButtonTitles:@[NSLocalizedString(@"去验证",nil)]];
                alertView.noLongerRemindKey = NoLongerRemindBrand;
                [alertView setAlertViewBlock:^(NSInteger selectedIndex){
                    if (selectedIndex == 1) {
                        //[[NSNotificationCenter defaultCenter] postNotificationName:kShowAccountNotification object:nil];
                    }
                }];
                [alertView show];
            }
            
            [LanguageManager setLanguageToServer];
            
        }else if(rspStatusAndMessage.status == kCode305){
            //                #define kCode305 305 //需要审核
            [self showYellowAlert:ECheckStyleNeedSubmit needVerify:1 userModel:userModel];
        }else if(rspStatusAndMessage.status == kCode301 || rspStatusAndMessage.status == kCode306){
            //#define kCode301 301 //审核被拒//#define kCode306 306 //审核过期
            [self showYellowAlert:ECheckStyleConfirmReject needVerify:1 userModel:userModel];
        }else if(rspStatusAndMessage.status == kCode300){
            //                #define kCode300 300 //审核中
            [self showYellowAlert:ECheckStyleToBeConfirm needVerify:0 userModel:userModel];
        }else if(rspStatusAndMessage.status ==kCode304){
            [YYUserApi reSendMailConfirmMail:userModel.email andUserType:[userModel.type stringValue]  andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if(rspStatusAndMessage.status == kCode100){
                    [YYToast showToastWithTitle: NSLocalizedString(@"发送成功！",nil) andDuration:kAlertToastDuration];
                    [self emailVerfy:email];
                }else{
                    [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                }
            }];
        }else{
            [YYToast showToastWithView:self.view title:rspStatusAndMessage.message  andDuration:kAlertToastDuration];

            //重新获取验证码
            [ws updateVerificationCode];
        }
    }];
    
    
}

- (void)loginButtonClicked:(id)sender{
    NSString *email = [self trimWhitespaceOfStr: _usernameTextField.text];
    NSString *password = [self trimWhitespaceOfStr:_passwordTextField.text];
    NSString *verificationCode = [self trimWhitespaceOfStr:_verificationCodeTextField.text];
  
    //设计师
    //[self loginByEmail:@"designer@yej.com"  password:@"123456" verificationCode:verificationCode];
    
    //买手店
    //[self loginByEmail:@"buyer@yej.com"  password:@"123456" verificationCode:verificationCode];
    
    //销售代表
    //[self loginByEmail:@"salesman@yej.com"  password:@"123456" verificationCode:verificationCode];
     
    if (! email || [email length] == 0) {
        
        [YYToast showToastWithTitle:NSLocalizedString(@"请输入邮箱！",nil) andDuration:kAlertToastDuration];
        return;
    }
    
    BOOL isEmail = [email isMatchedByRegex:@"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b"];
    if (!isEmail) {
        [YYToast showToastWithTitle:NSLocalizedString(@"邮箱格式不对！",nil) andDuration:kAlertToastDuration];
        return;
    }
    
    if (! password || [password length] == 0) {
        [YYToast showToastWithTitle:NSLocalizedString(@"请输入密码！",nil) andDuration:kAlertToastDuration];
        return;
    }
    
    if (!_verificationCodeViewShouldHidden) {
        if (! verificationCode || [verificationCode length] == 0) {
            [YYToast showToastWithTitle:NSLocalizedString(@"请输入验证码！",nil) andDuration:kAlertToastDuration];
            return;
        }
    }
    [_usernameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_verificationCodeTextField resignFirstResponder];
    NSString *localServerURL = [[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL];
    if(YYDEBUG == 0 && localServerURL == nil){
        WeakSelf(ws);
        __block NSString *blockemail = email;
        __block NSString *blockpassword = password;
        __block NSString *blockverificationCode = verificationCode;

        if ([YYCurrentNetworkSpace isNetwork]) {//&& (localServerVersin==nil || ![localServerVersin isEqualToString:kYYCurrentVersion])
            [YYServerURLApi getAppServerURLWidth:^(NSString *serverURL,BOOL isNeedUpdate, NSError *error) {
                if(serverURL != nil){
                    [[NSUserDefaults standardUserDefaults] setObject:serverURL forKey:kLastYYServerURL];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [ws loginByEmail:blockemail  password:blockpassword verificationCode:blockverificationCode];
                }else{
                    [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
                }
            }];
        }else{
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
        }

    }else{
    [self loginByEmail:email  password:password verificationCode:verificationCode];
    }
}

- (IBAction)registerButtonClicked:(id)sender{
    YYRegisterViewController *registerViewController = [[YYRegisterViewController alloc] init];
    registerViewController.registerType = kBuyerStorUserType;
    [self.navigationController pushViewController:registerViewController animated:YES];
}

- (void)showSelectRoleView:(NSInteger)logoHeight{
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//    YYSelectRoleViewController *selectRoleViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYSelectRoleViewController"];
//    if (selectRoleViewController) {
//        __weak UIView *_weakSelectRoleView = selectRoleViewController.view;
//        self.selectRoleViewController = selectRoleViewController;
//        [self.selectRoleViewController updateLogoIcon:logoHeight] ;
//        WeakSelf(weakSelf);
//        __weak UIStoryboard *_weakStoryboard = storyboard;
//        [selectRoleViewController setRoleButtonClicked:^(RoleButtonType buttonType){
//            switch (buttonType) {
//                case RoleButtonTypeBuyer:{
//                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//
//                    [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
//                    YYRegisterViewController *registerViewController = [_weakStoryboard instantiateViewControllerWithIdentifier:@"YYRegisterViewController"];
//                    registerViewController.registerType = kBuyerStorUserType;
//                    [self.navigationController pushViewController:registerViewController animated:YES];
//                    [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
//
//                    //removeFromSuperviewUseUseAnimateAndDeallocViewController(_weakSelectRoleView,weakSelf.selectRoleViewController);
//                }
//                    break;
//                case RoleButtonTypeCancel:{
//                    //                    YYRegisterViewController *registerViewController = [_weakStoryboard instantiateViewControllerWithIdentifier:@"YYRegisterViewController"];
//                    //                    registerViewController.registerType = kForgetPasswordType;
//                    //                    [self.navigationController pushViewController:registerViewController animated:YES];
//                    
//                    removeFromSuperviewUseUseAnimateAndDeallocViewController(_weakSelectRoleView,weakSelf.selectRoleViewController);
//                }
//                    break;
//                    
//                default:
//                    break;
//            }
//        }];
//        
//        
//        
//        [self.view addSubview:_weakSelectRoleView];
//        __weak UIView *_weakSelfView = self.view;
//        [_weakSelectRoleView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_weakSelfView.mas_top);
//            make.left.equalTo(_weakSelfView.mas_left);
//            make.bottom.equalTo(_weakSelfView.mas_bottom);
//            make.right.equalTo(_weakSelfView.mas_right);
//            
//        }];
//    }
}


- (IBAction)forgetPasswordButtonClicked:(id)sender{
    YYForgetPasswordViewController *viewController = [[YYForgetPasswordViewController alloc] init];
    viewController.viewType = kForgetPasswordType;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)emailVerfy:(NSString*)email{
    YYRegisterViewController *registerViewController = [[YYRegisterViewController alloc] init];
    registerViewController.registerType = kEmailRegisterType;
    registerViewController.userEmail = email;
    [self.navigationController pushViewController:registerViewController animated:YES];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 输出点击的view的类名
    NSLog(@"%@", NSStringFromClass([touch.view class]));
    
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}

- (void)tabPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
    if(YYDEBUG){
        CGPoint translatedPoint = [gestureRecognizer locationInView:self.view];
        CGPoint testPoint = [self.view convertPoint:translatedPoint toView:_userTableView];
        if([_userTableView pointInside:testPoint withEvent:nil]){
            return;
        }
    }
    if ([_usernameTextField isFirstResponder]) {
        [_usernameTextField resignFirstResponder];
    }
    
    if ([_passwordTextField isFirstResponder]) {
        [_passwordTextField resignFirstResponder];
    }
    
    if ([_verificationCodeTextField isFirstResponder]) {
        [_verificationCodeTextField resignFirstResponder];
    }
}

- (void)moveViewWhenKeyboardIsShow{
    CGFloat viewOffset = 0;
    if (_verificationCodeViewShouldHidden) {
        viewOffset = _keyBoardHeight - (viewMargin+_verificationCodeViewHeight)+40;
    }else{
        viewOffset = _keyBoardHeight +40;
    }
    if(self.loginViewMaxYDefault < 0){
        self.loginViewMaxYDefault = CGRectGetMaxY(self.loginView.frame);
    }
    float viewSpace = SCREEN_HEIGHT -self.loginViewMaxYDefault;
    float loginViewMoveOffset = 0;
    if(viewSpace < viewOffset){
        loginViewMoveOffset = viewOffset - viewSpace;
    }
    if(loginViewMoveOffset > 0 && _loginViewTopLayoutConstraint.constant > 0){
        if(loginViewMoveOffset > self.loginViewTopLayoutConstantDefault){
            _loginViewTopLayoutConstraint.constant = 0;
             self.logoTxtImageView.alpha = 0.8;
            __block float reduceLoginImgHeight = loginViewMoveOffset -self.loginViewTopLayoutConstantDefault;
            if(reduceLoginImgHeight > 0){
                float logoHeight = self.logoHeightLayoutConstantDefault -reduceLoginImgHeight;
                if(IsPhone5_gt){
                   float logoMinHeight = SCREEN_HEIGHT*0.25 - 10;
                    logoMinHeight = MIN(logoMinHeight, self.logoHeightLayoutConstantDefault);
                    logoHeight = MAX(logoHeight, logoMinHeight);
                }else{
                    logoHeight = 0;//MAX(logoHeight, 0);
                }
                [self.logoImageView setConstraintConstant:logoHeight  forAttribute:NSLayoutAttributeHeight];
            }
            [UIView animateWithDuration:0.5 animations:^{
                [self.loginView layoutIfNeeded];
                self.logoTxtImageView.alpha = 0.0;
                [self.logoImageView layoutIfNeeded];
            } completion:^(BOOL finished) {
            }];

        }else{
            _loginViewTopLayoutConstraint.constant = self.loginViewTopLayoutConstantDefault-loginViewMoveOffset;
            __block BOOL hideTxtFlag = (loginViewMoveOffset> self.loginViewTopLayoutConstantDefault/2);
            if(hideTxtFlag)
            self.logoTxtImageView.alpha = 0.8;
            [UIView animateWithDuration:0.5 animations:^{
                [self.loginView layoutIfNeeded];
                if(hideTxtFlag)
                    self.logoTxtImageView.alpha = 0.0;
            } completion:^(BOOL finished) {
                if(hideTxtFlag)
                    self.logoTxtImageView.hidden = YES;
            }];
        }
    }
    
    //_logoTopLayoutConstraint.constant = _logoTopLayoutConstantDefault - viewOffset;
//    _loginViewTopLayoutConstraint.constant = _loginViewTopLayoutConstantDefault - viewOffset;
//    WeakSelf(seakSelf);
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
//        [UIView animateWithDuration:animateDuration animations:^{
//            [_logoImageView layoutIfNeeded];
//            [_loginView layoutIfNeeded];
//        }];
//    }
}

#pragma mark - 键盘隐藏与消失

- (void)keyboardWillShow:(NSNotification *)note
{
    //获取键盘高度
//    if(self.keyBoardHeight > 0){
//        return;
//    }
    
    NSDictionary *info = [note userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;

    self.keyBoardHeight = keyboardSize.height;
    
    
    [self moveViewWhenKeyboardIsShow];
}

- (void)keyboardWillHide:(NSNotification *)note
{
//    if(self.keyBoardHeight < 0){
//        return;
//    }
    self.keyBoardHeight = 0;
    if(_loginViewTopLayoutConstraint.constant > 0){
        _loginViewTopLayoutConstraint.constant = self.loginViewTopLayoutConstantDefault;
        [UIView animateWithDuration:0.5 animations:^{
            [self.loginView layoutIfNeeded];
            self.logoTxtImageView.hidden = NO;

        } completion:^(BOOL finished) {
            self.logoTxtImageView.alpha = 1;

        }];
    }else{
        [self.logoImageView setConstraintConstant:self.logoHeightLayoutConstantDefault  forAttribute:NSLayoutAttributeHeight];
        [UIView animateWithDuration:0.5 animations:^{
            [self.logoImageView layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.logoTxtImageView.hidden = NO;
            self.loginViewTopLayoutConstraint.constant = self.loginViewTopLayoutConstantDefault;
            [UIView animateWithDuration:animateDuration animations:^{
                self.logoTxtImageView.alpha = 1;
                [self.loginView layoutIfNeeded];
            }];
            
        }];
        
    }
    
    // }
}

#pragma 提示框
-(void)showYellowAlert:(ECheckStyle )checkStyle needVerify:(NSInteger)needVerify userModel:(YYUserModel *)userModel{
    WeakSelf(ws);
    __block NSInteger weakNeedVerify = needVerify;
    [[YYYellowPanelManage instance] showYellowUserCheckAlertPanel:@"Main" andIdentifier:@"YYUserCheckAlertViewController" checkStyle:checkStyle andCallBack:^(NSArray *value) {
        if(weakNeedVerify == 1){
            YYVerifyBuyerViewController *viewController = [[YYVerifyBuyerViewController alloc] init];
            [ws.navigationController pushViewController:viewController animated:YES];
        }else if(weakNeedVerify == 2){
            [YYUserApi reSendMailConfirmMail:userModel.email andUserType:[userModel.type stringValue]  andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if(rspStatusAndMessage.status == kCode100){
                    [YYToast showToastWithTitle:NSLocalizedString(@"发送成功！",nil) andDuration:kAlertToastDuration];
                }else{
                    [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                }
            }];
        }
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    //    self.currentYYOrderInfoModel.buyerName = str;
    if(![str isEqualToString:@""]){
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.email CONTAINS %@",str];
        //_filterUsersList = [_usersList filteredArrayUsingPredicate:predicate];
        _usersList = [NSKeyedUnarchiver unarchiveObjectWithFile:getUsersStorePath()];
        _filterUsersList = [[NSMutableArray alloc] init];
        for (NSArray *user in _usersList) {
            if([user[0] containsString:str]){
                [_filterUsersList addObject:user];
            }
        }
        if(_filterUsersList && [_filterUsersList count] > 0){
            _userTableView.hidden = NO;
            _userTableView.frame = CGRectMake(_userTableView.frame.origin.x, _userTableView.frame.origin.y, CGRectGetWidth(_userTableView.frame), ([_filterUsersList count]*30)) ;
            
        }
        [_userTableView reloadData];
        return YES;
    }
    _userTableView.hidden = YES;
    [_userTableView reloadData];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.text
        && [textField.text length] > 0) {
        _userTableView.hidden = YES;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return (_filterUsersList?[_filterUsersList count]:0);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* reuseIdentifier = @"usercelld";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        //cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }

    NSArray *user = [_filterUsersList objectAtIndex:indexPath.row];
    cell.textLabel.text = user[0];
    cell.detailTextLabel.text = user[1];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_usernameTextField resignFirstResponder];
    if([_filterUsersList count] > indexPath.row){
    NSArray *user = [_filterUsersList objectAtIndex:indexPath.row];
    _usernameTextField.text = user[0];
    _passwordTextField.text = user[2];
    }
}
#pragma mark - Other

//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

- (BOOL)prefersStatusBarHidden
{
    return YES; // 返回NO表示要显示，返回YES将hiden
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
