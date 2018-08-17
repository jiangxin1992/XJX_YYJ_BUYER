//
//  YYOrderAddressListCell.m
//  Yunejian
//
//  Created by Apple on 15/10/26.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYOrderAddressListCell.h"

#import "UIImage+YYImage.h"

@implementation YYOrderAddressListCell
-(void)updateUI{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    if((_curModel.contactEmail == nil && _infoModel.contactEmail == nil) || ([_curModel.contactEmail isEqualToString:_infoModel.contactEmail] )){
        self.nameLabel.font = [UIFont boldSystemFontOfSize:15];
        self.emailLabel.font = [UIFont boldSystemFontOfSize:15];
        self.cityLabel.font = [UIFont boldSystemFontOfSize:15];
        self.backgroundColor = [UIColor colorWithHex:kDefaultImageColor];

    }else{
        self.nameLabel.font = [UIFont systemFontOfSize:15];
        self.emailLabel.font = [UIFont systemFontOfSize:15];
        self.cityLabel.font = [UIFont systemFontOfSize:15];
        self.backgroundColor = [UIColor whiteColor];

    }
    
    self.nameLabel.text = self.infoModel.contactName;
    if(self.infoModel.contactEmail){
    self.emailLabel.text = self.infoModel.contactEmail;
//    [self downloadLogoImageWithRelativePath:self.infoModel.logoPath andImageView:self.logoView];
        sd_downloadWebImageWithRelativePath(NO, self.infoModel.logoPath, self.logoView, kStyleColorImageCover, 0);
    if([self.infoModel.province isEqualToString:@""] && [self.infoModel.city isEqualToString:@""]){
        self.cityLabel.text = NSLocalizedString(@"缺少",nil);
    }else{
        NSString *_nation = [LanguageManager isEnglishLanguage]?self.infoModel.nationEn:self.infoModel.nation;
        NSString *_province = [LanguageManager isEnglishLanguage]?self.infoModel.provinceEn:self.infoModel.province;
        NSString *_city = [LanguageManager isEnglishLanguage]?self.infoModel.cityEn:self.infoModel.city;
        NSArray *tempArr = @[_nation,_province,_city];
        self.cityLabel.text = [tempArr componentsJoinedByString:@","];
    }
    }else{
        UIImage *defaultImage = [UIImage imageNamed:@"buyer_icon"];//[UIImage imageWithColor:[UIColor colorWithHex:kDefaultImageColor] size:self.logoView.frame.size];
        self.logoView.image = defaultImage;
        self.emailLabel.text = NSLocalizedString(@"未入驻",nil);
        self.cityLabel.text = @"";
    }
}

//- (void)downloadLogoImageWithRelativePath:(NSString *)imageRelativePath andImageView:(SCGIFImageView *)imageView{
//    sd_downloadWebImageWithRelativePath(NO, imageRelativePath, imageView, kStyleColorImageCover, 0);
//}
@end
