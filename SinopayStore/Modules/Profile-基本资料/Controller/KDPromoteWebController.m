//
//  KDPromoteWebController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/5/23.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDPromoteWebController.h"
#import "SGQRCodeTool.h"

#define PromoteCodeStr [NSString stringWithFormat:@"qrcodeStr%@", [ZFGlobleManager getGlobleManager].merID]

@interface KDPromoteWebController ()

@property (nonatomic, strong)UIImageView *codeImageView;
@property (nonatomic, strong)NSString *qrcodeStr;

@end

@implementation KDPromoteWebController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"推广有奖", nil);
    self.view.backgroundColor = GrayBgColor;
    
    _qrcodeStr = [[NSUserDefaults standardUserDefaults] objectForKey:PromoteCodeStr];
    
    [self createView];
    
    [self getQRCodeString];
}

- (void)getQRCodeString{
    NSDictionary *dict = @{@"countryCode":[ZFGlobleManager getGlobleManager].areaNum,
                           @"mobile":[ZFGlobleManager getGlobleManager].userPhone,
                           @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                           @"merId":[ZFGlobleManager getGlobleManager].merID,
                           @"txnType":@"68"
                           };
    if (!_qrcodeStr) {
        [[MBUtils sharedInstance] showMBInView:self.view];
    }
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] dismissMB];
            _qrcodeStr = [requestResult objectForKey:@"qrCode"];
            _codeImageView.image = [self getImageWithString:_qrcodeStr];
            
            [[NSUserDefaults standardUserDefaults] setObject:_qrcodeStr forKey:PromoteCodeStr];
            
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

- (void)createView{
    
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_WIDTH)];
    backImageView.image = [UIImage imageNamed:@"pic_promote_background"];
    [self.view addSubview:backImageView];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180, 180)];
    backView.backgroundColor = [UIColor whiteColor];
    backView.layer.cornerRadius = 10;
    backView.center = CGPointMake(SCREEN_WIDTH/2, IPhoneXTopHeight+70+backView.height/2);
    [self.view addSubview:backView];
    
    _codeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, backView.width-20, backView.width-20)];
    _codeImageView.image = [self getImageWithString:_qrcodeStr];
    [backView addSubview:_codeImageView];
    
    UIImageView *bottomImage = [[UIImageView alloc] initWithFrame:CGRectMake(60, backImageView.bottom+40, SCREEN_WIDTH-120, 70)];
    bottomImage.image = [UIImage imageNamed:@"pic_promote_kuang"];
    [self.view addSubview:bottomImage];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.frame = CGRectMake(bottomImage.x+15, bottomImage.y, bottomImage.width-30, bottomImage.height);
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.textColor = MainFontColor;
    tipLabel.numberOfLines = 2;
    tipLabel.adjustsFontSizeToFitWidth = YES;
    tipLabel.text = NSLocalizedString(@"扫一扫注册成为“小微开店”商户推荐人获取奖励", nil);
    [self.view addSubview:tipLabel];
}

- (UIImage *)getImageWithString:(NSString *)str{
    if ([str isKindOfClass:[NSNull class]] || !str) {
        return nil;
    }
    
    UIImage *image = [SGQRCodeTool SG_generateWithDefaultQRCodeData:str imageViewWidth:200];
    return image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
