//
//  YYChooseStyleListView.m
//  YunejianBuyer
//
//  Created by yyj on 2017/7/9.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYChooseStyleListView.h"

#import "regular.h"
#import "SCGIFImageView.h"

@interface YYChooseStyleListView()

@property (nonatomic,strong) NSMutableArray *btnArr;
@property (nonatomic,strong) NSMutableArray *imageArr;
@property (nonatomic,strong) NSArray *dataArr;

@end

@implementation YYChooseStyleListView
#pragma mark - INIT
- (instancetype)initWithFrame:(CGRect)frame WithChooseStyleListType:(YYChooseStyleButtonStyle )chooseStyleButtonStyle WithChooseStyleReqModel:(YYChooseStyleReqModel *)reqModel
{
    self = [super initWithFrame:frame];
    if (self) {
        _chooseStyleButtonStyle = chooseStyleButtonStyle;
        _reqModel = reqModel;
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

-(void)PrepareData{
    _btnArr = [[NSMutableArray alloc] init];
    _imageArr = [[NSMutableArray alloc] init];
    if(_chooseStyleButtonStyle == YYChooseStyleButtonStyleRecommendation){
        _dataArr = [_reqModel getRecommendationDESArrIsTitle:NO];
    }else if(_chooseStyleButtonStyle == YYChooseStyleButtonStyleSort){
        _dataArr = [_reqModel getSortDESArr];
    }
}
-(void)PrepareUI{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disappearAction)]];
}
#pragma mark - UIConfig
-(void)UIConfig{
    
    UIView *backView = [UIView getCustomViewWithColor:_define_white_color];
    [self addSubview:backView];
    [backView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(NULLAction)]];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
    }];
    
    NSInteger selectIndex = [self getIndex];
    UIView *lastView = nil;
    for (int i=0; i<_dataArr.count; i++) {
        NSString *titleStr = [[_dataArr objectAtIndex:i] objectForKey:@"des"];
        UIButton *btn = [UIButton getCustomTitleBtnWithAlignment:1 WithFont:14.0f WithSpacing:0 WithNormalTitle:titleStr WithNormalColor:[UIColor colorWithHex:@"919191"] WithSelectedTitle:titleStr WithSelectedColor:[UIColor colorWithHex:@"ED6498"]];
        [backView addSubview:btn];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 17, 0, 0)];
        [btn setBackgroundImage:[self createImageWithColor:[UIColor colorWithHex:@"f8f8f8"]] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(chooseStyle:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 100 + i;
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            if(!lastView){
                make.top.mas_equalTo(0);
            }else{
                make.top.mas_equalTo(lastView.mas_bottom).with.offset(0);
            }
            make.height.mas_equalTo(44);
        }];
        
        UIImageView *icon = [UIImageView getImgWithImageStr:@"chooseStyle_Select"];
        [btn addSubview:icon];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(btn);
            make.right.mas_equalTo(-17);
            make.width.mas_equalTo(15);
            make.height.mas_equalTo(10);
        }];
        
        if(selectIndex == i){
            btn.selected = YES;
            icon.hidden = NO;
        }else{
            icon.hidden = YES;
        }
        
        [_btnArr addObject:btn];
        [_imageArr addObject:icon];
        
        
        UIView *downLine = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EFEFEF"]];
        [backView addSubview:downLine];
        [downLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(13);
            make.right.mas_equalTo(-13);
            make.height.mas_equalTo(1);
            make.top.mas_equalTo(btn.mas_bottom).with.offset(0);
            if(_dataArr.count-1 == i){
                make.bottom.mas_equalTo(0);
            }
        }];
        
        lastView = downLine;
    }
}

#pragma mark - SomeAction
-(void)closeAtion{
    if(_chooseStyleListBlock){
        _chooseStyleListBlock(@"close");
    }
}
-(void)chooseStyle:(UIButton *)btn{
    for (int i=0; i<_btnArr.count; i++) {
        UIButton *btn = _btnArr[i];
        UIImageView *imageView = _imageArr[i];
        btn.selected = NO;
        imageView.hidden = YES;
    }
    
    NSInteger index = btn.tag - 100;
    
    btn.selected = YES;
    ((UIImageView *)_imageArr[index]).hidden = NO;
    if(_dataArr.count > index){
        NSDictionary *dataDict = [_dataArr objectAtIndex:index];
        if(_chooseStyleButtonStyle == YYChooseStyleButtonStyleRecommendation){
            _reqModel.recommendation = [dataDict objectForKey:@"recommendation"];
        }else if(_chooseStyleButtonStyle == YYChooseStyleButtonStyleSort){
            _reqModel.sortField = [dataDict objectForKey:@"sortField"];
            _reqModel.sortType = [dataDict objectForKey:@"sortType"];
        }
    }
    
    if(_chooseStyleListBlock){
        _chooseStyleListBlock(@"choose_done");
    }
}
-(NSInteger)getIndex{
    
    for (int i = 0; i < _dataArr.count; i++) {
        NSDictionary *dict = _dataArr[i];
        if(_chooseStyleButtonStyle == YYChooseStyleButtonStyleRecommendation){
            if([_reqModel.recommendation integerValue] == [[dict objectForKey:@"recommendation"] integerValue]){
                return i;
            }
        }else if(_chooseStyleButtonStyle == YYChooseStyleButtonStyleSort){
            if([_reqModel.sortField isEqualToString:[dict objectForKey:@"sortField"]] && [_reqModel.sortType isEqualToString:[dict objectForKey:@"sortType"]]){
                return i;
            }
        }
    }
    return -1;
}
-(void)NULLAction{}
-(void)disappearAction{
    if(_chooseStyleListBlock){
        _chooseStyleListBlock(@"disappear");
    }
}
/**
 * 将UIColor变换为UIImage
 *
 **/
- (UIImage *)createImageWithColor:(UIColor *)color
{
    //设置长宽
    CGRect rect = CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, 44.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}
@end
