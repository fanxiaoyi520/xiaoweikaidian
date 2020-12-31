//
//  KDReceiptDetailController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/9/6.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDReceiptDetailController.h"
#import "SGQRCodeTool.h"
#import "KDValidationPWController.h"

@interface KDReceiptDetailController ()
///信息
@property (nonatomic, strong)NSMutableArray *contentArray;
///商户号 撤销时用
@property (nonatomic, strong)NSString *merCode;
///撤销标志 0 未撤销 1 已撤销
@property (nonatomic, strong)NSString *refundFlag;
///token
@property (nonatomic, strong)NSString *token;
///条形码
@property (nonatomic, strong)NSString *serialNumber;
///支付类型
@property (nonatomic, strong)NSString *payType;
///消费类型
@property (nonatomic, strong)NSString *purchaseType;
@property (nonatomic, strong)UIView *backView;
@property (nonatomic, strong)NSString *codeTagStr;
@end

@implementation KDReceiptDetailController
- (UIImage *)capturImageWithUIView:(UIView *)view {
    //UIGraphicsBeginImageContext(view.bounds.size);
    UIGraphicsBeginImageContextWithOptions(view.bounds.size,NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    UIImage *currentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return currentImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.naviAndRightTitle = NSLocalizedString(@"交易详情", nil);

    _contentArray = [[NSMutableArray alloc] init];
    [_contentArray addObject:@"MERCHANT COPY"];//用户存根
    [_contentArray addObject:[ZFGlobleManager getGlobleManager].merName];//商户名

    [self getDetailData];
}

- (void)getDetailData{
    if ([_orderID isKindOfClass:[NSNull class]] || !_orderID) {
        return;
    }
    
    NSDictionary *dicts = @{@"countryCode":[ZFGlobleManager getGlobleManager].areaNum,
                            @"mobile":[ZFGlobleManager getGlobleManager].userPhone,
                            @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                            @"orderID":_orderID,
                            @"txnType":@"09"
                            };
    [[MBUtils sharedInstance] showMBWithText:@"" inView:self.view];
    [NetworkEngine singlePostWithParmas:dicts success:^(id requestResult) {
        
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] dismissMB];
            
            NSArray *arr = [NSArray arrayWithObjects:@"merCode", @"termID", @"操作员号", @"recMethod", @"termBatchID", @"termTraceNum", @"termTraceNum", @"serialNumber", @"serialNumber", @"transTime", @"serialNumber", @"productAmt", @"tipsAmt", @"txnAmt", nil];
            
            NSDictionary *dict = [requestResult objectForKey:@"list"];
            NSString *transCurr = [dict objectForKey:@"transCurr"];
            
            for (NSInteger i = 0; i < arr.count; i++) {
                NSString *key = arr[i];
                NSString *value = [dict objectForKey:key];
                
                if ([value isKindOfClass:[NSNull class]] || !value) {
                    value = @"";
                }
                
                if (i == 2) {//操作员号
                    value = @"01";
                }
                
                if (i == 11 || i == 12 || i == 13) {
                    if (value.length > 0) {//金额以分为单位
                        if (![value isEqualToString:@"-"]) {
                            value = [NSString stringWithFormat:@"%.2f", [value doubleValue]/100];
                            value = [NSString stringWithFormat:@"%@ %@", transCurr , value];
                        }
                    }
                }
                if (i == 9) {
                    if (value.length == 14) {//调整时间格式
                        value = [self setDateFormatter:value];
                    }
                }
                
                [_contentArray addObject:value];
            }
            
            _refundFlag = [dict objectForKey:@"refundFlag"];
            if ([_refundFlag isKindOfClass:[NSNull class]] || !_refundFlag) {
                _refundFlag = @"";
            }
            _merCode = [dict objectForKey:@"merCode"];
            _token = [dict objectForKey:@"cardNum"];
            _serialNumber = [dict objectForKey:@"serialNumber"];
            _purchaseType = [dict objectForKey:@"purchaseType"];
            _payType = [dict objectForKey:@"payType"];
            [self createView];
            __weak typeof(self) weakself = self;
            [self setNaviAndRightTitle:NSLocalizedString(@"交易详情", nil) rightBlock:^(UIButton *sender) {
                __strong typeof(self) strongself = weakself;
                __block UIImage *image = nil;
                [strongself.backView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.tag == 1000) {
                        obj.hidden = YES;
                        image = [strongself capturImageWithUIView:strongself.backView];
                    }
                }];
                UIImageWriteToSavedPhotosAlbum(image, strongself, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }];
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}


-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil ;
    if(error){
        msg = NSLocalizedString(@"保存图片失败" ,nil);
        [self.backView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.tag == 1000) {
                if ([self.codeTagStr isEqualToString:@"1"]) {
                    obj.hidden = NO;
                } else {
                    obj.hidden = YES;
                }
            }
        }];
        [[MBUtils sharedInstance] showMBFailedWithText:msg inView:self.view];
    }else{
        msg = NSLocalizedString(@"保存图片成功" ,nil);
        [self.backView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.tag == 1000) {
                if ([self.codeTagStr isEqualToString:@"1"]) {
                    obj.hidden = NO;
                } else {
                    obj.hidden = YES;
                }
            }
        }];
        [[MBUtils sharedInstance] showMBSuccessdWithText:msg inView:self.view];
    }
}

- (NSString *)setDateFormatter:(NSString *)dateStr{
    NSString *resultStr = @"";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddHHmmss"];
    NSDate *date = [formatter dateFromString:dateStr];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    resultStr = [formatter stringFromDate:date];
    if (!resultStr) {
        resultStr = @"";
    }
    return resultStr;
}

- (void)createView{
//    NSArray *titleArray = @[@"商戶存根", @"商戶名稱(MERCHANT NAME):", @"商戶編號(MID):", @"终端編號(TID):", @"操作員號(OPERAIOR NO):", @"交易類型(TRANS TYPE):", @"批次號(BATCH NO):", @"憑證號(VOUCHER NO):", @"授權碼(AUTO NO):", @"支付訂單號:", @"商戶訂單號:", @"日期/時間(DATE/TIME):", @"交易參考號(REF.NO):", @"金額(AMOUNT):", @"小費(TIPS):", @"總計(TOTAL):"];
    NSArray *titleArray = @[NSLocalizedString(@"商户存根", nil), NSLocalizedString(@"商户名称:", nil), NSLocalizedString(@"商户编号:", nil), NSLocalizedString(@"终端编号:", nil), NSLocalizedString(@"操作员号:", nil), NSLocalizedString(@"交易类型:", nil), NSLocalizedString(@"批次号:", nil), NSLocalizedString(@"凭证号:", nil), NSLocalizedString(@"授权码:", nil), NSLocalizedString(@"支付订单号:", nil), NSLocalizedString(@"商户订单号:", nil), NSLocalizedString(@"日期/时间:", nil), NSLocalizedString(@"交易参考号:", nil), NSLocalizedString(@"金额:", nil), NSLocalizedString(@"小费:", nil), NSLocalizedString(@"总计:", nil)];
//    NSArray *contentArray = @[@"USER COPY", @"中付電子測試", @"606090908080", @"3445959", @"01", @"銀聯掃碼支付(WALLET SALE)", @"00006", @"000081", @"", @"18090843898", @"18090843898", @"2018/09/07 14:21:19", @"18090843898", @"HKD 10.00", @"HKD 1.00", @"HKD 11.00"];
    self.view.backgroundColor = [UIColor grayColor];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-320)/2, IPhoneXTopHeight, 320, SCREEN_HEIGHT-IPhoneXTopHeight)];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:scrollView];
    
    CGFloat width = 300;
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake((320-width)/2, 0, width, scrollView.height)];
    [scrollView addSubview:backView];
    self.backView = backView;
    
    //w/55 = imageView.image.size.width / imageView.image.size.height
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"Group 4"];
    imageView.frame = CGRectMake((backView.width-(imageView.image.size.width / imageView.image.size.height)*55)/2, 30, (imageView.image.size.width / imageView.image.size.height)*55, 55);
    imageView.centerX = width/2;
    [backView addSubview:imageView];

    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.font = [UIFont systemFontOfSize:24];
    [nameLabel sizeToFit];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.frame = CGRectMake(0, imageView.bottom+10, width, nameLabel.height);
    [backView addSubview:nameLabel];
    if ([_payType isEqualToString:@"Alipay"]) {
        nameLabel.text = NSLocalizedString(@"支付寶掃碼簽購單",nil);
        imageView.image = [UIImage imageNamed:@"icon_zhifubao"];
        imageView.frame = CGRectMake((backView.width-(imageView.image.size.width / imageView.image.size.height)*55)/2, 30, (imageView.image.size.width / imageView.image.size.height)*55, 55);
    } else {
        nameLabel.text = NSLocalizedString(@"銀聯掃碼簽購單",nil);
        imageView.image = [UIImage imageNamed:@"Group 4"];
        
        imageView.frame = CGRectMake((backView.width-(imageView.image.size.width / imageView.image.size.height)*55)/2, 30, (imageView.image.size.width / imageView.image.size.height)*55, 55);
    }
    
    NSInteger count = titleArray.count;
    CGFloat y = nameLabel.bottom+5;
    for (NSInteger i = 0; i < count; i++) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.text = titleArray[i];
        [titleLabel sizeToFit];
        titleLabel.origin = CGPointMake(0, y);
        [backView addSubview:titleLabel];
        
        UILabel *contentLabel = [[UILabel alloc] init];
        contentLabel.font = [UIFont systemFontOfSize:12];
        contentLabel.textAlignment = NSTextAlignmentRight;
        
        CGFloat contentX = titleLabel.right+10;
        CGFloat contentY = titleLabel.y;
        if (i == 1 || i == 5) {
            contentLabel.font = [UIFont systemFontOfSize:16];
            contentLabel.textAlignment = NSTextAlignmentLeft;
            contentX = 0;
            contentY = titleLabel.bottom+3;
        }
        
        if (i == 9 || i == 10 || i == 11) {
            contentLabel.textAlignment = NSTextAlignmentLeft;
            contentX = 0;
            contentY = titleLabel.bottom+3;
            if (i == 11) {
                contentX = 20;
            }
        }
        
        if (i == 13 || i == 14 || i == 15) {
            contentLabel.textAlignment = NSTextAlignmentLeft;
            contentLabel.font = [UIFont boldSystemFontOfSize:16];
            contentY = titleLabel.bottom+3;
            contentX = 50;
        }
        
        NSString *contentStr = _contentArray[i];
        if (contentStr.length < 1) {
            contentStr = @" ";
        }
        contentLabel.text = contentStr;
        [contentLabel sizeToFit];
        contentLabel.frame = CGRectMake(contentX, contentY, width-contentX, contentLabel.height);
        [backView addSubview:contentLabel];
        
        y = contentLabel.bottom+3;
        
        if (i == 0 || i == 15) {//虚线
            UIImageView *lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, contentLabel.bottom+2, width, 1)];
            lineImage.image = [UIImage imageNamed:@"line_receipt"];
            [backView addSubview:lineImage];
            
            y = lineImage.bottom+3;
        }
        
        if (i == 10) {//条形码
            UIImageView *txImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, y, width-40, 50)];
            txImageView.image = [self generateBarCodeWith:_serialNumber size:CGSizeMake(width, txImageView.height)];
            [backView addSubview:txImageView];
            
            y = txImageView.bottom+3;
        }
    }
    
    //标注
    UILabel *bzlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, 100, 10)];
    bzlabel.text = NSLocalizedString(@"标注", nil);
    bzlabel.font = [UIFont systemFontOfSize:10];
    [backView addSubview:bzlabel];
    y = bzlabel.bottom+5;
    
    //token
    UILabel *tokenLabel = [[UILabel alloc] init];
    tokenLabel.font = [UIFont systemFontOfSize:13];
    tokenLabel.text = [NSString stringWithFormat:@"TOKEN: %@", _token];
    [tokenLabel sizeToFit];
    tokenLabel.frame = CGRectMake(0, y, tokenLabel.width, tokenLabel.height);
    [backView addSubview:tokenLabel];
    y = tokenLabel.bottom;
    
    //提示标签
//    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y+40, width, 40)];
//    tipLabel.font = [UIFont systemFontOfSize:10];
//    tipLabel.text = @"本人确认以上交易，统一将其计入本卡账户\nI ACKNOWLEDGE SATISFACTORY RECEIPT OF RELATIVE GOODS SERVICE";
//    tipLabel.numberOfLines = 0;
//    [backView addSubview:tipLabel];
//    y = tipLabel.bottom;
    
    //撤銷按鈕
    UIButton *revocationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    revocationBtn.frame = CGRectMake(0, y+40, width, 40);
    revocationBtn.layer.cornerRadius = 5.0;
    [revocationBtn setTitle:NSLocalizedString(@"撤销", nil) forState:UIControlStateNormal];
    [revocationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    revocationBtn.backgroundColor = MainThemeColor;
    [revocationBtn addTarget:self action:@selector(revocationBtn) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:revocationBtn];
    revocationBtn.tag = 1000;
    if ([[ZFGlobleManager getGlobleManager].channleCannel isEqualToString:@"open"] && [_purchaseType isEqualToString:@"TRADE"]) {
        revocationBtn.hidden = NO;
    } else {
        revocationBtn.hidden = YES;
    }
    
    if (![_refundFlag isEqualToString:@"0"] && [_purchaseType isEqualToString:@"TRADE"]) {
        revocationBtn.hidden = NO;
        revocationBtn.enabled = NO;
        revocationBtn.alpha = 0.6;
        revocationBtn.backgroundColor = [UIColor grayColor];
        [revocationBtn setTitle:NSLocalizedString(@"已撤销", nil) forState:UIControlStateNormal];
    }
    y = revocationBtn.bottom;
    if (revocationBtn.hidden == NO) self.codeTagStr = @"1";
    if (revocationBtn.hidden == YES) self.codeTagStr = @"2";
    backView.height = y+20;
    scrollView.contentSize = CGSizeMake(width, y+20);
}

#pragma mark 生成条形码
- (UIImage *)generateBarCodeWith:(NSString *)str size:(CGSize)size {
    CIImage *ciImage = [self generateBarCodeImage:str];
    UIImage *image = [self resizeCodeImage:ciImage withSize:size];
    return image;
}
/**
 *  生成条形码
 */
- (CIImage *) generateBarCodeImage:(NSString *)source{
    // iOS 8.0以上的系统才支持条形码的生成，iOS8.0以下使用第三方控件生成
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 注意生成条形码的编码方式
        NSData *data = [source dataUsingEncoding: NSASCIIStringEncoding];
        CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
        [filter setValue:data forKey:@"inputMessage"];
        // 设置生成的条形码的上，下，左，右的margins的值
        [filter setValue:[NSNumber numberWithInteger:0] forKey:@"inputQuietSpace"];
        return filter.outputImage;
    }else{
        return nil;
    }
}

- (UIImage *) resizeCodeImage:(CIImage *)image withSize:(CGSize)size{
    if (image) {
        CGRect extent = CGRectIntegral(image.extent);
        CGFloat scaleWidth = size.width/CGRectGetWidth(extent);
        CGFloat scaleHeight = size.height/CGRectGetHeight(extent);
        size_t width = CGRectGetWidth(extent) * scaleWidth;
        size_t height = CGRectGetHeight(extent) * scaleHeight;
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
        CGContextRef contentRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef imageRef = [context createCGImage:image fromRect:extent];
        CGContextSetInterpolationQuality(contentRef, kCGInterpolationNone);
        CGContextScaleCTM(contentRef, scaleWidth, scaleHeight);
        CGContextDrawImage(contentRef, extent, imageRef);
        CGImageRef imageRefResized = CGBitmapContextCreateImage(contentRef);
        CGContextRelease(contentRef);
        CGImageRelease(imageRef);
        return [UIImage imageWithCGImage:imageRefResized];
    }else{
        return nil;
    }
}

#pragma mark 撤銷
- (void)revocationBtn{
    if ([_orderID isKindOfClass:[NSNull class]] || !_orderID) {
        return;
    }
    if ([_merCode isKindOfClass:[NSNull class]] || !_merCode) {
        return;
    }
    
    [XLAlertController acWithTitle:NSLocalizedString(@"确认撤销此交易？", nil) msg:@"" confirmBtnTitle:NSLocalizedString(@"确定", nil) cancleBtnTitle:NSLocalizedString(@"取消", nil) confirmAction:^(UIAlertAction *action) {
        KDValidationPWController *vaVC = [[KDValidationPWController alloc] init];
        vaVC.payType = _payType;
        vaVC.orderID = _orderID;
        vaVC.merCode = _merCode;
        [self pushViewController:vaVC];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
