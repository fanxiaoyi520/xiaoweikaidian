//
//  ZFBaseViewController.h
//  StatePay
//
//  Created by Jellyfish on 17/3/13.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFBaseViewController : UIViewController

/** 导航栏下面的横线,子类可自定义是否影藏 */
@property (nonatomic, weak) UIImageView *navBarHairlineImageView;

/** 子页，有返回按钮 */
@property(nonatomic, copy) NSString *naviTitle;

/** 首页，无返回按钮 */
@property(nonatomic, copy) NSString *homeNaviTitle;

///白色导航栏
@property (nonatomic, copy)NSString *whiteNavTitle;
// 推出下一个控制器
- (void)pushViewController:(UIViewController *)vc;

- (void)setNaviAndRightTitle:(NSString *)naviTitle rightBlock:(void (^)(UIButton *sender))rightBlock;


@end
