//
//  YYConSuitChooseView.m
//  YunejianBuyer
//
//  Created by yyj on 2017/4/13.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYConSuitChooseView.h"

#import "YYConClass.h"
#import "YYConSuitClass.h"
#import "YYBrandAddHeadBtn.h"

@interface YYConSuitChooseView()

@property (nonatomic,strong) NSMutableArray *ArrSuit;
@property (nonatomic,strong) UIView *backview;
@end

@implementation YYConSuitChooseView

-(instancetype)init{
    self = [super init];
    if(self){
        _ArrSuit = [[NSMutableArray alloc] init];
        
        self.backgroundColor = [_define_black_color colorWithAlphaComponent:0.2];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideAction)]];
        
        [_backview removeFromSuperview];
        _backview = [UIView getCustomViewWithColor:_define_white_color];
        [self addSubview:_backview];
        _backview.userInteractionEnabled = YES;
        [_backview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(NULLACTION)]];
        [_backview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(0);
            make.height.mas_equalTo(0);
        }];
        
    }
    return self;
}
-(void)setConnClass:(YYConClass *)connClass{
    _connClass = connClass;
    if(_ArrSuit){
        for (int i=0; i<_ArrSuit.count; i++) {
            UIView *obj = _ArrSuit[i];
            [obj removeFromSuperview];
        }
        [_ArrSuit removeAllObjects];
    }
    
    if(_connClass.suitTypes.count){
        
        NSMutableArray *imageNormalArr = [[NSMutableArray alloc] init];
        NSMutableArray *imageSelectArr = [[NSMutableArray alloc] init];
        
        for (int i=0; i<_connClass.suitTypes.count; i++) {
            YYConSuitClass *suitClass = _connClass.suitTypes[i];
            NSInteger num = [suitClass.id integerValue];
            if(num>0){
                NSString *normalStr = num==1?@"conn_clothing_normal":num==2?@"conn_shoes_normal":num==3?@"conn_bag_normal":num==4?@"conn_jewelry_normal":num==5?@"conn_other_normal":@"conn_other_normal";
                
                NSString *SelectStr = num==1?@"conn_clothing_select":num==2?@"conn_shoes_select":num==3?@"conn_bag_select":num==4?@"conn_jewelry_select":num==5?@"conn_other_select":@"conn_other_select";
                
                [imageNormalArr addObject:normalStr];
                [imageSelectArr addObject:SelectStr];
            }else{
                [imageNormalArr addObject:@"conn_all_normal"];
                [imageSelectArr addObject:@"conn_all_select"];
            }
        }
        
        
        NSInteger lineNum=_connClass.suitTypes.count/3;
        CGFloat getHight = lineNum*70+70+(lineNum-1)*35;
        [_backview mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(getHight);
        }];
        
        CGFloat edge = 16.0f;
        CGFloat Spacing = (SCREEN_WIDTH-80*3-edge*2)/2.0f;
        UIView *lastview = nil;
        for (int i=0; i<_connClass.suitTypes.count; i++) {
            YYConSuitClass *suitClass = _connClass.suitTypes[i];
            UIButton *btn = [UIButton getCustomTitleBtnWithAlignment:0 WithFont:[LanguageManager isEnglishLanguage]?14.0f:14.0f WithSpacing:0 WithNormalTitle:suitClass.name WithNormalColor:[UIColor colorWithHex:@"919191"] WithSelectedTitle:suitClass.name WithSelectedColor:[UIColor colorWithHex:@"ED6498"]];
            [_backview addSubview:btn];
//            btn.backgroundColor = [UIColor redColor];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                if(i%3==0){
                    make.left.mas_equalTo(edge);
                    if(i==0){
                        make.top.mas_equalTo(35);
                    }else{
                        make.top.mas_equalTo(lastview.mas_bottom).with.offset(35);
                    }
                }else{
                    make.left.mas_equalTo(lastview.mas_right).with.offset(Spacing);
                    make.top.mas_equalTo(lastview);
                }
                make.width.mas_equalTo(80);
                make.height.mas_equalTo(70);
                if(i==_connClass.suitTypes.count-1){
                    make.bottom.mas_equalTo(_backview.mas_bottom).with.offset(-35);
                }
            }];
//            UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)

            [btn setImageEdgeInsets:UIEdgeInsetsMake(-26, 16, 0, 0)];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -40, -40, 0)];
            btn.tag = 100+i;
            [btn addTarget:self action:@selector(chooseSuitAction:) forControlEvents:UIControlEventTouchUpInside];
            if(_suitSelectIndex==i){
                btn.selected=YES;
            }else{
                btn.selected=NO;
            }
            [btn setImage:[UIImage imageNamed:imageNormalArr[i]] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:imageSelectArr[i]] forState:UIControlStateSelected];
            
            [_ArrSuit addObject:btn];
            lastview = btn;
        }
    }
}
-(void)NULLACTION{}
-(void)hideAction{
    if(!self.hidden){
        if(_blockHide){
            _blockHide();
        }
    }
}
-(void)chooseSuitAction:(UIButton *)btn{
    NSInteger index = btn.tag-100;
    if(_blockSuit){
        _blockSuit(index);
    }
}
@end
