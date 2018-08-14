//
//  YYShareView.m
//  YunejianBuyer
//
//  Created by yyj on 2017/6/5.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYShareView.h"

#import "YYTypeButton.h"

@implementation YYShareView
#pragma mark - init
-(instancetype)initWithParams:(NSDictionary *)params WithBlock:(void(^)(NSString *type,SSDKPlatformType platformType))block{
    self = [super init];
    if(self){
        _block = block;
        [self SomePrepare];
        [self UIConfig];
    }
    return self;
}

#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}

-(void)PrepareData{}
-(void)PrepareUI{}

#pragma mark - UIConfig
-(void)UIConfig{

    self.backgroundColor = _define_white_color;
    
    self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 182 + kBottomSafeAreaHeight);
    
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = _define_white_color;
    [self addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(kBottomSafeAreaHeight);
    }];
    
    UIButton *cancelButton = [UIButton getCustomTitleBtnWithAlignment:0 WithFont:15.0f WithSpacing:0 WithNormalTitle:NSLocalizedString(@"取消",nil) WithNormalColor:nil WithSelectedTitle:nil WithSelectedColor:nil];
    [self addSubview:cancelButton];
    [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.equalTo(bottomView.mas_top);
        make.height.mas_equalTo(50);
    }];
    
    UIView *line = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EFEFEF"]];
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(cancelButton.mas_top).with.offset(0);
        make.height.mas_equalTo(1);
    }];
    
    NSArray *typeArr = nil;
    CGFloat _jianju = 0;
    CGFloat _bianju = 0;
    NSDictionary *imageDict = @{
                              @"wechat":@"Share_Weixin"
                              ,@"wechat_friend":@"Share_Friendcircle"
                              ,@"sina":@"Share_Weibo"
                              ,@"copy":@"Share_Copylink"
                              };
    
    NSDictionary *titleDict = @{
                                @"wechat":NSLocalizedString(@"微信好友",nil)
                                ,@"wechat_friend":NSLocalizedString(@"微信朋友圈",nil)
                                ,@"sina":NSLocalizedString(@"新浪微博",nil)
                                ,@"copy":NSLocalizedString(@"复制链接",nil)
                                };
    if([self isInstallWeChat]){
        //安装微信
//        YYTypeButton
        typeArr = @[@"wechat",@"wechat_friend",@"sina",@"copy"];
        _jianju = (SCREEN_WIDTH - 50*4 -40)/3.0f;
        _bianju = 20;
    }else{
        //未安装微信
        typeArr = @[@"sina",@"copy"];
        _jianju = 75;
        _bianju = (SCREEN_WIDTH - _jianju - 50*2)/2.0f;
    }
    UIView *lastView = nil;
    for (int i=0; i<typeArr.count; i++) {
        YYTypeButton *btn = [YYTypeButton getCustomImgBtnWithImageStr:[imageDict objectForKey:typeArr[i]] WithSelectedImageStr:nil];
        [self addSubview:btn];
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 25;
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = [[UIColor colorWithHex:@"EFEFEF"] CGColor];
        btn.type = typeArr[i];
        [btn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            if(lastView){
                make.left.mas_equalTo(lastView.mas_right).with.offset(_jianju);
            }else{
                make.left.mas_equalTo(_bianju);
            }
            make.width.height.mas_equalTo(50);
            make.top.mas_equalTo(20);
        }];
        
        UILabel *btnLabel = [UILabel getLabelWithAlignment:1 WithTitle:[titleDict objectForKey:typeArr[i]] WithFont:12.0f WithTextColor:nil WithSpacing:0];
        [self addSubview:btnLabel];
        [btnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(btn);
            make.top.mas_equalTo(btn.mas_bottom).with.offset(10);
        }];
        lastView = btn;
    }
}
#pragma mark - SomeAction
- (void)show {
    [UIView animateWithDuration:0.2 animations:^{
        self.frame=CGRectMake(0, SCREEN_HEIGHT - CGRectGetHeight(self.frame), SCREEN_WIDTH, CGRectGetHeight(self.frame));
    }];
}

-(void)shareAction:(YYTypeButton *)typeBtn{

    if(_block){
        if([typeBtn.type isEqualToString:@"wechat"]){
            
            _block(@"share",SSDKPlatformSubTypeWechatSession);
            
        }else if([typeBtn.type isEqualToString:@"wechat_friend"]){
            
            _block(@"share",SSDKPlatformSubTypeWechatTimeline);
            
        }else if([typeBtn.type isEqualToString:@"sina"]){
            
            _block(@"share",SSDKPlatformTypeSinaWeibo);
            
        }else if([typeBtn.type isEqualToString:@"copy"]){
            
            _block(@"share",SSDKPlatformTypeCopy);
        }
    }
}
-(void)cancelAction{
    if(_block){
        _block(@"cancel",0);
    }
}
/**
 * 当前设备是否安装微信
 */
-(BOOL)isInstallWeChat
{
    return [ShareSDK isClientInstalled:SSDKPlatformTypeWechat];
}
+(NSMutableDictionary *)getShareParamsWithType:(NSString *)type WithShare_type:(SSDKPlatformType )platformType WithShareParams:(NSDictionary *)params
{
//    @{
//      @"orderingName":_orderingModel.name
//      ,@"orderingUrl":_weburl
//      ,@"poster":_orderingModel.poster
//      ,@"buyerStoreName":user.name
//      }]
    //1、创建分享参数（必要）
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    if([type isEqualToString:@"ordering_detail"])
    {
        
        NSString *poster = [NSString stringWithFormat:@"%@%@",[params objectForKey:@"poster"],kLookBookImage];
        NSString *orderingUrl = [params objectForKey:@"orderingUrl"];
        NSString *orderingName = [params objectForKey:@"orderingName"];
        NSString *buyerStoreName = [params objectForKey:@"buyerStoreName"];
        UIImage *downloadPic = [params objectForKey:@"downloadPic"];
        
        if(platformType==SSDKPlatformSubTypeWechatSession)
        {
            //        微信
            // 定制微信好友的分享内容
            [shareParams SSDKSetupWeChatParamsByText:[[NSString alloc] initWithFormat:@"from %@",buyerStoreName] title:[[NSString alloc] initWithFormat:@"YCO SYSTEM_%@",orderingName] url:[NSURL URLWithString:orderingUrl] thumbImage:nil image:poster musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeAuto forPlatformSubType:platformType];// 微信好友子平台
        }else if(platformType==SSDKPlatformSubTypeWechatTimeline)
        {
            //        朋友圈
            // 定制微信好友的分享内容
            [shareParams SSDKSetupWeChatParamsByText:nil title:[[NSString alloc] initWithFormat:@"%@\n%@",[[NSString alloc] initWithFormat:@"YCO SYSTEM_%@",orderingName],[[NSString alloc] initWithFormat:@"from %@",buyerStoreName]] url:[NSURL URLWithString:orderingUrl] thumbImage:nil image:poster musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeAuto forPlatformSubType:platformType];// 微信好友子平台
        }else if(platformType==SSDKPlatformTypeSinaWeibo)
        {
            //        微博
            NSString *textstr = [[NSString alloc] initWithFormat:@"YCO SYSTEM_%@（分享自@云衣间） %@",orderingName,orderingUrl];
            [shareParams SSDKSetupSinaWeiboShareParamsByText:textstr title:nil images:downloadPic video:nil url:[NSURL URLWithString:orderingUrl] latitude:0 longitude:0 objectID:nil isShareToStory:NO type:SSDKContentTypeAuto];
            
        }else if(platformType==SSDKPlatformTypeCopy)
        {
            //        复制
//            [shareParams SSDKSetupCopyParamsByText:[[NSString alloc] initWithFormat:@"YCO SYSTEM_%@。点击 %@ 即刻预约",orderingName,orderingUrl] images:poster url:[NSURL URLWithString:orderingUrl] type:SSDKContentTypeText];
            [shareParams SSDKSetupCopyParamsByText:orderingUrl images:poster url:[NSURL URLWithString:orderingUrl] type:SSDKContentTypeText];
        }
    }
    return shareParams;
}

@end
