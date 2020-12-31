//
//  KDSendReportController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/5/15.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDSendReportController.h"

@interface KDSendReportController ()
@property (nonatomic, strong)UITextField *textField;
@end

@implementation KDSendReportController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"发送结算报告", nil);
    self.view.backgroundColor = GrayBgColor;
    [self createView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_textField becomeFirstResponder];
}

- (void)createView{
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, IPhoneXTopHeight, SCREEN_WIDTH-40, 44)];
    tipLabel.text = NSLocalizedString(@"结算报告发送至邮箱", nil);
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.alpha = 0.6;
    [self.view addSubview:tipLabel];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, tipLabel.bottom, SCREEN_WIDTH, 44)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-40, backView.height)];
    _textField.placeholder = NSLocalizedString(@"请输入邮箱", nil);
    _textField.font = [UIFont systemFontOfSize:16];
    _textField.keyboardType = UIKeyboardTypeEmailAddress;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [backView addSubview:_textField];
    
    //确定按钮
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, backView.bottom+42, SCREEN_WIDTH-40, 44)];
    confirmBtn.backgroundColor = MainThemeColor;
    confirmBtn.layer.cornerRadius = 5;
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [confirmBtn setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirmBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmBtn];
}

- (void)confirmBtn{
    [self.view endEditing:YES];
    
    if (_textField.text.length == 0) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请输入邮箱", nil) inView:self.view];
        return;
    }
    if (![self isEmailAddress:_textField.text]) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"邮箱输入错误", nil) inView:self.view];
        return;
    }
    
    if (!_merIdAndTime) {
        _merIdAndTime = @"";
    }
//    [self upLoadeImage];
    [self sendEmail];
}

- (NSString *)encodeToPercentEscapeString: (NSString *) input{
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    NSString *outputStr = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,                   (CFStringRef)input, NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8));
    return outputStr;
}

- (void)upLoadeImage{
    
    NSString *imageStr = [UIImageJPEGRepresentation(_webImage, 0.5) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    imageStr = [self encodeToPercentEscapeString:imageStr];
    if (!imageStr) {
        imageStr = @"";
    }
    
    NSDictionary *dict = @{@"countryCode" : [ZFGlobleManager getGlobleManager].areaNum,
                           @"mobile" : [ZFGlobleManager getGlobleManager].userPhone,
                           @"sessionID" : [ZFGlobleManager getGlobleManager].tempSessionID,
                           @"image" : imageStr,
                           @"imageParam" : @"picSett",
                           @"timeStamp" : _nowTime,
                           @"txnType":@"07",
                           };
    [[MBUtils sharedInstance] showMBWithText:@"" inView:self.view];
    
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) { // 成功
            [self sendEmail];
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

- (void)sendEmail{
    NSDictionary *dicts = @{@"countryCode":[ZFGlobleManager getGlobleManager].areaNum,
                            @"mobile":[ZFGlobleManager getGlobleManager].userPhone,
                            @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                            @"email":_textField.text,
                            @"merIdAndDate":_merIdAndTime,
                            @"txnType":@"63"
                            };
    
    [NetworkEngine singlePostWithParmas:dicts success:^(id requestResult) {
        
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] showMBSuccessdWithText:[requestResult objectForKey:@"msg"] inView:[UIApplication sharedApplication].keyWindow];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

//邮箱
- (BOOL)isEmailAddress:(NSString *)inputStr{
     NSString *emailRegex = @"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
     NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
     return [pre evaluateWithObject:inputStr];
}

@end
