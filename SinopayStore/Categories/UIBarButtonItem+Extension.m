//
//  UIBarButtonItem+Extension.m
//  Jellyfish
//
//  Created by Jellyfish on 16/4/13.
//  Copyright © 2016年 ios-21. All rights reserved.
//

#import "UIBarButtonItem+Extension.h"
#import "UIView+FrameCategory.h"

@implementation UIBarButtonItem (Extension)

/**
 *  自定义UIBarButtonItem
 *
 *  @param action           点击item后需要调用的方法
 *  @param image            图片
 *  @param highlightedImage 高亮时图片
 *
 *  @return 创建完的item
 */
+ (UIBarButtonItem *)itemWithTarget:(id)target action:(SEL)action image:(NSString *)image highlightedImage:(NSString *)highlightedImage {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    //设置图片
    [btn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:highlightedImage] forState:UIControlStateHighlighted];
    //设置尺寸
    btn.size = btn.currentImage.size;
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

@end
