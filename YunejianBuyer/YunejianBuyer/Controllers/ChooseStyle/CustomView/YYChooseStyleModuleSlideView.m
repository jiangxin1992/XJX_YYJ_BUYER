//
//  YYChooseStyleModuleSlideView.m
//  YunejianBuyer
//
//  Created by yyj on 2017/7/10.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYChooseStyleModuleSlideView.h"

#import "regular.h"
#import "SCGIFImageView.h"

#define YY_SLIDE_MARGIN 12.0f
#define YY_SLIDE_INTERVAL 8.0f
#define YY_SLIDE_ITEM_WIDTH ((kIPhone6Plus?324.0f:285.0f) - 2*YY_SLIDE_INTERVAL - 2*YY_SLIDE_MARGIN)/3.0f
#define YY_SLIDE_ITEM_HEIGHT 33.0f

@interface YYChooseStyleModuleSlideView()

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) NSMutableArray *btnArr;
@property (nonatomic,strong) NSArray *dataArr;

@end

@implementation YYChooseStyleModuleSlideView

-(instancetype)initWithConClass:(YYConClass *)conClass WithReqModel:(YYChooseStyleReqModel *)reqModel WithChooseStyleModuleSlideViewType:(YYChooseStyleModuleSlideViewType )chooseStyleModuleSlideViewType HaveDownLine:(BOOL )haveDownLine{
    self = [super init];
    if(self){
        _conClass = conClass;
        _reqModel = reqModel;
        _chooseStyleModuleSlideViewType = chooseStyleModuleSlideViewType;
        _haveDownLine = haveDownLine;
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
    _dataArr = [self getDataArr];
}
-(void)PrepareUI{}
#pragma mark - UIConfig
-(void)UIConfig{
    _titleLabel = [UILabel getLabelWithAlignment:0 WithTitle:[self getTitleStr] WithFont:12.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [self addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.top.mas_equalTo(15);
    }];
    
    UIView *lastView = nil;
    for (int i = 0; i<_dataArr.count; i++) {
        NSDictionary *tempDict = [_dataArr objectAtIndex:i];
        UIButton *classBtn = [UIButton getCustomTitleBtnWithAlignment:0 WithFont:13.0f WithSpacing:0 WithNormalTitle:[tempDict objectForKey:@"des"] WithNormalColor:_define_black_color WithSelectedTitle:[tempDict objectForKey:@"des"] WithSelectedColor:[UIColor colorWithHex:@"ED6498"]];
        [self addSubview:classBtn];
        classBtn.layer.masksToBounds = YES;
        classBtn.layer.cornerRadius = 3.0f;
        classBtn.layer.borderColor = [[UIColor colorWithHex:@"d3d3d3"] CGColor];
        classBtn.layer.borderWidth = 1;
        [classBtn addTarget:self action:@selector(classAction:) forControlEvents:UIControlEventTouchUpInside];
        classBtn.tag = 100 + i;
        [classBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            if(i % 3 == 0){
                make.left.mas_equalTo(YY_SLIDE_MARGIN);
                if(i == 0){
                    make.top.mas_equalTo(_titleLabel.mas_bottom).with.offset(10);
                }else{
                    make.top.mas_equalTo(lastView.mas_bottom).with.offset(12);
                }
            }else{
                make.left.mas_equalTo(lastView.mas_right).with.offset(YY_SLIDE_INTERVAL);
                make.top.mas_equalTo(lastView);
            }
            make.width.mas_equalTo(YY_SLIDE_ITEM_WIDTH);
            make.height.mas_equalTo(YY_SLIDE_ITEM_HEIGHT);
        }];
        

        [_btnArr addObject:classBtn];
        lastView = classBtn;
    }
    
    UIView *downline = [UIView getCustomViewWithColor:_haveDownLine?[UIColor colorWithHex:@"EFEFEF"]:_define_white_color];
    [self addSubview:downline];
    [downline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.right.mas_equalTo(-8);
        make.height.mas_equalTo(1);
        if(lastView){
            make.top.mas_equalTo(lastView.mas_bottom).with.offset(12);
        }else{
            make.top.mas_equalTo(_titleLabel.mas_bottom).with.offset(12);
        }
        make.bottom.mas_equalTo(0);
    }];
    
}
#pragma mark - SomeAction
-(void)clearSliderSelect{
    if(self){
        for (UIButton *button in _btnArr) {
            button.selected = NO;
            button.layer.borderColor = [[UIColor colorWithHex:@"d3d3d3"] CGColor];
        }
    }
}
-(void)classAction:(UIButton *)btn{
    
    if(btn.selected){
        //如果点击已选  全部清空
        for (UIButton *button in _btnArr) {
            button.selected = NO;
            button.layer.borderColor = [[UIColor colorWithHex:@"d3d3d3"] CGColor];
        }
    }else{
        //如果点击未选  选中 清空其他的
        for (UIButton *button in _btnArr) {
            button.selected = NO;
            button.layer.borderColor = [[UIColor colorWithHex:@"d3d3d3"] CGColor];
        }
        
        btn.selected = YES;
        btn.layer.borderColor = [[UIColor colorWithHex:@"ED6498"] CGColor];
    }
    [self updateReqModel];
    if(_chooseStyleModuleSlideBlock){
        _chooseStyleModuleSlideBlock(@"click_done");
    }
}
-(void)updateReqModel{
    BOOL haveSelect = NO;
    NSInteger selectIndex = 0;
    
    for (int i=0; i<_btnArr.count; i++) {
        UIButton *button = _btnArr[i];
        if(button.selected){
            selectIndex = i;
            haveSelect = YES;
            break;
        }
    }
    
    if(_chooseStyleModuleSlideViewType == YYChooseStyleModuleSlideViewTypeRecommendation){
        if(!haveSelect){
            _reqModel.recommendationType = @(-1);
        }else{
            NSDictionary *tempDict = _dataArr[selectIndex];
            _reqModel.recommendationType = [tempDict objectForKey:@"recommendationType"];
        }
    }else if(_chooseStyleModuleSlideViewType == YYChooseStyleModuleSlideViewTypePeople){
        if(!haveSelect){
            _reqModel.peopleIds = @"";
        }else{
            NSDictionary *tempDict = _dataArr[selectIndex];
            _reqModel.peopleIds = [tempDict objectForKey:@"peopleIds"];
        }
    }else if(_chooseStyleModuleSlideViewType == YYChooseStyleModuleSlideViewTypeSuit){
        if(!haveSelect){
            _reqModel.suitIds = @"";
        }else{
            NSDictionary *tempDict = _dataArr[selectIndex];
            _reqModel.suitIds = [tempDict objectForKey:@"suitIds"];
        }
    }else if(_chooseStyleModuleSlideViewType == YYChooseStyleModuleSlideViewTypeSeason){
        if(!haveSelect){
            _reqModel.relation = @"";
            _reqModel.seasonCat = @"";
            _reqModel.year = @(0);
        }else{
            NSDictionary *tempDict = _dataArr[selectIndex];
            _reqModel.relation = [tempDict objectForKey:@"relation"];
            _reqModel.seasonCat = [tempDict objectForKey:@"seasonCat"];
            _reqModel.year = [tempDict objectForKey:@"year"];
        }
    }else if(_chooseStyleModuleSlideViewType == YYChooseStyleModuleSlideViewTypeCurType){
        if(!haveSelect){
            _reqModel.curType = @(-1);
        }else{
            NSDictionary *tempDict = _dataArr[selectIndex];
            _reqModel.curType = [tempDict objectForKey:@"curType"];
        }
    }
    NSLog(@"111");
}
-(NSString *)getTitleStr{
    if(_chooseStyleModuleSlideViewType == YYChooseStyleModuleSlideViewTypeRecommendation){
        return NSLocalizedString(@"选款",nil);
    }else if(_chooseStyleModuleSlideViewType == YYChooseStyleModuleSlideViewTypePeople){
        return NSLocalizedString(@"人群",nil);
    }else if(_chooseStyleModuleSlideViewType == YYChooseStyleModuleSlideViewTypeSuit){
        return NSLocalizedString(@"品类",nil);
    }else if(_chooseStyleModuleSlideViewType == YYChooseStyleModuleSlideViewTypeSeason){
        return NSLocalizedString(@"季",nil);
    }else if(_chooseStyleModuleSlideViewType == YYChooseStyleModuleSlideViewTypeCurType){
        return NSLocalizedString(@"批发价范围",nil);
    }
    return @"";
}
-(NSArray *)getDataArr{
    if(_chooseStyleModuleSlideViewType == YYChooseStyleModuleSlideViewTypeRecommendation){
        return @[@{@"des":NSLocalizedString(@"可订款",nil),@"recommendationType":@(2)}
                 ,@{@"des":NSLocalizedString(@"鉴赏款",nil),@"recommendationType":@(3)}];
    }else if(_chooseStyleModuleSlideViewType == YYChooseStyleModuleSlideViewTypePeople){
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        if(_conClass){
            for (int i=0; i<_conClass.peopleTypes.count; i++) {
                YYConPeopleClass *peopleClass = _conClass.peopleTypes[i];
                NSDictionary *tempDict = @{@"des":peopleClass.name
                                           ,@"peopleIds":[peopleClass.peopleIds componentsJoinedByString:@","]
                                           };
                [tempArr addObject:tempDict];
            }
        }
        return [tempArr copy];
    }else if(_chooseStyleModuleSlideViewType == YYChooseStyleModuleSlideViewTypeSuit){
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        if(_conClass){
            for (int i=0; i<_conClass.suitTypes.count; i++) {
                YYConSuitClass *suitClass = _conClass.suitTypes[i];
                NSDictionary *tempDict = @{@"des":suitClass.name
                                           ,@"suitIds":[suitClass.suitIds componentsJoinedByString:@","]
                                           };
                [tempArr addObject:tempDict];
            }
        }
        return [tempArr copy];
    }else if(_chooseStyleModuleSlideViewType == YYChooseStyleModuleSlideViewTypeSeason){
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        if(_conClass){
            for (int i=0; i<_conClass.seasons.count; i++) {
                YYConSeasonsClass *seasonsClass = _conClass.seasons[i];
                NSString *tempName = [seasonsClass getShowName];
                NSDictionary *tempDict = @{@"des":tempName
                                           ,@"relation":[NSString isNilOrEmpty:seasonsClass.relation]?@"":seasonsClass.relation
                                           ,@"seasonCat":[NSString isNilOrEmpty:seasonsClass.seasonCat]?@"":seasonsClass.seasonCat
                                           ,@"year":seasonsClass.year?seasonsClass.year:@(0)
                                           };
                [tempArr addObject:tempDict];
            }
        }
        return [tempArr copy];
    }else if(_chooseStyleModuleSlideViewType == YYChooseStyleModuleSlideViewTypeCurType){
        
        return @[@{@"des":NSLocalizedString(@"人民币",nil),@"curType":@(0)}
                 ,@{@"des":NSLocalizedString(@"欧元",nil),@"curType":@(1)}
                 ,@{@"des":NSLocalizedString(@"英镑",nil),@"curType":@(2)}
                 ,@{@"des":NSLocalizedString(@"美元",nil),@"curType":@(3)}];
    }
    return @[];
}

@end
