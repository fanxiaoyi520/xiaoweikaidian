//
//  KDScanTradeResultController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/11/21.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDScanTradeResultController.h"

@interface KDScanTradeResultController ()
@property (weak, nonatomic) IBOutlet UIImageView *resultImageView;
@property (weak, nonatomic) IBOutlet UILabel *resultL;
@property (weak, nonatomic) IBOutlet UILabel *detailL;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumL;
@property (weak, nonatomic) IBOutlet UIButton *completeBtn;

@end

@implementation KDScanTradeResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"交易结果", nil);
    _completeBtn.layer.borderColor = MainThemeColor.CGColor;
    _completeBtn.layer.borderWidth = 1;
    [self setValue];
}

- (void)setValue{

    [_completeBtn setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
    if (_tradeType == 1) {//失败
        _resultImageView.image = [UIImage imageNamed:@"pic_failed"];
        _resultL.text = NSLocalizedString(@"收款失败", nil);
        _detailL.text = NSLocalizedString(_errMsg, nil);
    } else {//成功
        _resultL.text = NSLocalizedString(@"收款成功", nil);
        _detailL.text = [NSString stringWithFormat:@"+ %.2f", [_amount doubleValue]/100];
        if ([_cardNo isEqualToString:@""]) _phoneNumL.hidden = YES;
        _phoneNumL.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"卡号", nil), _cardNo];
    }
}

- (IBAction)completeBtn:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
