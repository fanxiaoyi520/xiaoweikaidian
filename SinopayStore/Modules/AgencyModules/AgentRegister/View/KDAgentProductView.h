//
//  KDAgentProductView.h
//  SinopayStore
//
//  Created by 中付支付 on 2018/12/26.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KDAgentProductViewDelegate <NSObject>

- (void)productViewClick;

@end

@interface KDAgentProductView : UIView

@property (weak, nonatomic) IBOutlet UITextField *productTF;
@property (weak, nonatomic) IBOutlet UITextField *rateTF;
@property (weak, nonatomic) IBOutlet UITextField *beginTimeTF;
@property (weak, nonatomic) IBOutlet UITextField *endTimeTF;

@property (nonatomic, assign)id <KDAgentProductViewDelegate> delegate;

@property (nonatomic, assign)CGFloat viewHeight;
@property (nonatomic, strong)NSArray *dataArray;

@property (nonatomic, strong)UIViewController *superVC;

- (NSDictionary *)getAllValue;

@end

NS_ASSUME_NONNULL_END
