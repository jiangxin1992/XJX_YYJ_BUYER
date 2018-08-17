//
//  YYUserOrderCell.m
//  YunejianBuyer
//
//  Created by yyj on 2017/8/15.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYUserOrderCell.h"

#import "AppDelegate.h"

@interface YYUserOrderCell()

@property (nonatomic,copy) void (^userOrderBlock)(NSString *type);
@property (nonatomic,copy) NSMutableArray *numLabelArr;

@end

@implementation YYUserOrderCell

#pragma mark - --------------生命周期--------------
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type))block{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _userOrderBlock = block;
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
- (void)PrepareData{
    _numLabelArr = [[NSMutableArray alloc] init];
}
- (void)PrepareUI{}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    [self CreateView];
}
-(void)CreateView{

    NSArray *imgArr = @[@"user_order_ordered",@"user_order_confirmed",@"user_order_produced",@"user_order_delivered",@"user_order_received"];
    NSArray *titleArr = @[NSLocalizedString(@"已下单",nil),NSLocalizedString(@"已确认",nil),NSLocalizedString(@"已生产",nil),NSLocalizedString(@"已发货",nil),NSLocalizedString(@"已收货",nil)];
    UIView *lastView = nil;
    for (int i = 0; i < imgArr.count; i++) {

        UIButton *button = [UIButton getCustomBtn];
        [self.contentView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            if(lastView){
                make.left.mas_equalTo(lastView.mas_right).with.offset(0);
                make.width.mas_equalTo(lastView);
            }else{
                make.left.mas_equalTo(0);
            }
            if(i == imgArr.count - 1){
                make.right.mas_equalTo(0);
            }
            make.bottom.mas_equalTo(0);
        }];
        [button addTarget:self action:@selector(orderAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 100 + i;

        UIImageView *btnImg = [UIImageView getImgWithImageStr:imgArr[i]];
        [button addSubview:btnImg];
        [btnImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(button);
            make.width.mas_equalTo(30);
            make.height.mas_equalTo(27);
        }];
        btnImg.userInteractionEnabled = NO;
        btnImg.contentMode = UIViewContentModeScaleToFill;

        UILabel *titleLabel = [UILabel getLabelWithAlignment:1 WithTitle:titleArr[i] WithFont:12.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
        [button addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(btnImg.mas_bottom).with.offset(8);
        }];

        UIButton *numLabel = [UIButton getCustomTitleBtnWithAlignment:0 WithFont:11.0f WithSpacing:0 WithNormalTitle:nil WithNormalColor:_define_white_color WithSelectedTitle:nil WithSelectedColor:nil];
        [button addSubview:numLabel];
        [numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(14);
            make.height.mas_equalTo(14);
            make.left.mas_equalTo(btnImg.mas_right).with.offset(-8);
            make.bottom.mas_equalTo(btnImg.mas_top).with.offset(8);
            make.top.mas_equalTo(0);
        }];
        numLabel.backgroundColor = [UIColor colorWithHex:@"EF4E31"];
        numLabel.layer.masksToBounds = YES;
        numLabel.layer.cornerRadius = 7;
        numLabel.hidden = YES;

        [_numLabelArr addObject:numLabel];

        lastView = button;
    }
    NSLog(@"111");

}
#pragma mark - --------------请求数据----------------------
-(void)RequestData{}

#pragma mark - --------------自定义响应----------------------
-(void)orderAction:(UIButton *)btn{
    if(_userOrderBlock){
        NSInteger index = btn.tag - 100;
        if(index == 0){
            //已下单
            _userOrderBlock(@"order_ordered");
        }else if(index == 1){
            //已确认
            _userOrderBlock(@"order_confirmed");
        }else if(index == 2){
            //已生产
            _userOrderBlock(@"order_produced");
        }else if(index == 3){
            //已收货
            _userOrderBlock(@"order_delivered");
        }else if(index == 4){
            //已收货
            _userOrderBlock(@"order_received");
        }
    }
}

#pragma mark - --------------自定义方法----------------------
-(void)updateUI{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *numArr = @[@(appDelegate.unconfirmedOrderedMsgAmount),@(appDelegate.unconfirmedConfirmedMsgAmount),@(appDelegate.unconfirmedProducedMsgAmount),@(appDelegate.unconfirmedDeliveredMsgAmount),@(appDelegate.unconfirmedReceivedMsgAmount)];
    for (int i = 0; i < _numLabelArr.count; i++) {
        UIButton *tempLabel = _numLabelArr[i];
        NSInteger num = [numArr[i] integerValue];
        if(num > 0){
            tempLabel.hidden = NO;
            [tempLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                if(num > 9){
                    make.width.mas_equalTo(20);
                }else{
                    make.width.mas_equalTo(14);
                }
            }];
            if(num > 99){
                [tempLabel setTitle:@"…" forState:UIControlStateNormal];
                [tempLabel setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 7, 0 )];
            }else{
                [tempLabel setTitle:[[NSString alloc] initWithFormat:@"%ld",num] forState:UIControlStateNormal];
                [tempLabel setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0 )];
            }

        }else{
            tempLabel.hidden = YES;
            [tempLabel setTitle:@"" forState:UIControlStateNormal];
            [tempLabel setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0 )];
        }
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
