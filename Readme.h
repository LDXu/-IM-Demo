
 第一次用户登录, 下次免登陆, 直接进入到主界面
    是否登陆过(通过偏好设置, 把登录状态记录起来)
    到程序启动的时候, 就从沙盒里获取登录状态
    程序启动后, 发送用户名和密码到服务器, 建立连接

自动登录:
    环信, 会把用户的登录信息保存到沙盒
    当程序启动, 自动登录到服务器

环信集成监听网络状态
    当网络突然不通, 当网络恢复时, 自动连接到服务器

---
显示好友列表
    从本地获取
    从服务器获取
-->开启自动获取好友列表
[[EaseMob sharedInstance].chatManager setIsAutoFetchBuddyList:YES];
---
监听好友的动作, 刷新列表

---
获取登录用户信息, 在chatManager的字典loginInfo里
---

显示聊天数据
    从数据库MessageV1这张表获取对应记录
    刷新表格
---

声音用图文混排, 监听label点击, 加入动画, 让label可以交互