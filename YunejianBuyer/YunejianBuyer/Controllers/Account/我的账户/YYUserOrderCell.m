//
//  YYUserOrderCell.m
//  YunejianBuyer
//
//  Created by yyj on 2017/8/15.
//  Copyright © 2017年 Apple. All rights reserved.
//

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "YYUserOrderCell.h"

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYUser.h"
#import "YYUntreatedMsgAmountModel.h"
#import "AppDelegate.h"

@interface YYUserOrderCell()

@property (nonatomic,copy) void (^userOrderBlock)(kOrderCode type);
@property (nonatomic,strong) NSMutableArray *numLabelArr;
@property (nonatomic, strong) NSArray *orderCodes;

@end

@implementation YYUserOrderCell

#pragma mark - --------------生命周期--------------
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithActionBlock:(void(^)(NSInteger pageIndex))block{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.userOrderBlock = block;
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
    self.numLabelArr = [[NSMutableArray alloc] init];
    self.orderCodes = @[@(YYOrderCode_NEGOTIATION), @(YYOrderCode_CONTRACT_DONE), @(YYOrderCode_MANUFACTURE), @(YYOrderCode_DELIVERING), @(YYOrderCode_DELIVERY), @(YYOrderCode_RECEIVED)];
}
- (void)PrepareUI{}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    [self CreateView];
}
-(void)CreateView{

    NSArray *imgArr = [self orderTypeImageForOrderCodes:self.orderCodes];
    NSArray *titleArr = [self orderTypeNamesForOrderCodes:self.orderCodes];
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
        button.tag = [self.orderCodes[i] integerValue];

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

        [self.numLabelArr addObject:numLabel];

        lastView = button;
    }
    NSLog(@"111");

}
#pragma mark - --------------请求数据----------------------
-(void)RequestData{}

#pragma mark - --------------自定义响应----------------------
-(void)orderAction:(UIButton *)sender{
    if(self.userOrderBlock){
        self.userOrderBlock([self orderPageIndexForOrderCode:sender.tag]);
    }
}

#pragma mark - --------------自定义方法----------------------
-(void)updateUI{
    NSArray *numArr = [self unreadMsgCountsForOrderCodes:self.orderCodes];
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

#pragma mark - 订单类型配置
- (NSArray *)orderTypeNamesForOrderCodes:(NSArray *)orderCodes {
    NSMutableArray *array = [NSMutableArray array];
    for (NSNumber *orderCode in orderCodes) {
        switch ([orderCode integerValue]) {
            case YYOrderCode_NEGOTIATION:
                [array addObject:NSLocalizedString(@"已下单", nil)];
                break;
            case YYOrderCode_CONTRACT_DONE:
                [array addObject:NSLocalizedString(@"已确认", nil)];
                break;
            case YYOrderCode_MANUFACTURE:
                [array addObject:NSLocalizedString(@"已生产", nil)];
                break;
            case YYOrderCode_DELIVERING:
                [array addObject:NSLocalizedString(@"发货中", nil)];
                break;
            case YYOrderCode_DELIVERY:
                [array addObject:NSLocalizedString(@"已发货", nil)];
                break;
            case YYOrderCode_RECEIVED:
                [array addObject:NSLocalizedString(@"已收货", nil)];
                break;
            default:
                break;
        }
    }
    return [NSArray arrayWithArray:array];
}

- (NSArray *)orderTypeImageForOrderCodes:(NSArray *)orderCodes {
    NSMutableArray *array = [NSMutableArray array];
    for (NSNumber *orderCode in orderCodes) {
        switch ([orderCode integerValue]) {
            case YYOrderCode_NEGOTIATION:
                [array addObject:@"user_order_ordered"];
                break;
            case YYOrderCode_CONTRACT_DONE:
                [array addObject:@"user_order_confirmed"];
                break;
            case YYOrderCode_MANUFACTURE:
                [array addObject:@"user_order_produced"];
                break;
            case YYOrderCode_DELIVERING:
                [array addObject:@"user_order_delivering"];
                break;
            case YYOrderCode_DELIVERY:
                [array addObject:@"user_order_delivered"];
                break;
            case YYOrderCode_RECEIVED:
                [array addObject:@"user_order_received"];
                break;
            default:
                break;
        }
    }
    return [NSArray arrayWithArray:array];
}

- (NSArray *)unreadMsgCountsForOrderCodes:(NSArray *)orderCodes {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *array = [NSMutableArray array];
    for (NSNumber *orderCode in orderCodes) {
        switch ([orderCode integerValue]) {
            case YYOrderCode_NEGOTIATION:
                [array addObject:@(appDelegate.untreatedMsgAmountModel.unconfirmedOrderedMsgAmount)];
                break;
            case YYOrderCode_CONTRACT_DONE:
                [array addObject:@(appDelegate.untreatedMsgAmountModel.unconfirmedConfirmedMsgAmount)];
                break;
            case YYOrderCode_MANUFACTURE:
                [array addObject:@(appDelegate.untreatedMsgAmountModel.unconfirmedProducedMsgAmount)];
                break;
            case YYOrderCode_DELIVERING:
                [array addObject:@(appDelegate.untreatedMsgAmountModel.unconfirmedDeliveringMsgAmount)];
                break;
            case YYOrderCode_DELIVERY:
                [array addObject:@(appDelegate.untreatedMsgAmountModel.unconfirmedDeliveredMsgAmount)];
                break;
            case YYOrderCode_RECEIVED:
                [array addObject:@(appDelegate.untreatedMsgAmountModel.unconfirmedReceivedMsgAmount)];
                break;
            default:
                break;
        }
    }
    return [NSArray arrayWithArray:array];
}

- (NSInteger)orderPageIndexForOrderCode:(kOrderCode)orderCode {
    switch (orderCode) {
        case YYOrderCode_NEGOTIATION:
            //  已下单
            return 1;
        case YYOrderCode_CONTRACT_DONE:
            //  已确认
            return 2;
        case YYOrderCode_MANUFACTURE:
            //  已生产
            return 3;
        case YYOrderCode_DELIVERING:
            //  发货中
            return 4;
        case YYOrderCode_DELIVERY:
            //  已发货
            return 5;
        case YYOrderCode_RECEIVED:
            //  已收货
            return 6;
        default:
            return 0;
    }
}

@end
