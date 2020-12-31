//
//  ZFPreviewCell.m
//  Agent
//
//  Created by 中付支付 on 2018/9/19.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFPreviewCell.h"
#import "UIImageView+WebCache.h"

@implementation ZFPreviewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor blackColor];
        [self createView];
    }
    return self;
}

- (void)createView{
    _scorllView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _scorllView.showsVerticalScrollIndicator = NO;
    _scorllView.showsHorizontalScrollIndicator = NO;
    _scorllView.userInteractionEnabled = YES;
    _scorllView.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:_scorllView];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    _imageView.center = CGPointMake(_scorllView.width/2, _scorllView.height/2);
    _imageView.userInteractionEnabled = YES;
    [_scorllView addSubview:_imageView];
}

- (void)setImage:(UIImage *)image{
    _imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, image.size.height/image.size.width*SCREEN_WIDTH);
    _imageView.image = image;
    _imageView.center = CGPointMake(_scorllView.width/2, _scorllView.height/2);
    if (_imageView.height > _scorllView.height) {
        _imageView.origin = CGPointMake(0, 0);
    }
    
    _scorllView.contentSize = _imageView.size;
}

- (void)setUrlString:(NSString *)urlString{
    [_imageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"icon_picloading_big"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {        
            self.imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, image.size.height/image.size.width*SCREEN_WIDTH);
            self.imageView.center = CGPointMake(self.scorllView.width/2, self.scorllView.height/2);
            if (self.imageView.height > self.scorllView.height) {
                self.imageView.origin = CGPointMake(0, 0);
            }
            
            self.scorllView.contentSize = self.imageView.size;
        } else {
            self.imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH);
            self.imageView.center = CGPointMake(self.scorllView.width/2, self.scorllView.height/2);
        }
    }];
}

@end
