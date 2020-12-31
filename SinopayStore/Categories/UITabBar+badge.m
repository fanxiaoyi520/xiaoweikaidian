//
//  UITabBar+badge.m
//  SinopayStore
//
//  Created by Jellyfish on 2017/12/8.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "UITabBar+badge.h"
#import "JPUSHService.h"

#define TabbarItemNums 3.0    //tabbar的数量

@implementation UITabBar (badge)


- (void)showBadgeOnItemIndex:(int)index{
    //移除之前的小红点
    [self removeBadgeOnItemIndex:index];
    
    //新建小红点
    UIView *badgeView = [[UIView alloc]init];
    badgeView.tag = 888 + index;
    badgeView.layer.cornerRadius = 5;
    badgeView.backgroundColor = [UIColor redColor];
    CGRect tabFrame = self.frame;
    
    //确定小红点的位置
    float percentX = (index +0.6) / TabbarItemNums;
    CGFloat x = ceilf(percentX * tabFrame.size.width);
    CGFloat y = ceilf(0.1 * tabFrame.size.height);
    badgeView.frame = CGRectMake(x, y, 10, 10);
    [self addSubview:badgeView];
    
    // 每次显示红点时,保存标志
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UNREAD_MESSAGE];
}

- (void)hideBadgeOnItemIndex:(int)index{
    //移除小红点
    [self removeBadgeOnItemIndex:index];
    [self resetBadge];
}

- (void)removeBadgeOnItemIndex:(int)index{
    
    //按照tag值进行移除
    for (UIView *subView in self.subviews) {
        if (subView.tag == 888+index) {
            [subView removeFromSuperview];
        }
    }
}

- (void)resetBadge {
    // 清空消息，隐藏红点
//    [ZFGlobleManager getGlobleManager].notificationInfo = nil;
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PUSH_ORDERID];
    
    // 清空服务端角标，本地角标置0
    [JPUSHService resetBadge];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    // 移除标志
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:UNREAD_MESSAGE];
}

@end
