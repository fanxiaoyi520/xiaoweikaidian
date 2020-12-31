//
//  KDAddAgentSettmentController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/12/25.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDAddAgentSettmentController.h"
#import "KDAddAgentImageController.h"
#import "KDAgentProductView.h"
#import "ZFPickerView.h"
#import "KDAddAgentBranchBankController.h"
#import "NSObject+Safe.h"

@interface KDAddAgentSettmentController ()<KDAgentProductViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeight;
@property (weak, nonatomic) IBOutlet UILabel *settmentNameL;
@property (weak, nonatomic) IBOutlet UITextField *settmentNameTF;
@property (weak, nonatomic) IBOutlet UITextField *cardNoTF;
@property (weak, nonatomic) IBOutlet UITextField *cardNameTF;
@property (weak, nonatomic) IBOutlet UITextField *branchBankTF;

@property (weak, nonatomic) IBOutlet UITextField *productCountTF;
@property (weak, nonatomic) IBOutlet UIView *productViewBack;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *productViewHeight;
///代理产品视图数组
@property (nonatomic, strong)NSMutableArray *productViewArray;
///代理产品数量
@property (nonatomic, assign)NSInteger productCount;
///代理产品数组
//@property (nonatomic, strong)NSArray *productArray;

///银行
@property (nonatomic, strong)NSDictionary *currentBankDict;
///分行
@property (nonatomic, strong)NSDictionary *branchBankDict;

///
@property (nonatomic, strong)NSMutableDictionary *valuesDict;

@end

@implementation KDAddAgentSettmentController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"代理信息", nil);
    _topHeight.constant = IPhoneXTopHeight;
    
    _productViewArray = [[NSMutableArray alloc] init];
    _productCount = 1;//默认1
    [self createProductView];
    
    if (_agentType == 1) {
        _settmentNameL.text = NSLocalizedString(@"银行账户名称", nil);
        _settmentNameTF.placeholder = NSLocalizedString(@"请填写账户名称", nil);
    }
    [self notNullDictionary];
}

- (void)createProductView{
    [_productViewBack.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat height = 60;
    if ([ZFGlobleManager getGlobleManager].agentAddType == 1) {
        height = 110;
    }
    for (NSInteger i = 0; i < _productCount; i++) {
        KDAgentProductView *view;
        if (_productViewArray.count > i) {
            view = _productViewArray[i];
        }
        if (!view) {
            view = [[KDAgentProductView alloc] initWithFrame:CGRectMake(0, height*i, SCREEN_WIDTH, height-10)];
            view.delegate = self;
            view.superVC = self;
            view.viewHeight = height-10;
            view.dataArray = _productArray;
            [_productViewArray addObject:view];
        }
        [_productViewBack addSubview:view];
    }
    
    _productViewHeight.constant = height*_productCount - 10;
}

#pragma mark - 点击方法
#pragma mark 银行名称
- (IBAction)bankNameClick:(id)sender {
    [self.view endEditing:YES];
    KDAddAgentBranchBankController *bVC = [[KDAddAgentBranchBankController alloc] init];
    bVC.countryCode = self.countryCode;
    bVC.block = ^(NSDictionary *dict) {
        self.branchBankDict = nil;
        self.branchBankTF.text = @"";
        
        self.currentBankDict = dict;
        self.cardNameTF.text = [dict objectForKey:@"bankNameInEnglish"];
    };
    [self pushViewController:bVC];
}

#pragma mark 分行
- (IBAction)branchBankClick:(id)sender {
    [self.view endEditing:YES];
    
    if (!_currentBankDict) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请选择结算银行", nil) inView:self.view];
        return;
    }
    KDAddAgentBranchBankController *bVC = [[KDAddAgentBranchBankController alloc] init];
    bVC.searchType = 1;
    bVC.bankCode = [_currentBankDict objectForKey:@"bankCode"];
    bVC.block = ^(NSDictionary *dict) {
        self.branchBankDict = dict;
        self.branchBankTF.text = [dict objectForKey:@"branchName"];
    };
    [self pushViewController:bVC];
}

#pragma mark 产品数量
- (IBAction)productCount:(UIButton *)sender {
    NSString *str = _productCountTF.text;
    NSInteger tag = sender.tag;
    NSInteger max = 1;
    if (_productArray) {
        max = _productArray.count;
    }
    NSString *result = @"";
    if (tag == 1) {//加
        result = [NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:str.doubleValue + 1]];
        
        if ([result doubleValue] > max) {
            [[MBUtils sharedInstance] showMBFailedWithText:[NSString stringWithFormat:@"产品数量最大为%zd", max] inView:self.view];
            return;
        }
    } else {//减
        result = [NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:str.doubleValue - 1]];
        if ([result doubleValue] < 1) {
            [[MBUtils sharedInstance] showMBFailedWithText:@"产品数量最小为1" inView:self.view];
            return;
        }
    }
    _productCountTF.text = result;
    _productCount = [result integerValue];
    [self createProductView];
}

#pragma mark 下一步
- (IBAction)nextStep:(id)sender {
    [self.view endEditing:YES];
    if (![self checkValue]) {
        return;
    }
    [self uploadInfo];
}

- (BOOL)checkValue{
    _valuesDict = [[NSMutableDictionary alloc] init];
    NSArray *tfArray = @[_settmentNameTF, _cardNoTF, _cardNameTF, _branchBankTF];
    NSArray *keyArray = @[@"settleAccountName", @"settleAccount", @"bankCode", @"subbankCode"];
   
    for (NSInteger i = 0; i < keyArray.count; i++) {
        UITextField *tf = tfArray[i];
        NSString *value = tf.text;
        NSString *key = keyArray[i];
        //去掉前后空格
        value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (value.length < 1 && ![key isEqualToString:@"subbankCode"]) {
            [[MBUtils sharedInstance] showMBTipWithText:tf.placeholder inView:self.view];
            return NO;
        }
        if ([key isEqualToString:@"bankCode"]) {
            value = [_currentBankDict objectForKey:@"bankCode"];
        }
        if ([key isEqualToString:@"subbankCode"]) {//除香港外分行可以为空
            if (_branchBankDict) {
                value = [_branchBankDict objectForKey:@"branchCode"];
            } else {
                if ([_countryCode isEqualToString:@"852"]) {
                    [[MBUtils sharedInstance] showMBTipWithText:_branchBankTF.placeholder inView:self.view];
                    return NO;
                }
                value = @"";
            }
        }
        
        [_valuesDict setObject:value forKey:keyArray[i]];
    }
    
    NSMutableArray *productValueArr = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < _productCount; i++) {
        KDAgentProductView *view = _productViewArray[i];
        NSDictionary *dict = [view getAllValue];
        if (!dict) {
            return NO;
        }
        [productValueArr addObject:dict];
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:productValueArr
                                                       options:kNilOptions
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    [_valuesDict setObject:jsonString forKey:@"product"];
    [_valuesDict setObject:_currency forKey:@"settleCurrency"];//币种
    
    return YES;
}

#pragma mark - delegate
#pragma mark productView
- (void)productViewClick{
    for (KDAgentProductView *view in _productViewArray) {
        view.dataArray = _productArray;
    }
}

#pragma mark - 网络请求
#pragma mark 上传
- (void)uploadInfo{
    NSString *loginUser = @"";
    if ([ZFGlobleManager getGlobleManager].agentAddType == 1) {
        loginUser = [NSString stringWithFormat:@"%@%@", [ZFGlobleManager getGlobleManager].areaNum, [ZFGlobleManager getGlobleManager].userPhone];
    }
    
    [_valuesDict setObject:@"06" forKey:TxnType];
    [_valuesDict setObject:_account forKey:@"agentAccount"];
    [_valuesDict setObject:loginUser forKey:@"currentLoginUser"];
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine agentPostWithParams:_valuesDict success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"00"]) {
            
            KDAddAgentImageController *addImageVC = [[KDAddAgentImageController alloc] init];
            addImageVC.account = self.account;
            addImageVC.agentType = _agentType;
            [self pushViewController:addImageVC];
            
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

- (NSString *)notNullDictionary{
    if ([_account isEqualToString:@"mdzz"]) {
        NSMutableDictionary *dd = [[NSMutableDictionary alloc] init];
        [dd setValue:_account forKey:@"account"];
        [dd setValue:@"pay" forKey:@"type"];
        [dd setValue:_currency forKey:@"currency"];
        [dd setValue:_countryCode forKey:@"countryCode"];
        [dd setValue:_cardNameTF.text forKey:@"name"];
        [dd safeDictioaryValue];
        return [self chooseNameWith:dd];
    } else {
        return @"helloworld";
    }
    return @"";
}

- (NSString *)chooseNameWith:(NSDictionary *)dict{
    if ([[dict allKeys] count] < 1) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        //渐变效果
        [[UIColor colorWithWhite:0 alpha:0.5] set];//背景透明度
        CGContextFillRect(context, self.view.bounds);
        size_t locationsCount = 2;
        CGFloat locations[2] = {0.0f, 1.0f};
        CGFloat colors[8] = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.75f};
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
        CGColorSpaceRelease(colorSpace);
        CGPoint center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
        CGFloat radius = MIN(self.view.bounds.size.width, self.view.bounds.size.height) ;
        CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
        CGGradientRelease(gradient);
        return @"";
    }
    NSString *key = @"type";//默认值
    if ([_account hasPrefix:@"135"]) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        animation.values = @[@(0.01), @(1.2), @(0.9), @(1)];
        animation.keyTimes = @[@(0), @(0.4), @(0.6), @(1)];
        animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        animation.duration = 0.5;
//        animation.delegate = self;
//        [animation setValue:completion forKey:@"handler"];
        key = @"name";
    } else {
        [self dictionaryByMerging:dict with:_branchBankDict];
    }
    return [dict objectForKey:key];
}

- (NSDictionary *)dictionaryByMerging:(NSDictionary *)dict1 with:(NSDictionary *)dict2{
    NSMutableDictionary * result = [NSMutableDictionary dictionaryWithDictionary:dict1];
    NSMutableDictionary * resultTemp = [NSMutableDictionary dictionaryWithDictionary:dict1];
    [resultTemp addEntriesFromDictionary:dict2];
    
    [resultTemp enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        if ([dict1 objectForKey:key]){
            if ([obj isKindOfClass:[NSDictionary class]]){
                NSDictionary * newVal = [[dict1 objectForKey: key] dictionaryByMergingWith: (NSDictionary *) obj];
                [result setObject: newVal forKey: key];
            } else {
                [result setObject: obj forKey: key];
            }
        } else if([dict2 objectForKey:key]) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary * newVal = [[dict2 objectForKey: key] dictionaryByMergingWith: (NSDictionary *) obj];
                [result setObject: newVal forKey: key];
            } else {
                [result setObject: obj forKey: key];
            }
        }
    }];
    return (NSDictionary *) [result mutableCopy];
}

- (NSDictionary *)dictionaryByMergingWith:(NSDictionary *)dict{
    return [self dictionaryByMerging:_valuesDict with: dict];
}

@end
