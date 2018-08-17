//
//  YYOrderAppendViewController.m
//  Yunejian
//
//  Created by Apple on 16/8/8.
//  Copyright © 2016年 yyj. All rights reserved.
//

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYOrderAppendViewController.h"

// 自定义视图
#import "YYNavView.h"
#import "YYOrderAppendStyleInfoCell.h"

// 接口
#import "YYOrderApi.h"

// 分类
#import "UIView+UpdateAutoLayoutConstraints.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYOrderSimpleStyleList.h"

@interface YYOrderAppendViewController ()<UITableViewDataSource,UITableViewDelegate,YYTableCellDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *styleTotalLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableVIew;
@property (weak, nonatomic) IBOutlet UIButton *allSelectBtn;
@property (nonatomic, strong) YYNavView *navView;
@property (strong, nonatomic) NSArray *styleList;
@property (strong, nonatomic) NSMutableArray *selectCellSections;
@end

@implementation YYOrderAppendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navView = [[YYNavView alloc] initWithTitle:NSLocalizedString(@"选择追单款式",nil) WithSuperView:self.view haveStatusView:YES];
    WeakSelf(ws);
    self.navView.goBackBlock = ^{
        [ws goBack];
    };
    
    _tableVIew.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableVIew.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _selectCellSections = [[NSMutableArray alloc] init];
    [self updateAllSelectBtnView];
    [self loadOrderStyleList];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageOrderAppend];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageOrderAppend];
}

- (void)goBack {
    if(self.cancelButtonClicked){
        self.cancelButtonClicked();
    }
}

- (IBAction)closeBtnHandler:(id)sender {
    if(self.cancelButtonClicked){
        self.cancelButtonClicked();
    }
}

- (IBAction)makeSureBtnHandler:(id)sender {
    if(self.modifySuccess && [_selectCellSections count] > 0){
        NSMutableArray * styleIds = [[NSMutableArray alloc] initWithCapacity:[_selectCellSections count]];
        for (id sectionKey in _selectCellSections) {
            YYOpusStyleModel * styleModel = [self.styleList objectAtIndex:[sectionKey integerValue]];
            [styleIds addObject:styleModel.id];
        }

        self.modifySuccess(styleIds);
    }
}

- (IBAction)allSelectBtnHandler:(id)sender {
    if([_styleList count] > 0 && [_selectCellSections count] == [_styleList count]){
        [_selectCellSections removeAllObjects];
    }else{
        [_selectCellSections removeAllObjects];
        NSInteger total = [_styleList count];
        for (NSInteger i=0; i<total; i++) {
            [_selectCellSections addObject:@(i)];
        }
    }
    [self.tableVIew reloadData];
    [self updateAllSelectBtnView];
}

-(void)updateAllSelectBtnView{
    if([_styleList count] > 0 && [_selectCellSections count] == [_styleList count]){
        [_allSelectBtn setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateNormal];
        [_allSelectBtn setTitle:NSLocalizedString(@"取消全选",nil) forState:UIControlStateNormal];
        [_allSelectBtn setConstraintConstant:80 forAttribute:NSLayoutAttributeWidth];
    }else{
        [_allSelectBtn setImage:[UIImage imageNamed:@"noChecked"] forState:UIControlStateNormal];
        [_allSelectBtn setTitle:NSLocalizedString(@"全选",nil) forState:UIControlStateNormal];
        [_allSelectBtn setConstraintConstant:54 forAttribute:NSLayoutAttributeWidth];

    }
    _styleTotalLabel.text = [NSString stringWithFormat:NSLocalizedString(@"已选 %lu 款",nil),(unsigned long)[_selectCellSections count]];
}

-(void)loadOrderStyleList{
    WeakSelf(ws);
    [YYOrderApi getOrderSimpleStyleList:_ordreCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderSimpleStyleList *styleList, NSError *error) {
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            ws.styleList = styleList.result;
            [ws.tableVIew reloadData];
        }else{
            [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    
    return [self.styleList  count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{    
    //UITableViewCell *cell = [[UITableViewCell alloc] init];
    static NSString* reuseIdentifier = @"YYOrderAppendStyleInfoCell";
    YYOrderAppendStyleInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    YYOpusStyleModel * styleModel = [self.styleList objectAtIndex:indexPath.section];
    cell.indexPath = indexPath;
    cell.styleModel = styleModel;
    cell.selectCellSections = [_selectCellSections copy];
    cell.delegate = self;
    [cell updateUI];
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 98;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 5;
//}
//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    UIView *footer = [[UIView alloc] init];
//    footer.backgroundColor = [UIColor whiteColor];
//    return footer;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}
#pragma YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    if([_selectCellSections containsObject:@(section)]){
        [_selectCellSections removeObject:@(section)];
    }else{
        [_selectCellSections addObject:@(section)];
    }
    [self.tableVIew reloadData];
    [self updateAllSelectBtnView];

}
@end
