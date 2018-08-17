//
//  YYMessageApi.m
//  yunejianDesigner
//
//  Created by Apple on 16/10/20.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYMessageApi.h"
#import "YYRequestHelp.h"
#import "RequestMacro.h"
#import "UserDefaultsMacro.h"
#import "YYHttpHeaderManager.h"

@implementation YYMessageApi
//获取合作买手店
+ (void)getUserChatListPageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYMessageUserChatListModel *chatListModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kMessageUserChatList];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kMessageUserChatList params:nil];

    NSDictionary *parameters = @{@"pageIndex":@(pageIndex),@"pageSize":@(pageSize)};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            YYMessageUserChatListModel * chatList = [[YYMessageUserChatListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,chatList,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}


//删除会话
+(void)deleteMessageUserChat:(NSString *)oppositeEmail andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kMessageUserChatDelete];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kMessageUserChatDelete params:nil];

    NSDictionary *parameters = @{@"oppositeEmail":oppositeEmail};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}
//会话已读
+(void)markAsReadMessageUserChatWithOppositeId:(NSNumber*)oppositeId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSInteger num, NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kMessageMarkAsRead];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kMessageMarkAsRead params:nil];

    NSDictionary *parameters = @{@"receiveId":oppositeId};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            NSInteger num = [responseObject integerValue];
            block(rspStatusAndMessage,num,error);
        }else{
            block(rspStatusAndMessage,0,error);
        }
    }];
}

//消息历史记录
+ (void)getMessageTalkHistoryWithOppositeId:(NSNumber*)oppositeId pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYMessageTalkListModel *talkListModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kMessageTalkHistory];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kMessageTalkHistory params:nil];

    NSDictionary *parameters = @{@"receiveId":oppositeId,@"pageIndex":@(pageIndex),@"pageSize":@(pageSize)};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            YYMessageTalkListModel * talkList = [[YYMessageTalkListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,talkList,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}

//发送私信
+(void)sendTalkWithOppositeId:(NSNumber*)oppositeId content:(NSString *)content charType:(NSString *)charType andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kMessageSend];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kMessageSend params:nil];

    NSDictionary *parameters = @{@"receiveIds":oppositeId,@"content":content,@"chatType":charType};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}
@end
