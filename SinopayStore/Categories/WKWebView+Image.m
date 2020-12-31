//
//  WKWebView+Image.m
//  XzfPos
//
//  Created by wd on 2017/10/16.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "WKWebView+Image.h"
#import <QuartzCore/QuartzCore.h>

@implementation WKWebView (Image)

- (UIImage *)imageRepresentation{
    CGSize boundsSize = self.scrollView.contentSize;
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
    UIGraphicsBeginImageContextWithOptions(boundsSize, YES, 0.0);
    if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    }
    else{
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
