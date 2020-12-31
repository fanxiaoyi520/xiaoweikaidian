//
//  KDFilterView.h
//  SinopayStore
//
//  Created by 中付支付 on 2019/2/14.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FilterBlock)(NSString *searchText, NSString *beginTime, NSString *endTime);

NS_ASSUME_NONNULL_BEGIN

@interface KDFilterView : UIView

@property (nonatomic, assign)CGRect myFrame;
/// 0 显示搜索框  1 不显示搜索框  2 不显示时间
@property (nonatomic, assign)NSInteger filterType;

@property (nonatomic, copy)FilterBlock block;

@property (nonatomic, strong)NSString *placeholder;

@end

NS_ASSUME_NONNULL_END
