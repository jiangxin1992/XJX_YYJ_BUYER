//
//  YYBuyerMessageCell.m
//  Yunejian
//
//  Created by yyj on 15/8/21.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYBuyerMessageCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "SCGIFImageView.h"

// 接口

// 分类
#import "UIImage+YYImage.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYOrderInfoModel.h"
#import "UserDefaultsMacro.h"

@interface YYBuyerMessageCell ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet SCGIFImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *logoNameLabel;

@end

@implementation YYBuyerMessageCell
#pragma mark - --------------生命周期--------------
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type))block{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self SomePrepare];
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
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _logoImageView.layer.borderWidth = 1;
    _logoImageView.layer.borderColor = [UIColor colorWithHex:@"919191"].CGColor;
    _logoImageView.layer.cornerRadius = 2.5;
    _logoImageView.layer.masksToBounds = YES;

    UIButton *addbtn = [self.contentView viewWithTag:10001];
    addbtn.layer.borderWidth = 1;
    addbtn.layer.borderColor = [UIColor colorWithHex:@"d3d3d3"].CGColor;
    addbtn.layer.cornerRadius = 2.5;
    addbtn.layer.masksToBounds = YES;
    _view2.hidden = NO;
}

#pragma mark - --------------UpdateUI----------------------
- (void)updateUI{
    if(_currentYYOrderInfoModel.brandLogo){
        sd_downloadWebImageWithRelativePath(NO, _currentYYOrderInfoModel.brandLogo, _logoImageView, kLogoCover ,0);
    }else{
        _logoImageView.image = [UIImage imageNamed:@"default_icon"];
    }
    _logoNameLabel.text = _currentYYOrderInfoModel.brandName;
}

#pragma mark - --------------系统代理----------------------

#pragma mark - --------------自定义响应----------------------
- (IBAction)oprateBtnHandler:(id)sender {
    if(self.delegate){
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:nil];
    }else{
        NSLog(@"111");
    }
}

#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------other----------------------
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
@end
