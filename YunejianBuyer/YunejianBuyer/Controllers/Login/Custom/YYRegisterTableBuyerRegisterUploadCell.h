//
//  YYRegisterTableBuyerRegisterUploadCell.h
//  YunejianBuyer
//
//  Created by Victor on 2017/12/25.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYTableViewCellInfoModel.h"

typedef NS_ENUM(NSUInteger, UploadImageType) {
    UploadImageType0 = 1000,
    UploadImageType1 = 1001,
    UploadImageType2 = 1002,
    UploadImageType3 = 1003
};

@interface YYRegisterTableBuyerRegisterUploadCell : UITableViewCell

@property(nonatomic,weak)id<YYRegisterTableCellDelegate> delegate;
@property(nonatomic,copy)NSIndexPath * indexPath;
@property(nonatomic,assign)NSInteger photoType;
@property (nonatomic, strong)UIImage *uploadImage;

-(void)updateCellInfo:(YYTableViewCellInfoModel *)info;

@end
