//
//  ZFSignNameController.m
//  Agent
//
//  Created by 中付支付 on 2018/10/24.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFSignNameController.h"
#import "MyView.h"

@interface ZFSignNameController ()

@property (weak, nonatomic) IBOutlet UIView *signView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signHeightConstraint;
@property (weak, nonatomic) IBOutlet MyView *drawRect;

@end

@implementation ZFSignNameController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = GrayBgColor;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.drawRect initVariable];
    
    self.signWidthConstraint.constant = SCREEN_HEIGHT;
    self.signHeightConstraint.constant = SCREEN_WIDTH;
    self.signView.transform = CGAffineTransformIdentity;
    self.signView.frame = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
    self.signView.transform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(M_PI_2), (SCREEN_HEIGHT - SCREEN_WIDTH) / 2, (SCREEN_HEIGHT - SCREEN_WIDTH) / 2);
}

//隐藏状态栏
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)backBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)resignBtn:(id)sender {
    [_drawRect clear];
}

- (IBAction)confirmBtn:(id)sender {
    if ([_drawRect doAnySign] >= 60) {
        self.block([self saveScreen]);
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [[MBUtils sharedInstance] showMBTipWithText:@"签名太过简单，请重签" inView:self.view];
    }
}

- (UIImage *)saveScreen{
    
    UIView *screenView = _drawRect;
    
    UIGraphicsBeginImageContext(screenView.bounds.size);
    [screenView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
