//
//  YLQChatPageViewController.m
//  集成环信SDK2.0
//
//  Created by 杨卢青 on 16/4/1.
//  Copyright © 2016年 杨卢青. All rights reserved.
//

#import "YLQChatPageViewController.h"
#import "YLQChatPageCell.h"
#import <AVFoundation/AVFoundation.h>
#import "EaseMob.h"
#import "EMCDDeviceManager.h"
#import "YLQVoiceTool.h"

//#import <EaseMob.h>

@interface YLQChatPageViewController()<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, EMChatManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarBottomConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarHeightConstraints;

/** 计算cell高度的工具*/
@property (nonatomic, strong) YLQChatPageCell *chatCellTool;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UIButton *typeSelectButton;

@property (weak, nonatomic) IBOutlet UIButton *voiceButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
//存放对方聊天内容
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation YLQChatPageViewController

#pragma mark - lazy load
- (YLQChatPageCell *)chatCellTool {
    
    if (!_chatCellTool) {
        _chatCellTool = [self.tableView dequeueReusableCellWithIdentifier:ReceiverCellID];
    }
    
    return _chatCellTool;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.buddy.username;

    
    // 添加代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    //加载本地数据库的聊天记录
    [self loadMessageFramDB];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //监听键盘弹出
    NSNotificationCenter *center =[NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - 监听键盘
- (void)keyboardWillShow:(NSNotification *)center{
    //获取键盘frame
    CGRect keyboardFrame = [center.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.toolBarBottomConstraints.constant = keyboardFrame.size.height;
}

- (void)keyboardWillHide:(NSNotification *)center{
    self.toolBarBottomConstraints.constant = 0;
}

#pragma mark - 加载聊天记录
- (void)loadMessageFramDB {
    //获取会话对象  单聊
    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:self.buddy.username conversationType:eConversationTypeChat];
    //获取聊天记录
    //标准使用这个
//    - (NSArray *)loadNumbersOfMessages:(NSUInteger)aCount before:(long long)timestamp;
    //但是现在简单的加载所有
    NSArray *allMessage = [conversation loadAllMessages];
    [self.dataArray addObjectsFromArray:allMessage];
}

#pragma mark - TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //聊天类型
    EMMessage *message = self.dataArray[indexPath.row];
    //是否是接收方
    BOOL isReceiver = [message.from isEqualToString:self.buddy.username];
    YLQChatPageCell *cell = nil;
    if (isReceiver) {
        cell = [tableView dequeueReusableCellWithIdentifier:ReceiverCellID];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:SenderCellID];
    }
    cell.message = self.dataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //把接受到的内容给 用来计算cell高度的cell
    self.chatCellTool.message = self.dataArray[indexPath.row];
    return [self.chatCellTool getCellHeight];
}

#pragma mark - 监听TextView的文字变化
- (void)textViewDidChange:(UITextView *)textView {
    //计算textView里面文字的高度
    CGFloat textHeight = textView.contentSize.height;
    if (textHeight > 68) {
        textHeight = 68;
    }
    
    self.toolBarHeightConstraints.constant = textHeight + 13;
    
    // 如果最后一个字是换行字符，代表点击了“发送按钮”
    if([textView.text hasSuffix:@"\n"]){
        
        //取出回车换行字符
        NSString *text = [textView.text substringToIndex:textView.text.length - 1];
        // 1.把消息发送给服务器
        [self sendMessage:text];
        
        // 2.清空textView的文字
        textView.text = nil;
        
        // 3.恢复InputToolBar高度
        self.toolBarHeightConstraints.constant = 46;
    }
    

}

- (void)sendMessage:(NSString *)msg {
    //创建消息体
    //    EMTextMessageBody  文本消息体
    //    EMVideoMessageBody 视频消息体
    //    EMVoiceMessageBody 语音消息体
    //    EMLocationMessageBody 位置消息体
    //    EMImageMessageBody 图片消息
    EMChatText *chatText = [[EMChatText alloc] initWithText:msg];
    EMTextMessageBody *textBuddy = [[EMTextMessageBody alloc] initWithChatObject:chatText];
    
    //bodies  只传一个
    EMMessage *message = [[EMMessage alloc] initWithReceiver:self.buddy.username bodies:@[textBuddy]];
#warning 聊天消息的类型默认就是单聊
    message.messageType = eMessageTypeChat; // 设置为单聊消息
    //message.messageType = eConversationTypeGroupChat;// 设置为群聊消息
    //message.messageType = eConversationTypeChatRoom;// 设置为聊天室消息
    

    [[EaseMob sharedInstance].chatManager asyncSendMessage:message progress:nil prepare:^(EMMessage *message, EMError *error) {
        NSLog(@"准备发送消息");
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            NSLog(@"发送消息成功");
        } else {
            NSLog(@"发送消息失败");
        }
    } onQueue:nil];
    
    // 刷新表格
    [self.dataArray addObject:message];
    [self.tableView reloadData];
}

// 接收到好友回复的消息
-(void)didReceiveMessage:(EMMessage *)message{
    //微信： test3 - test2
    //环信： test4 - tes3 //的聊天记录也显示
#warning 只有是当前好友的聊天记录，才显示
    if (![message.from isEqualToString:self.buddy.username])return;
    
#warning  只有是单聊的聊天类型，才显示
    if (message.messageType != eMessageTypeChat) return;
    
    // 把消息添加到数据源
    [self.dataArray addObject:message];
    // 刷新表格
    [self.tableView reloadData];
    
}

- (IBAction)startRecord:(id)sender {
    // 1.NSFileManger (创建一个录音文件)
    // 2.把录音的数据写入一个文件
    //    不使用AVAudioRecorder类实现，使用环信封装录音框架
    
#warning 每次录音的文件名需要不同的
    int x = arc4random() % 100000;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
    [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error) {
        if (!error) {
            NSLog(@"录音开启成功");
        }else{
            NSLog(@"录音开启失败%@",error);
        }
    }];
    
}
- (IBAction)stopRecord:(id)sender {
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
//        NSLog(@"%@",recordPath);
        if (!error) {
            // 发语音给服务器
            [self sendVoiceMessage:recordPath duration:aDuration];
        }else{
            NSLog(@"发语音给服务器失败%@",error);
        }
        
    }];
}

-(void)sendVoiceMessage:(NSString *)filePath duration:(NSInteger)duration{
    
#warning 开发时，加上时间长短的判断
    
    // 创建一个聊天的语音对象
    EMChatVoice *chatVoice = [[EMChatVoice alloc] initWithFile:filePath displayName:@"音频"];
    chatVoice.duration = duration;
    
    // 创建一个语音的消息
    EMVoiceMessageBody *voiceBody = [[EMVoiceMessageBody alloc] initWithChatObject:chatVoice];
    
    // 把语音封装成一个EMMeaage对象
    EMMessage *message = [[EMMessage alloc] initWithReceiver:self.buddy.username bodies:@[voiceBody]];
    
    
    // 发送
    [[EaseMob sharedInstance].chatManager asyncSendMessage:message progress:nil prepare:^(EMMessage *message, EMError *error) {
        NSLog(@"准备发送语音");
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        NSLog(@"发送语音成功");
    } onQueue:nil];
    
    // 刷新表格
    [self.dataArray addObject:message];
    [self.tableView reloadData];
    
}

- (IBAction)cancelRecord:(id)sender {
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
}

- (IBAction)voiceButtonClick:(id)sender {
    self.recordButton.hidden = !self.recordButton.hidden;
    
    if (self.recordButton.hidden == NO) {
        // 退出键盘, 结束编辑
        [self.view endEditing:YES];
        
        // 让InputToolBar回到默认46的高度
        self.toolBarHeightConstraints.constant = 46;
    }else{
        // 键盘弹出
        [self.inputTextView becomeFirstResponder];
        
        // 让InputToolBar回到实际高度
        [self textViewDidChange:self.inputTextView];
        
    }
}

#pragma mark - imagePickDelegate
- (IBAction)typeSelectorClick:(id)sender {
    UIImagePickerController *imgPick = [[UIImagePickerController alloc] init];
    imgPick.delegate = self;
    imgPick.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imgPick animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    //获取用户选择的图片
    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
    //发图片
//    [self sendImageMassege:selectedImage];
}

//- (void)sendImageMassege:(UIImage *)selectedImage {
//    //创建图片消息体
//    EMImageMessageBuddy *imageBuddy = [EMImageMessageBuddy alloc]
//    //创建消息对象
//    EMMessage *message = [EMMessage alloc] initWithReceiver:self.buddy.username bodies:<#(NSArray *)#>
//}


#pragma mark - ScrollDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //停止语音播放
    [YLQVoiceTool stop];
}

@end
