//
//  YLQChatViewController.m
//  集成环信SDK2.0
//
//  Created by 杨卢青 on 16/3/31.
//  Copyright © 2016年 杨卢青. All rights reserved.
//<EMChatManagerChatDelegate,
//EMChatManagerLoginDelegate,
//EMChatManagerEncryptionDelegate,  加密
//EMChatManagerBuddyDelegate,
//EMChatManagerUtilDelegate,        工具
//EMChatManagerGroupDelegate,
//EMChatManagerPushNotificationDelegate,
//EMChatManagerChatroomDelegate>

//

#import "YLQChatViewController.h"
#import <EaseMob.h>

@interface YLQChatViewController()<EMChatManagerDelegate>

@end

@implementation YLQChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}


#pragma mark - EMChatManagerDelegate
//网络状态改变的回调
- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
    //
    if (eEMConnectionDisconnected == connectionState) {
        NSLog(@"未连接");
        self.title = @"未连接";
    } else {
        NSLog(@"恢复连接");
    }
}

/*!
 @method
 @brief 将要发起自动重连操作
 @discussion
 @result
 */
- (void)willAutoReconnect {
    self.title = @"连接中";
}

/*!
 @method
 @brief 自动重连操作完成后的回调（成功的话，error为nil，失败的话，查看error的错误信息）
 @discussion
 @result
 */
- (void)didAutoReconnectFinishedWithError:(NSError *)error {
    self.navigationItem.title = @"芝麻客服";
}


#pragma mark - EMChatManagerDelegate
/*!
 @method
 @brief 好友请求被接受时的回调
 @discussion
 @param username 之前发出的好友请求被用户username接受了
 */
- (void)didAcceptedByBuddy:(NSString *)username {
    //提示用户成功
    NSString *msg = [NSString stringWithFormat:@"%@同意了你的请求", username];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加成功" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *knowAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:knowAction];
    [self presentViewController:alert animated:YES completion:nil];
}

/*!
 @method
 @brief 好友请求被拒绝时的回调
 @discussion
 @param username 之前发出的好友请求被用户username拒绝了
 */
- (void)didRejectedByBuddy:(NSString *)username {
    //提示用户被拒绝
    NSString *msg = [NSString stringWithFormat:@"%@拒绝了您的请求", username];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加失败" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *knowAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:knowAction];
    [self presentViewController:alert animated:YES completion:nil];
}

//响应 他人 添加好友请求
- (void)didReceiveBuddyRequest:(NSString *)username message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"好友的添加请求" message:message preferredStyle:UIAlertControllerStyleActionSheet];
    //两个Action
    //同意
    UIAlertAction *agree = [UIAlertAction actionWithTitle:@"Agree" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //回复给服务器
        [[EaseMob sharedInstance].chatManager acceptBuddyRequest:username error:nil];
    }];
    
    //拒绝
    UIAlertAction *reject = [UIAlertAction actionWithTitle:@"Reject" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //选择后的动作, 告诉服务器
        [[EaseMob sharedInstance].chatManager rejectBuddyRequest:username reason:@"不加陌生人" error:nil];
    }];
    [alert addAction:agree];
    [alert addAction:reject];
    
    //整合后弹出Alert
    [self presentViewController:alert animated:YES completion:nil];
}

//被好友删除, 正常不会监听的
- (void)didRemovedByBuddy:(NSString *)username {
    NSString *msg = [username stringByAppendingString:@"把你删除了"];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"好友删除提醒" message:msg preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *knowAction = [UIAlertAction actionWithTitle:@"Cancle" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:knowAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
