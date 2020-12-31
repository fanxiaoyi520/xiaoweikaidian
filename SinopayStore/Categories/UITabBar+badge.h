//
//  UITabBar+badge.h
//  SinopayStore
//
//  Created by Jellyfish on 2017/12/8.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (badge)

//显示小红点
- (void)showBadgeOnItemIndex:(int)index;

//隐藏小红点
- (void)hideBadgeOnItemIndex:(int)index;

@end
