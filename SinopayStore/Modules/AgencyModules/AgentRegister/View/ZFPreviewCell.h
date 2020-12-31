//
//  ZFPreviewCell.h
//  Agent
//
//  Created by 中付支付 on 2018/9/19.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFPreviewCell : UICollectionViewCell

@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, strong)UIScrollView *scorllView;

@property (nonatomic, strong)UIImage *image;
@property (nonatomic, strong)NSString *urlString;
@end
