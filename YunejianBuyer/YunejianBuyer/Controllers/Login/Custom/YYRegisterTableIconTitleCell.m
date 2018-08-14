//
//  YYRegisterTableIconTitleCell.m
//  YunejianBuyer
//
//  Created by Victor on 2017/12/26.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYRegisterTableIconTitleCell.h"
@interface YYRegisterTableIconTitleCell()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation YYRegisterTableIconTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth([UIScreen mainScreen].bounds), 0, 0);
        __weak typeof (self)weakSelf = self;
        
        self.iconImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(34);
            make.height.mas_equalTo(34);
            make.left.mas_equalTo(13);
            make.bottom.mas_equalTo(0);
        }];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor = _define_black_color;
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(weakSelf.iconImageView.mas_centerY);
            make.left.mas_equalTo(40);
            make.right.mas_equalTo(-17);
        }];
    }
    return self;
}

-(void)updateCellInfo:(YYTableViewCellInfoModel *)info{
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    YYTableViewCellInfoModel *infoModel = info;
    _titleLabel.text = infoModel.title;
    if(![NSString isNilOrEmpty:infoModel.tipStr]){
        _iconImageView.image = [UIImage imageNamed:infoModel.tipStr];
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(62);
        }];
        [super updateConstraints];
    }else{
        _iconImageView.image = nil;
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(35);
        }];
        [super updateConstraints];
    }
}

@end
