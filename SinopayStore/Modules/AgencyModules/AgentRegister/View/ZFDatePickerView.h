//
//  ZFDatePickerView.h
//  Agent
//
//  Created by 中付支付 on 2018/9/13.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZFDatePickerViewDelegate <NSObject>

- (void)datePickerViewTag:(NSInteger)tag time:(NSString *)time;

@end

@interface ZFDatePickerView : UIView

@property (nonatomic, weak)id<ZFDatePickerViewDelegate>delegate;

- (void)show;

@end
