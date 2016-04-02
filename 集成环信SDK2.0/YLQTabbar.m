//
//  AppDelegate.h
//  集成环信SDK2.0
//
//  Created by 杨卢青 on 16/3/31.
//  Copyright © 2016年 杨卢青. All rights reserved.
//

#import "YLQTabbar.h"

@interface YLQTabbar()
//UIColor(red: 29/255.0, green: 176/255.0, blue: 0, alpha: 1)
@property(nonatomic,strong)UIColor *textNormalColor;
//UIColor.grayColor()
@property(nonatomic,strong)UIColor *textSelectedColor;


@end

@implementation YLQTabbar

-(UIColor *)textNormalColor{
    if (!_textNormalColor) {
        _textNormalColor = [UIColor grayColor];
    }
    return _textNormalColor;
}

-(UIColor *)textSelectedColor{
    if (!_textSelectedColor) {
        _textSelectedColor = [UIColor colorWithRed:29/255.0 green:176/255.0 blue:0 alpha:1];
    }
    
    return _textSelectedColor;
}

-(void)setSelectedItem:(UITabBarItem *)selectedItem{
    [super setSelectedItem:selectedItem];
    [self changeTitleColor];
}

-(void)changeTitleColor{
    // 遍历tabbar的子控件
    for (UIView *subView in self.subviews){
//UITabBarButton
        if (![subView isKindOfClass:NSClassFromString(@"UITabBarButton")]) continue;
            
        for (UILabel *label in subView.subviews){
            //UILabel
            if (![label isKindOfClass:NSClassFromString(@"UILabel")]) continue;
            
            if (![label.text isEqualToString: self.selectedItem.title]){
                label.textColor = self.textNormalColor;
            }else{
                label.textColor = self.textSelectedColor;
            }
        }
    }
}

-(void)awakeFromNib{
//    self.backgroundColor = [UIColor darkGrayColor];
    self.backgroundImage = [UIImage imageNamed:@"tabbarBkg"];
    
}

@end
