//
//  YYIndexOrderingNoDataCell.m
//  YunejianBuyer
//
//  Created by yyj on 2017/8/11.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYIndexOrderingNoDataCell.h"

@interface YYIndexOrderingNoDataCell()

@property(nonatomic,copy) void (^indexOrderingNoDataBlock)(NSString *type);

@end

@implementation YYIndexOrderingNoDataCell

#pragma mark - --------------生命周期--------------
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type))block{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _indexOrderingNoDataBlock = block;
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
    self.contentView.backgroundColor = _define_white_color;
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    UIImageView *imageView = [UIImageView getImgWithImageStr:@"ordering_nodata"];
    [self.contentView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(35);
        make.width.mas_equalTo(79);
        make.height.mas_equalTo(74);
        make.centerX.mas_equalTo(self.contentView);
    }];

    UILabel *titleLabel = [UILabel getLabelWithAlignment:1 WithTitle:NSLocalizedString(@"暂无可预约的订货会",nil) WithFont:13.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [self.contentView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.right.mas_equalTo(-17);
        make.top.mas_equalTo(imageView.mas_bottom).with.offset(18);
    }];

//    UIButton *checkOldOrderingButton = [UIButton getCustomTitleBtnWithAlignment:0 WithFont:15.0f WithSpacing:0 WithNormalTitle:NSLocalizedString(@"查看往期订货会",nil) WithNormalColor:_define_white_color WithSelectedTitle:nil WithSelectedColor:nil];
//    [self.contentView addSubview:checkOldOrderingButton];
//    [checkOldOrderingButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(titleLabel.mas_bottom).with.offset(21);
//        make.height.mas_equalTo(40);
//        make.left.mas_equalTo(62);
//        make.right.mas_equalTo(-62);
//    }];
//    checkOldOrderingButton.backgroundColor = _define_black_color;
//    [checkOldOrderingButton addTarget:self action:@selector(checkOldOrderingAction) forControlEvents:UIControlEventTouchUpInside];
}

//#pragma mark - --------------自定义响应----------------------
//查看往期订货会
//-(void)checkOldOrderingAction{
//    if(_indexOrderingNoDataBlock){
//        _indexOrderingNoDataBlock(@"check_old_ordering");
//    }
//}

//#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------other----------------------
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
