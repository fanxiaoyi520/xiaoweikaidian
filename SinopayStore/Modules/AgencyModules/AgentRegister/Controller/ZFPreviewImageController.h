//
//  ZFPreviewImageController.h
//  Agent
//
//  Created by 中付支付 on 2018/9/19.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

typedef void(^MyBlock)(NSInteger index);

@interface ZFPreviewImageController : ZFBaseViewController
///预览的图片数组
@property (nonatomic, strong)NSMutableArray *imageArray;
///预览的序列
@property (nonatomic, assign)NSInteger index;
///隐藏删除按钮
@property (nonatomic, assign)BOOL isHiddenDelete;

@property (nonatomic, copy)MyBlock block;

///是否是URL格式
@property (nonatomic, assign)BOOL isURL;

@end
