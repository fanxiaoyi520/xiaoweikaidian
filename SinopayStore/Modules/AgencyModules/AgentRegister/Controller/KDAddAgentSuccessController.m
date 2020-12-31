//
//  KDAddAgentSuccessController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/12/26.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDAddAgentSuccessController.h"

@interface KDAddAgentSuccessController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeight;
@property (weak, nonatomic) IBOutlet UIButton *completeBtn;

@end

@implementation KDAddAgentSuccessController

- (void)viewDidLoad {
    [super viewDidLoad];
    _topHeight.constant = IPhoneXTopHeight+80;
    self.naviTitle = NSLocalizedString(@"提交成功", nil);
    _completeBtn.layer.borderWidth = 1;
    _completeBtn.layer.borderColor = MainThemeColor.CGColor;
}

- (IBAction)completeBtn:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
