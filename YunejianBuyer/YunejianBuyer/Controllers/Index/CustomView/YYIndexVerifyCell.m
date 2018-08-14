//
//  YYIndexVerifyCell.m
//  YunejianBuyer
//
//  Created by yyj on 2017/10/23.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYIndexVerifyCell.h"

#import "YYCompleteInformationView.h"

@interface YYIndexVerifyCell()

@property (nonatomic,copy) void (^block)(NSString *type);

@property (nonatomic,copy) YYCompleteInformationView *completeInformationView;

@end

@implementation YYIndexVerifyCell

#pragma mark - --------------生命周期--------------
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type))block{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _block = block;
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
- (void)PrepareUI{}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    _completeInformationView = [[YYCompleteInformationView alloc] initWithBlock:^(NSString *type) {
        if(_block){
            _block(type);
        }
    }];
    [self.contentView addSubview:_completeInformationView];
    [_completeInformationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(30);
        make.left.right.mas_equalTo(0);
    }];
}
#pragma mark - --------------自定义响应----------------------


#pragma mark - --------------自定义方法----------------------
-(void)updateUI{
    if(_completeInformationView){
        [_completeInformationView updateUI];
    }
}

#pragma mark - --------------other----------------------
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
