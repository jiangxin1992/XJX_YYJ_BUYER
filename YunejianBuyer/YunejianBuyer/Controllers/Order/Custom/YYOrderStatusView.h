//
//  YYOrderStatusView.h
//  Yunejian
//
//  Created by Apple on 15/11/25.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYOrderStatusView : UIView{

}
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView *progressDotBgView;
@property (weak, nonatomic) IBOutlet UIView *progressDotView;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dotLayoutCenterXConstaint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timerLabelLayoutCenterXConstaint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dotBgLayoutCenterXConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressLayoutLeftConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel1;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel2;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel3;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel4;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel5;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel6;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (assign, nonatomic) NSInteger showIndex;
@property (assign, nonatomic) NSInteger showNum;
@property (strong, nonatomic) NSArray *titleArray;
@property (assign, nonatomic) NSInteger curProgressValue;
@property (strong, nonatomic) NSString *progressTintColor;
@property (assign, nonatomic) NSInteger containerViewWidth;

-(void)updateUI;
-(NSInteger)getClipX:(NSInteger)value;
-(void)setProgressValue:(float) value;
@end
