//
//  YYVisibleUploadImageView.h
//  YunejianBuyer
//
//  Created by chuanjun sun on 2017/10/27.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

//哪一个按钮点击. 一共有两个按钮点击上传，上下各一个
typedef NS_ENUM(NSInteger,  whoPhoto) {
    /** 店铺营业执照 */
    shop,
    /** 法人身份证正面照 */
    man,
};

@class YYVisibleUploadImageView;
@protocol YYVisibleUploadImageViewDelegate<NSObject>
@optional

- (void)YYVisibleUploadImageView:(YYVisibleUploadImageView *)view photo:(whoPhoto)photo;


@end

@interface YYVisibleUploadImageView : UIView

/** 店铺营业执照 */
@property (nonatomic, strong) NSData *shopPhoto;
/** 法人身份证照片 */
@property (nonatomic, strong) NSData *manPhoto;


/** 代理 */
@property (nonatomic, weak) id<YYVisibleUploadImageViewDelegate> delegate;

@end
