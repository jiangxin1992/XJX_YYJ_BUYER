//
//  YYBuyerInfoAboutCell.m
//  YunejianBuyer
//
//  Created by yyj on 2017/1/5.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYBrandInfoAboutCell.h"

//#import <WebKit/WebKit.h>

#import "YYNoDataView.h"

#import "YYBrandHomeInfoModel.h"

@interface YYBrandInfoAboutCell ()
//<WKNavigationDelegate>

@property (nonatomic, strong) UIView *infoAboutBackView;
@property (nonatomic, strong) UILabel *infoAboutTitleLabel;
@property (nonatomic, strong) UILabel *infoAboutLabel;
//@property (nonatomic, strong) WKWebView *infoAboutWebview;

@property (nonatomic, strong) UIView *pancraseBackView;
@property (nonatomic, strong) UILabel *pancraseTitleLabel;
@property (nonatomic, strong) UILabel *pancraseLabel;

@property (nonatomic, strong) UILabel *retailerNameTitleLabel;
@property (nonatomic, strong) UILabel *retailerNameLabel;

@property (nonatomic, strong) UIView *noIntroductionDataView;

@end

@implementation YYBrandInfoAboutCell

#pragma mark - init
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type, CGFloat height))block
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        _cellblock=block;
        [self SomePrepare];
        [self UIConfig];
    }
    return self;
}
-(id)initWithBlock:(void(^)(NSString *type, CGFloat height))block{
    self=[super init];
    if(self)
    {
        _cellblock=block;
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
-(void)PrepareData{}
-(void)PrepareUI
{
    
    _infoAboutBackView = [UIView getCustomViewWithColor:nil];
    _pancraseBackView = [UIView getCustomViewWithColor:nil];
    _retailerNameBackView = [UIView getCustomViewWithColor:nil];
    
    _infoAboutTitleLabel = [UILabel getLabelWithAlignment:0 WithTitle:@"" WithFont:14.0f WithTextColor:_define_black_color WithSpacing:0];
    _pancraseTitleLabel = [UILabel getLabelWithAlignment:0 WithTitle:@"" WithFont:14.0f WithTextColor:_define_black_color WithSpacing:0];
    _retailerNameTitleLabel = [UILabel getLabelWithAlignment:0 WithTitle:@"" WithFont:14.0f WithTextColor:_define_black_color WithSpacing:0];
    
    _infoAboutLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:14.0f WithTextColor:_define_black_color WithSpacing:0];
    _infoAboutLabel.numberOfLines = 0;
    
    _pancraseLabel = [UILabel getLabelWithAlignment:0 WithTitle:@"" WithFont:14.0f WithTextColor:[UIColor colorWithHex:kDefaultBlueColor] WithSpacing:0];
    _pancraseLabel.numberOfLines = 0;
    _pancraseLabel.userInteractionEnabled = YES;
    [_pancraseLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPancrase)]];
    
    _retailerNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:@"" WithFont:14.0f WithTextColor:_define_black_color WithSpacing:0];
    _retailerNameLabel.numberOfLines = 0;
}
#pragma mark - UIConfig
-(void)UIConfig
{
    [self CreateSubView];
    
    [self CreateNoDataView];
}
-(void)CreateSubView
{
    NSArray *viewArr = @[_infoAboutBackView,_pancraseBackView,_retailerNameBackView];
    NSArray *titleArr = @[_infoAboutTitleLabel,_pancraseTitleLabel,_retailerNameTitleLabel];
    __block UIView *lastView = nil;
    [viewArr enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.contentView addSubview:obj];
        [obj mas_makeConstraints:^(MASConstraintMaker *make) {
            if(!lastView)
            {
                make.top.mas_equalTo(0);
            }else
            {
                make.top.mas_equalTo(lastView.mas_bottom);
            }
            make.left.right.mas_equalTo(0);
        }];
        
        UILabel *titleLabel = [titleArr objectAtIndex:idx];
        [obj addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(18);
            make.right.mas_equalTo(-18);
            make.top.mas_equalTo(11);
        }];
        
        //        if(idx==0)
        //        {
        //            _infoAboutWebview=[[WKWebView alloc] init];
        //            [obj addSubview:_infoAboutWebview];
        //            _infoAboutWebview.userInteractionEnabled=NO;
        //            _infoAboutWebview.navigationDelegate = self;
        //            [_infoAboutWebview sizeToFit];
        //            [_infoAboutWebview mas_makeConstraints:^(MASConstraintMaker *make) {
        //                make.left.mas_equalTo(18);
        //                make.right.mas_equalTo(-18);
        //                make.top.mas_equalTo(titleLabel.mas_bottom).with.offset(7);
        //                make.height.mas_equalTo(0);
        //                make.bottom.mas_equalTo(0);
        //            }];
        //        }else
        //        {
        UILabel *contentLabel = idx==0?_infoAboutLabel:idx==1?_pancraseLabel:_retailerNameLabel;
        [obj addSubview:contentLabel];
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(18);
            make.right.mas_equalTo(-18);
            make.top.mas_equalTo(titleLabel.mas_bottom).with.offset(7);
            make.bottom.mas_equalTo(0);
        }];
        //        }
        lastView = obj;
    }];
}
-(void)CreateNoDataView
{
    if(_isHomePage)
    {
        _noIntroductionDataView = (YYNoDataView *)addNoDataView_phone(self.contentView,[NSString stringWithFormat:@"%@|icon:notxt_icon",NSLocalizedString(@"还没有添加品牌信息，点击右上角编辑",nil)],kDefaultBorderColor,@"noinfo_icon");
    }else
    {
        _noIntroductionDataView = (YYNoDataView *)addNoDataView_phone(self.contentView,[NSString stringWithFormat:@"%@|icon:notxt_icon",NSLocalizedString(@"还没有添加品牌信息",nil)],kDefaultBorderColor,@"noinfo_icon");
    }
    [self.contentView addSubview:_noIntroductionDataView];
    [_noIntroductionDataView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.top.mas_equalTo(100);
        
    }];
    _noIntroductionDataView.hidden=YES;
    
}
#pragma mark - Setter
-(void)setHomePageModel:(YYBrandHomeInfoModel *)homePageModel
{
    _homePageModel=homePageModel;
    [self setData];
}

-(void)setData
{
    BOOL _haveData=NO;
    
    if(![NSString isNilOrEmpty:_homePageModel.brandIntroduction])
    {
        _infoAboutTitleLabel.text = NSLocalizedString(@"品牌简介",nil);
        [_infoAboutTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(11);
        }];
        
        NSString *tempStr = [_homePageModel.brandIntroduction stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
        _infoAboutLabel.text = tempStr;
        [_infoAboutLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_infoAboutTitleLabel.mas_bottom).with.offset(7);
        }];
        
        //        NSString *htmlStr = getHTMLStringWithContent_phone(_homePageModel.brandIntroduction, @"12px/20px", @"#000000");
        //        [_infoAboutWebview loadHTMLString:htmlStr baseURL:nil];
        //        [_infoAboutWebview mas_updateConstraints:^(MASConstraintMaker *make) {
        //            make.top.mas_equalTo(_infoAboutTitleLabel.mas_bottom).with.offset(7);
        //        }];
        
        _haveData = YES;
    }else
    {
        _infoAboutTitleLabel.text = @"";
        [_infoAboutTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
        }];
        
        [_infoAboutLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_infoAboutTitleLabel.mas_bottom).with.offset(0);
        }];
        
        //        [_infoAboutWebview mas_updateConstraints:^(MASConstraintMaker *make) {
        //            make.top.mas_equalTo(_infoAboutTitleLabel.mas_bottom).with.offset(0);
        //        }];
    }
    
    
    if(![NSString isNilOrEmpty:_homePageModel.webUrl])
    {
        _pancraseTitleLabel.text = NSLocalizedString(@"网站",nil);
        [_pancraseTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(11);
        }];
        
        _pancraseLabel.text = _homePageModel.webUrl;
        [_pancraseLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_pancraseTitleLabel.mas_bottom).with.offset(7);
        }];
        _haveData=YES;
    }else
    {
        _pancraseTitleLabel.text = @"";
        [_pancraseTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
        }];
        
        _pancraseLabel.text = @"";
        [_pancraseLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_pancraseTitleLabel.mas_bottom).with.offset(0);
        }];
    }
    
    
    if(_homePageModel.retailerName)
    {
        if(_homePageModel.retailerName.count)
        {
            __block BOOL _allNULL = YES;
            [_homePageModel.retailerName enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if(![NSString isNilOrEmpty:obj])
                {
                    _allNULL = NO;
                    *stop = YES;
                }
            }];
            if(_allNULL)
            {
                _retailerNameTitleLabel.text = @"";
                [_retailerNameTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(0);
                }];
                
                _retailerNameLabel.text = @"";
                [_retailerNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(_retailerNameTitleLabel.mas_bottom).with.offset(0);
                }];
            }else
            {
                _retailerNameTitleLabel.text = NSLocalizedString(@"合作过的买手店",nil);
                [_retailerNameTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(11);
                }];
                
                _retailerNameLabel.text = [_homePageModel.retailerName componentsJoinedByString:@"\n"];
                [_retailerNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(_retailerNameTitleLabel.mas_bottom).with.offset(7);
                }];
                _haveData=YES;
            }
        }else
        {
            _retailerNameTitleLabel.text = @"";
            [_retailerNameTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
            }];
            
            _retailerNameLabel.text = @"";
            [_retailerNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(_retailerNameTitleLabel.mas_bottom).with.offset(0);
            }];
        }
    }else
    {
        _retailerNameTitleLabel.text = @"";
        [_retailerNameTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
        }];
        
        _retailerNameLabel.text = @"";
        [_retailerNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_retailerNameTitleLabel.mas_bottom).with.offset(0);
        }];
    }
    
    if(!_haveData)
    {
//        _noIntroductionDataView.hidden = NO;
        _noIntroductionDataView.hidden = YES;
    }else
    {
        _noIntroductionDataView.hidden = YES;
    }
}

#pragma mark - SomeAction
+(CGFloat )getHeightWithHomeInfoModel:(YYBrandHomeInfoModel *)homePageModel
{
    YYBrandInfoAboutCell *aboutCell = [[YYBrandInfoAboutCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"getheight" WithBlock:nil];
    aboutCell.homePageModel = homePageModel;
    [aboutCell layoutIfNeeded];
    
    BOOL _haveData = [self haveData:homePageModel];
    if(_haveData)
    {
        CGRect frame =  aboutCell.retailerNameBackView.frame;
        return frame.origin.y + frame.size.height + 14;
    }else
    {
        return 0;
    }
}
+(BOOL)haveData:(YYBrandHomeInfoModel *)homePageModel
{
    BOOL _haveData=NO;
    
    if(![NSString isNilOrEmpty:homePageModel.brandIntroduction])
    {
        _haveData = YES;
    }
    
    if(![NSString isNilOrEmpty:homePageModel.webUrl])
    {
        _haveData=YES;
    }
    
    if(homePageModel.retailerName)
    {
        if(homePageModel.retailerName.count)
        {
            __block BOOL _allNULL = YES;
            [homePageModel.retailerName enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if(![NSString isNilOrEmpty:obj])
                {
                    _allNULL = NO;
                    *stop = YES;
                }
            }];
            if(!_allNULL)
            {
                _haveData=YES;
            }
        }
    }
    return _haveData;
}
-(void)openPancrase
{
    if(_cellblock){
        _cellblock(@"openPancrase",0);
    }
}
#pragma mark - Other
- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
//#pragma mark - WKNavigationDelegate
//
////加载完成时调用
//- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
//    [webView evaluateJavaScript:@"document.body.offsetHeight" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//        CGFloat height = 0;
//        if(![NSString isNilOrEmpty:_homePageModel.brandIntroduction])
//        {
//            height = floor([result doubleValue])+2;
//        }else
//        {
//            height = 0;
//        }
//        [webView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(height);
//        }];
//        CGFloat _height = CGRectGetMaxY(_retailerNameBackView.frame) + 30;
//        _cellblock(@"height",_height);
//    }];
//}
@end
