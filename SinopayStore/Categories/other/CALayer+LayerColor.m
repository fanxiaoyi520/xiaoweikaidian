//
//  CALayer+LayerColor.m
//  XzfPos
//
//  Created by 中付支付 on 2017/9/15.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "CALayer+LayerColor.h"

@implementation CALayer (LayerColor)

- (void)setBorderColorFromUIColor:(UIColor *)color{
    self.borderColor = color.CGColor;
}

@end
