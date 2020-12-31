//
//  KDAddMerSuccessController.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/2/18.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDAddMerSuccessController.h"

@interface KDAddMerSuccessController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeight;
@property (weak, nonatomic) IBOutlet UILabel *merNumL;
@property (weak, nonatomic) IBOutlet UILabel *terMumL;
@property (weak, nonatomic) IBOutlet UILabel *merNameL;
@property (weak, nonatomic) IBOutlet UILabel *merAddressL;

@end

@implementation KDAddMerSuccessController

- (void)viewDidLoad {
    [super viewDidLoad];
    _topHeight.constant = IPhoneXTopHeight;
    self.naviTitle = NSLocalizedString(@"开通成功", nil);
    [self setValue];
}

- (void)setValue{
    _merNumL.text = [_merDict objectForKey:@"merNo"];
    _terMumL.text = [_merDict objectForKey:@"termCode"];
    _merNameL.text = [_merDict objectForKey:@"merName"];
    _merAddressL.text = [_merDict objectForKey:@"merAddress"];
}

- (IBAction)checkRate:(id)sender {
    NSString *rateStr = [_merDict objectForKey:@"feeRate"];
    if ([rateStr isKindOfClass:[NSNull class]] || !rateStr) {
        return;
    }
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"手续费率", nil) message:[NSString stringWithFormat:@"%@ %@%%", NSLocalizedString(@"当前设备手续费率为:", nil), rateStr] preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *alertA = [UIAlertAction actionWithTitle:NSLocalizedString(@"知道了", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertC addAction:alertA];
    [self presentViewController:alertC animated:YES completion:nil];
}

- (IBAction)completeBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
