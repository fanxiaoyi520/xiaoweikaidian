//
//  UIColor+TrasferImage.m
//  XzfPos
//
//  Created by 许树轩 on 2017/11/15.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "UIColor+TrasferImage.h"

@implementation UIColor (TrasferImage)

- (UIImage *)getColorImage {
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
