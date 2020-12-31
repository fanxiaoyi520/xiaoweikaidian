//
//  KDRevocateResultController.m
//  SinopayStore
//
//  Created by 中付支付 on 2017/12/11.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "KDRevocateResultController.h"

@interface KDRevocateResultController ()

@end

@implementation KDRevocateResultController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.naviTitle = NSLocalizedString(@"交易结果", nil);
    if ([_status isEqualToString:@"0"]) {
        [self createSuccessView];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"chexiao_complete" object:@"shuaxin"];
    } else {
        [self createFailedViewWith:_causeStr];
    }
}

#pragma mark 成功
- (void)createSuccessView{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-100)/2, IPhoneXTopHeight+50, 100, 100)];
    imageView.image = [UIImage imageNamed:@"pic_success"];
    [self.view addSubview:imageView];
    
    //成功标签
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.bottom+20, SCREEN_WIDTH, 20)];
    tipLabel.text = NSLocalizedString(@"撤销成功", nil);
    tipLabel.textColor = MainThemeColor;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.view addSubview:tipLabel];
    _txnAmt = [NSString stringWithFormat:@"%.2f", [_txnAmt doubleValue]/100];
    
    NSArray *titleArray = nil;
    NSArray *contentArray = nil;
    if ([_payType isEqualToString:@"Alipay"]) {
        contentArray = @[_orderID, _txnAmt];
        titleArray = @[NSLocalizedString(@"订单号", nil ), NSLocalizedString(@"撤销金额", nil )];
    } else {
        contentArray = @[_orderID, _cardNum, _txnAmt];
        titleArray = @[NSLocalizedString(@"订单号", nil ), NSLocalizedString(@"卡号", nil ), NSLocalizedString(@"撤销金额", nil )];
    }

    if ([_orderID isKindOfClass:[NSNull class]] || !_orderID) {
        _orderID = @"";
    }
    
    if ([_cardNum isKindOfClass:[NSNull class]] || !_cardNum) {
        _cardNum = @"";
    }
    
    if ([_txnAmt isKindOfClass:[NSNull class]] || !_txnAmt) {
        _txnAmt = @"";
    }
    
    CGFloat labelY = tipLabel.bottom+60;
    for (NSInteger i = 0; i < titleArray.count; i++) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 50*i+labelY, 100, 49)];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.text = titleArray[i];
        [titleLabel sizeToFit];
        [self.view addSubview:titleLabel];
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.right+5, titleLabel.y, SCREEN_WIDTH-45-titleLabel.width, titleLabel.height)];
        contentLabel.textAlignment = NSTextAlignmentRight;
        contentLabel.font = [UIFont systemFontOfSize:15];
        contentLabel.alpha = 0.6;
        contentLabel.text = contentArray[i];
        [self.view addSubview:contentLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, titleLabel.bottom+15, SCREEN_WIDTH-10, 1)];
        lineView.backgroundColor = UIColorFromRGB(0xeeeeee);
        [self.view addSubview:lineView];
    }
    
    //完成按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(40, tipLabel.bottom+260, SCREEN_WIDTH-80, 40);
    [button setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
    [button setTitleColor:MainThemeColor forState:UIControlStateNormal];
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 5;
    button.layer.borderColor = MainThemeColor.CGColor;
    [button addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

#pragma mark 失败
- (void)createFailedViewWith:(NSString *)reasonStr{
    //图标
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    imageView.center = CGPointMake(SCREEN_WIDTH/2, IPhoneXTopHeight+100);
    imageView.image = [UIImage imageNamed:@"revocate_failed_icon"];
    [self.view addSubview:imageView];
    
    //付款失败
    UILabel *failedLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, imageView.bottom+20, SCREEN_WIDTH-40, 17)];
    failedLabel.text = NSLocalizedString(@"撤销失败", nil);
    failedLabel.textAlignment = NSTextAlignmentCenter;
    failedLabel.textColor = UIColorFromRGB(0xE3494A);
    failedLabel.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:failedLabel];
    
    //失败原因
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, failedLabel.bottom+20, SCREEN_WIDTH-40, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor grayColor];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:12];
    label.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"原因", nil), reasonStr];
    [self.view addSubview:label];
    
    //完成按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(40, imageView.bottom+284, SCREEN_WIDTH-80, 40);
    [button setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
    [button setTitleColor:MainThemeColor forState:UIControlStateNormal];
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 5;
    button.layer.borderColor = MainThemeColor.CGColor;
    [button addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)popBack{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
