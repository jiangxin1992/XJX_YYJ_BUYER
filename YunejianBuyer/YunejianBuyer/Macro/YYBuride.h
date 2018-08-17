//
//  YYBuride.h
//  YunejianBuyer
//
//  Created by chuanjun sun on 2017/8/2.
//  Copyright © 2017年 Apple. All rights reserved.
//

#ifndef YYBuride_h
#define YYBuride_h

#import <UMMobClick/MobClick.h>

#define currentServerUrlRelease(monitor, placeholder) [[[NSUserDefaults standardUserDefaults] objectForKey: kLastYYServerURL] containsString:@"http://ycosystem.com"]? monitor: placeholder

// 产品介绍页（安装后的三张介绍）
#define kYYPageIntroduction currentServerUrlRelease(@"YYIntroduction", @"not-release")
// 登录
#define kYYPageLogin currentServerUrlRelease(@"YYLogin", @"not-release")
// 主界面
#define kYYPageMain currentServerUrlRelease(@"YYMain", @"not-release")

/// ---------- Register start ----------
// 买手店 买手店入驻
#define kYYPageRegisterBuyerStorUser currentServerUrlRelease(@"YYRegister_buyerStorUser", @"not-release")
// 买手店 邮箱注册验证
#define kYYPageRegisterEmailRegister currentServerUrlRelease(@"YYRegister_emailRegister", @"not-release")
// 提交审核
#define kYYPageRegisterBuyerRegister currentServerUrlRelease(@"YYRegister_buyerRegister", @"not-release")
// 密码忘记
#define kYYPageRegisterForgetPassword currentServerUrlRelease(@"YYRegister_forgetPassword", @"not-release")
// 添加付款记录（线上付款记录／线下付款记录--详情）
#define kYYPageRegisterPayLogRegister currentServerUrlRelease(@"YYRegister_payLogRegister", @"not-release")
// 其他
#define kYYPageRegisterOther currentServerUrlRelease(@"YYRegister_Other", @"not-release")
/// ---------- Register  end   ---------

// (首页)选款
#define kYYPageChooseStyle currentServerUrlRelease(@"YYChooseStyle", @"not-release")
// (首页)订单
#define kYYPageOrderList currentServerUrlRelease(@"YYOrderList", @"not-release")
// (首页)我的
#define kYYPageAccountDetail currentServerUrlRelease(@"YYAccountDetail", @"not-release")
// (首页)品牌
#define kYYPageBrand currentServerUrlRelease(@"YYBrand", @"not-release")
// (首页)库存
#define kYYPageInventory currentServerUrlRelease(@"YYInventory", @"not-release")

// 选款-搜索
#define kYYPageChooseStyleSearch currentServerUrlRelease(@"YYChooseStyleSearch", @"not-release")

// 品牌-列表（两个）
#define kYYPageBrandTable currentServerUrlRelease(@"YYBrandTable", @"not-release")
// 邀请合作品牌
#define kYYPageConnAdd currentServerUrlRelease(@"YYConnAdd", @"not-release")


// 商品详情(可以加入购物车的一层)
#define kYYPageStyleDetail currentServerUrlRelease(@"YYStyleDetail", @"not-release")
// 设计师主页
#define kYYPageBrandHomePage currentServerUrlRelease(@"YYBrandHomePage", @"not-release")
// 设计师的品牌系列
#define kYYPageBrandSeries currentServerUrlRelease(@"YYBrandSeries", @"not-release")

/// ---------- Shopping start  ---------
// 加入购物车
#define kYYPageShoppingAdd currentServerUrlRelease(@"YYShopping_add", @"not-release")
// 修改款式数量
#define kYYPageShoppingUpdate currentServerUrlRelease(@"YYShopping_update", @"not-release")
/// ---------- Shopping  end   ---------

// 购物车
#define kYYPageCartDetail currentServerUrlRelease(@"YYCartDetail", @"not-release")

/// ---------- OrderModify start  ---------
// 确认订单
#define kYYPageOrderModifyConfirm currentServerUrlRelease(@"YYOrderModify_confirm", @"not-release")
// 修改订单
#define kYYPageOrderModifyUpdate currentServerUrlRelease(@"YYOrderModify_update", @"not-release")
// 补货追单
#define kYYPageOrderModifyReplenishment currentServerUrlRelease(@"YYOrderModify_replenishment", @"not-release")
/// ---------- OrderModify  end   ---------

// 消息中心
#define kYYPageGroupMessage currentServerUrlRelease(@"YYGroupMessage", @"not-release")
// 合作消息
#define kYYPageConnMsgList currentServerUrlRelease(@"YYConnMsgList", @"not-release")
// 订单消息
#define kYYPageOrderMessage currentServerUrlRelease(@"YYOrderMessage", @"not-release")
// 订单详情
#define kYYPageOrderDetail currentServerUrlRelease(@"YYOrderDetail", @"not-release")
// 如何理解订单状态／新手帮助
#define kYYPageOrderHelp currentServerUrlRelease(@"YYOrderHelp", @"not-release")
// 付款(线下支付)
#define kYYPageOrderAddMoneyLog currentServerUrlRelease(@"YYOrderAddMoneyLog", @"not-release")
// 付款记录
#define kYYPageOrderPayLog currentServerUrlRelease(@"YYOrderPayLog", @"not-release")
// 选择追单款式
#define kYYPageOrderAppend currentServerUrlRelease(@"YYOrderAppend", @"not-release")
// 管理收件地址
#define kYYPageBuyerAddress currentServerUrlRelease(@"YYBuyerAddress", @"not-release")
// 创建或修改收件地址
#define kYYPageCreateOrModifyAddress currentServerUrlRelease(@"YYCreateOrModifyAddress", @"not-release")
// 税率选择
#define kYYPageTaxChoose currentServerUrlRelease(@"YYTaxChoose", @"not-release")
// 款式备注
#define kYYPageOrderStylesRemark currentServerUrlRelease(@"YYOrderStylesRemark", @"not-release")
// 添加款式--款式列表（修改／追加）
#define kYYPageStyleDetailList currentServerUrlRelease(@"YYStyleDetailList", @"not-release")
// 订单修改记录
#define kYYPageOrderModifyLogList currentServerUrlRelease(@"YYOrderModifyLogList", @"not-release")

// yco线下订货会列表
#define kYYPageOrderingList currentServerUrlRelease(@"YYOrderingList", @"not-release")
// 线下订货会详情，带js交互
#define kYYPageOrderingDetail currentServerUrlRelease(@"YYOrderingDetail", @"not-release")

// yco新闻
#define kYYPageNews currentServerUrlRelease(@"YYNews", @"not-release")
// yco新闻
#define kYYPageNewsTableView currentServerUrlRelease(@"YYNewsTableView", @"not-release")
// yco新闻
#define kYYNewsDetail currentServerUrlRelease(@"YYNewsDetail", @"not-release")

// 聊天
#define kYYPageMessageDetail currentServerUrlRelease(@"YYMessageDetail", @"not-release")

// 我要补货/我有库存-选择合作品牌
#define kYYPageInventorySelectBrand currentServerUrlRelease(@"YYInventorySelectBrand", @"not-release")
// 我要补货/我有库存-选择款式
#define kYYPageInventorySelectOrderStyle currentServerUrlRelease(@"YYInventorySelectOrderStyle", @"not-release")
// 我要补货/我有库存-添加补货需求
#define kYYPageInventorySubmitStyleInfo currentServerUrlRelease(@"YYInventorySubmitStyleInfo", @"not-release")
// 我有库存-添加库存
#define kYYPageInventoryStore currentServerUrlRelease(@"YYInventoryStore", @"not-release")

// 我的买手店主页
#define kYYPageBuyerHomePage currentServerUrlRelease(@"YYBuyerHomePage", @"not-release")
// 编辑主页信息(编辑我的买手店)
#define kYYPageBuyerModifyInfo currentServerUrlRelease(@"YYBuyerModifyInfo", @"not-release")
// 编辑主页信息中的每一项(编辑我的买手店-详细信息/买手店简介/款式零售范围/列举合作品牌/网站/email/固定电话/手机/QQ/微信/新浪微博/微信公众号/facebook/ins)
#define kYYPageBuyerModifyInfoCell currentServerUrlRelease(@"YYBuyerModifyInfoCell", @"not-release")
// 我的预约
#define kYYPageOrderingHistoryList currentServerUrlRelease(@"YYOrderingHistoryList", @"not-release")

// 我的收藏
#define kYYPageUserCollection currentServerUrlRelease(@"YYUserCollection", @"not-release")
// 我的收藏-系列
#define kYYPageUserSeriesCollection currentServerUrlRelease(@"YYUserSeriesCollection", @"not-release")
// 我的收藏-款式
#define kYYPageUserStyleCollection currentServerUrlRelease(@"YYUserStyleCollection", @"not-release")

// 修改密码
#define kYYPageModifyPassword currentServerUrlRelease(@"YYModifyPassword", @"not-release")
// 修改电话
#define kYYPageModifyNameOrPhone currentServerUrlRelease(@"YYModifyNameOrPhone", @"not-release")

// 设置
#define kYYPageSetting currentServerUrlRelease(@"YYSettinge", @"not-release")
// 关于
#define kYYPageAboutUs currentServerUrlRelease(@"YYAboutUs", @"not-release")
// 反馈
#define kYYPageFeedback currentServerUrlRelease(@"YYFeedback", @"not-release")
// 帮助
#define kYYPageHelp currentServerUrlRelease(@"YYHelp", @"not-release")

// 展示网页信息（隐私权保护声明, 服务协议, ...）
#define kYYPageProtocolAgreement currentServerUrlRelease(@"YYProtocol", @"not-release")

// 支付（支付宝）结果
#define kYYPageOrderPayResult currentServerUrlRelease(@"YYOrderPayResult", @"not-release")


#endif /* YYBuride_h */
