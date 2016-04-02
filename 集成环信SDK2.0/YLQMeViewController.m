//
//  YLQMeViewController.m
//  集成环信SDK2.0
//
//  Created by 杨卢青 on 16/3/31.
//  Copyright © 2016年 杨卢青. All rights reserved.
//

#import "YLQMeViewController.h"
#import <EaseMob.h>
@interface YLQMeViewController()
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
- (IBAction)logoutClick:(id)sender;
@end

@implementation YLQMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //获取当前登录用户名称
    NSDictionary *loginInfo = [[EaseMob sharedInstance].chatManager loginInfo];
    self.userNameLabel.text = loginInfo[@"username"];
}
- (IBAction)logoutClick:(id)sender {
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
        if (!error) {
            NSLog(@"退出成功");
            //回到登录界面
            UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            self.view.window.rootViewController = SB.instantiateInitialViewController;
        } else {
            NSLog(@"退出失败 %@", error);
        }
    } onQueue:nil];
}

@end
