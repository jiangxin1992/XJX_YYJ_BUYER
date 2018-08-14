//
//  YYUserVerifyCell.m
//  YunejianBuyer
//
//  Created by yyj on 2017/10/24.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYUserVerifyCell.h"

#import "YYUser.h"

@interface YYUserVerifyCell ()

@property (nonatomic,copy) void (^userVerifyBlock)(NSString *type);

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *f_titleLabel;
@property (nonatomic,strong) UIButton *verifyButton;

@end

@implementation YYUserVerifyCell

#pragma mark - --------------生命周期--------------
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type))block{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _userVerifyBlock = block;
        [self SomePrepare];
        [self UIConfig];
    }
    return self;
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{}
- (void)PrepareUI{
    self.contentView.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    _verifyButton = [UIButton getCustomTitleBtnWithAlignment:0 WithFont:15.0f WithSpacing:0 WithNormalTitle:nil WithNormalColor:nil WithSelectedTitle:nil WithSelectedColor:nil];
    [self.contentView addSubview:_verifyButton];
    [_verifyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-17);
        make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo(115);
        make.height.mas_equalTo(40);
    }];
    _verifyButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    _verifyButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 8);
    _verifyButton.layer.masksToBounds = YES;
    _verifyButton.layer.cornerRadius = 3.0f;
    _verifyButton.layer.borderColor = [_define_black_color CGColor];
    [_verifyButton addTarget:self action:@selector(verifyAction) forControlEvents:UIControlEventTouchUpInside];

    _titleLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:14.0f WithTextColor:nil WithSpacing:0];
    [self.contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.bottom.mas_equalTo(self.contentView.mas_centerY).with.offset(-5);
        make.right.mas_equalTo(_verifyButton.mas_left).with.offset(-5);
    }];

    _f_titleLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:12.0f WithTextColor:nil WithSpacing:0];
    [self.contentView addSubview:_f_titleLabel];
    [_f_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.top.mas_equalTo(self.contentView.mas_centerY).with.offset(5);
        make.right.mas_equalTo(_verifyButton.mas_left).with.offset(-5);
    }];
}

#pragma mark - --------------请求数据----------------------
-(void)RequestData{}

#pragma mark - --------------自定义响应----------------------
-(void)verifyAction{
    if(_userVerifyBlock){
        YYUser *user = [YYUser currentUser];
        //1:待提交文件 2:待审核 3:审核通过 4:审核拒绝 5:停止
        NSInteger checkStatus = [user.checkStatus integerValue];
        if(checkStatus == 1 || checkStatus == 4){
            _userVerifyBlock(@"fillInformation");
        }
    }
}

#pragma mark - --------------自定义方法----------------------
-(void)updateUI{
    BOOL isShow = [self getCheckStatusIsShow];
    if(isShow){
        _titleLabel.hidden = NO;
        _f_titleLabel.hidden = NO;
        _verifyButton.hidden = NO;
        YYUser *user = [YYUser currentUser];
        //1:待提交文件 2:待审核 3:审核通过 4:审核拒绝 5:停止
        NSInteger checkStatus = [user.checkStatus integerValue];
        if(checkStatus == 1){
            //1:待提交文件
            _titleLabel.textColor =_define_black_color;
            _titleLabel.text = NSLocalizedString(@"请您完善资料", nil);

            _f_titleLabel.textColor = [UIColor colorWithHex:@"919191"];
            _f_titleLabel.text = NSLocalizedString(@"以便获得正常的使用权限与体验", nil);

            _verifyButton.layer.borderWidth = 1;
            _verifyButton.enabled = YES;
            _verifyButton.backgroundColor = _define_white_color;
            [_verifyButton setImage:[UIImage imageNamed:@"user_verify_black"] forState:UIControlStateNormal];
            [_verifyButton setTitleColor:_define_black_color forState:UIControlStateNormal];
            [_verifyButton setTitle:NSLocalizedString(@"完善资料", nil) forState:UIControlStateNormal];

        }else if(checkStatus == 2){
            //2:待审核
            _titleLabel.textColor =_define_black_color;
            _titleLabel.text = NSLocalizedString(@"买手店正在审核中，请耐心等待", nil);

            _f_titleLabel.textColor = [UIColor colorWithHex:@"919191"];
            _f_titleLabel.text = NSLocalizedString(@"未通过验证的买手账号将被锁定", nil);

            _verifyButton.layer.borderWidth = 0;
            _verifyButton.enabled = NO;
            _verifyButton.backgroundColor = [UIColor colorWithHex:@"d3d3d3"];
            [_verifyButton setImage:[UIImage imageNamed:@"user_verify_white"] forState:UIControlStateNormal];
            [_verifyButton setTitleColor:_define_white_color forState:UIControlStateNormal];
            [_verifyButton setTitle:NSLocalizedString(@"完善资料", nil) forState:UIControlStateNormal];

        }else if(checkStatus == 4){
            //4:审核拒绝
            _titleLabel.textColor =[UIColor colorWithHex:@"EF4E31"];
            _titleLabel.text = NSLocalizedString(@"身份验证失败！", nil);

            _f_titleLabel.textColor = [UIColor colorWithHex:@"919191"];
            _f_titleLabel.text = NSLocalizedString(@"您可以在邮件中查看审核失败的原因", nil);

            _verifyButton.layer.borderWidth = 1;
            _verifyButton.enabled = YES;
            _verifyButton.backgroundColor = _define_white_color;
            [_verifyButton setImage:[UIImage imageNamed:@"user_verify_black"] forState:UIControlStateNormal];
            [_verifyButton setTitleColor:_define_black_color forState:UIControlStateNormal];
            [_verifyButton setTitle:NSLocalizedString(@"再次验证", nil) forState:UIControlStateNormal];
            
        }
    }else{
        _titleLabel.hidden = YES;
        _f_titleLabel.hidden = YES;
        _verifyButton.hidden = YES;
    }
}

/**
 是否显示 1:待提交文件 2:待审核 4:审核拒绝 就这三种符合

 @return ...
 */
-(BOOL )getCheckStatusIsShow{
    BOOL isShow = NO;
    if(![[YYUser currentUser] hasPermissionsToVisit]){
        YYUser *user = [YYUser currentUser];
        //1:待提交文件 2:待审核 3:审核通过 4:审核拒绝 5:停止
        NSInteger checkStatus = [user.checkStatus integerValue];
        if(checkStatus == 1 || checkStatus == 2 || checkStatus == 4){
            isShow = YES;
        }
    }
    return isShow;
}

#pragma mark - --------------other----------------------
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
