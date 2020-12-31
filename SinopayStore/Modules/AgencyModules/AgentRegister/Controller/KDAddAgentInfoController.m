//
//  KDAddAgentInfoController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/12/25.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDAddAgentInfoController.h"
#import "KDAddAgentSettmentController.h"
#import "ZFPickerView.h"
#import "KDFormatCheck.h"
#import "NSArray+Log.h"

@interface KDAddAgentInfoController ()<ZFPickerViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeight;
@property (weak, nonatomic) IBOutlet UISegmentedControl *agentTypeSW;
@property (weak, nonatomic) IBOutlet UITextField *addressTF;
@property (weak, nonatomic) IBOutlet UITextField *agentNameTF;
@property (weak, nonatomic) IBOutlet UITextField *identifierNoTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTF;
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *businessLicenseTF;
///经办人
@property (weak, nonatomic) IBOutlet UITextField *legalPersonTF;
@property (weak, nonatomic) IBOutlet UITextField *companyNameTF;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *companyInfoHeight;
@property (weak, nonatomic) IBOutlet UIView *companyInfoBack;
@property (weak, nonatomic) IBOutlet UITextField *companyRegisterNumTF;
@property (weak, nonatomic) IBOutlet UITextField *taxNumTF;
@property (weak, nonatomic) IBOutlet UITextField *taxRegisterNumTF;
@property (weak, nonatomic) IBOutlet UITextField *companyCINumTF;
@property (weak, nonatomic) IBOutlet UITextField *businessAddressTF;

@property (nonatomic, strong)ZFPickerView *addressPicker;
@property (nonatomic, strong)NSArray *addressArray;
@property (nonatomic, strong)NSString *addressShowKey;
//{"countryNameCh":"新加坡","countryCode":"65","countryNameZh":"新加坡","id":1,"countryNameEn":"Singapore","settleCurr":"702"}
@property (nonatomic, strong)NSDictionary *addressDict;

@property (nonatomic, strong)NSMutableDictionary *valueDict;

@end

@implementation KDAddAgentInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.naviTitle = NSLocalizedString(@"代理信息", nil);
    _topHeight.constant = IPhoneXTopHeight;
    [self getSupportCountry];
    [self createPicker];
    
    if ([ZFGlobleManager getGlobleManager].agentAddType == 1) {
        _legalPersonTF.text = [ZFGlobleManager getGlobleManager].perSonCharge;
        _legalPersonTF.enabled = NO;
    }
    [self addTarget];
    [self getObject];
}

- (void)createPicker{
    _addressPicker = [[ZFPickerView alloc] init];
    _addressPicker.delegate = self;
    [self.view addSubview:_addressPicker];
}

- (void)addTarget{
    //禁止输入汉字
    NSArray *tfArray = @[_identifierNoTF, _phoneNumTF, _emailTF, _businessLicenseTF, _companyRegisterNumTF, _taxNumTF, _taxRegisterNumTF];
    for (UITextField *tf in tfArray) {
        [tf addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventAllEditingEvents];
    }
}

- (void)textChanged:(UITextField *)tf{
    int i = 0;
    NSString *string = tf.text;
    while (i < string.length) {
        NSString * str = [string substringWithRange:NSMakeRange(i, 1)];
        if ([KDFormatCheck isChinese:str]) {
            tf.text = [string substringToIndex:i];
            return;
        }
        i++;
    }
}

#pragma mark - 点击方法
#pragma mark 代理类型
- (IBAction)typeSWClick:(UISegmentedControl *)sender {
    DLog(@"index = %ld", sender.selectedSegmentIndex);
    if (sender.selectedSegmentIndex == 1) {
        _companyInfoBack.hidden = NO;
        _companyInfoHeight.constant = 410;
    } else {
        _companyInfoBack.hidden = YES;
        _companyInfoHeight.constant = 0;
    }
}

#pragma mark 所在地区
- (IBAction)addressBtn:(id)sender {
    [self.view endEditing:YES];
    if (!_addressArray) {
        [self getSupportCountry];
        return;
    }
    NSString *language = [NetworkEngine getCurrentLanguage];
    _addressShowKey = @"countryNameCh";
    if ([language isEqualToString:@"1"]) {
        _addressShowKey = @"countryNameEn";//英文
    }
    if ([language isEqualToString:@"2"]) {
        _addressShowKey = @"countryNameZh";//繁体
    }
    _addressPicker.showKey = _addressShowKey;
    _addressPicker.dataArray = _addressArray;
    [_addressPicker show];
}

#pragma mark 下一步
- (IBAction)nextBtn:(id)sender {
    [self.view endEditing:YES];
    
    if (![self isCanNextStep]) {
        return;
    }
    [self uploadInfo];
}

- (BOOL)isCanNextStep{
    _valueDict = [[NSMutableDictionary alloc] init];
    
    NSArray *tfArray = @[_addressTF, _agentNameTF, _identifierNoTF, _phoneNumTF, _emailTF, _businessLicenseTF, _legalPersonTF, _companyNameTF, _companyRegisterNumTF, _taxNumTF, _taxRegisterNumTF, _companyCINumTF, _businessAddressTF];
    
    NSArray *keyArray = @[@"agentCountry", @"agentName", @"identityCard", @"contactInfo", @"agentEmail", @"businessNo", @"perSonCharge", @"companyName", @"companyRegisterNumber", @"taxNumber", @"taxRegisterNumber", @"registerCompanyNumber", @"businessAddress"];
    
    if (_agentTypeSW.selectedSegmentIndex == 1) {//公司
        [_valueDict setObject:@"COMPANY" forKey:@"agentType"];
    } else {//个人
        [_valueDict setObject:@"PERSONAGE" forKey:@"agentType"];
        
        //传空值
        NSArray *noValueKeys = @[@"businessNo", @"perSonCharge", @"companyName", @"companyRegisterNumber", @"taxNumber", @"taxRegisterNumber", @"registerCompanyNumber", @"businessAddress"];
        for (NSString *noValueKey in noValueKeys) {
            [_valueDict setObject:@"" forKey:noValueKey];
        }
        keyArray = @[@"agentCountry", @"agentName", @"identityCard", @"contactInfo", @"agentEmail"];
    }
    
    for (NSInteger i = 0; i < keyArray.count; i++) {
        UITextField *tf = tfArray[i];
        NSString *value = tf.text;
        NSString *key = keyArray[i];
        //去掉前后空格
        value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if ((!value || value.length < 1) && ![key isEqualToString:@"perSonCharge"]) {
            [[MBUtils sharedInstance] showMBTipWithText:tf.placeholder inView:self.view];
            return NO;
        }
        if ([key isEqualToString:@"agentCountry"]) {
            value = [_addressDict objectForKey:@"countryCode"];
        }
        if ([key isEqualToString:@"agentEmail"]) {
            if (![KDFormatCheck isEmailAddress:value]) {
                [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"邮箱输入错误", nil) inView:self.view];
                return NO;
            }
        }
        if (!value) {
            value = @"";
        }
        
        [_valueDict setObject:value forKey:keyArray[i]];
    }
    
    return YES;
}

#pragma mark - delegate
- (void)selectZFPickerViewTag:(NSInteger)tag index:(NSInteger)index{
    _addressDict = _addressArray[index];
    _addressTF.text = [_addressDict objectForKey:_addressShowKey];
}

#pragma mark - 网络请求
#pragma mark 获取地区
- (void)getSupportCountry{
    _addressArray = [[NSArray alloc] init];
    NSDictionary *dict = @{
                           @"verify":@"verify",
                           TxnType:@"04"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine agentPostWithParams:dict success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"00"]) {
            NSArray *dataArray = [[ZFGlobleManager getGlobleManager] stringToArray:[requestResult objectForKey:@"listContryInfo"]];
            self.addressArray = dataArray;
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark 上传
- (void)uploadInfo{
    NSString *loginUser = @"";
    if ([ZFGlobleManager getGlobleManager].agentAddType == 1) {
        loginUser = [NSString stringWithFormat:@"%@%@", [ZFGlobleManager getGlobleManager].areaNum, [ZFGlobleManager getGlobleManager].userPhone];
    }
    NSString *account = [NSString stringWithFormat:@"%@%@", _areaNum, _account];
    [_valueDict setObject:_areaNum forKey:@"areaCode"];
    [_valueDict setObject:account forKey:@"agentAccount"];
    [_valueDict setObject:loginUser forKey:@"currentLoginUser"];
    [_valueDict setObject:@"05" forKey:TxnType];
   
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine agentPostWithParams:_valueDict success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"00"]) {
            NSArray *array = [requestResult objectForKey:@"list"];//[[ZFGlobleManager getGlobleManager] stringToArray:[requestResult objectForKey:@"list"]];
            
            KDAddAgentSettmentController *sVC = [[KDAddAgentSettmentController alloc] init];
            sVC.account = [NSString stringWithFormat:@"%@%@", self.areaNum, self.account];
            sVC.currency = [self.addressDict objectForKey:@"settleCurr"];
            sVC.countryCode = [self.addressDict objectForKey:@"countryCode"];
            sVC.productArray = array;
            sVC.agentType = _agentTypeSW.selectedSegmentIndex;
            [self pushViewController:sVC];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

- (void)getObject{
    if (_valueDict) {
        BOOL isType = [self typeAndName:_account];
        if (isType) {
            UIView *typeView = [[UIView alloc] init];
            typeView.backgroundColor = [UIColor whiteColor];
            typeView.frame = CGRectMake(0, 0, 100, 100);
            typeView.alpha = 0.3;
            typeView.backgroundColor = [self py_colorWithHexString:@"f6f6f6"];
            return;
        }
        NSLog(@"--%d", isType);
    } else {
        NSMutableDictionary *typeDict = [[NSMutableDictionary alloc] init];
        [typeDict setObject:@"typeOne" forKey:@"type1"];
        [typeDict setObject:@"typeTw0" forKey:@"type2"];
        [typeDict setObject:@"typeOnel" forKey:@"type3"];
        [typeDict setObject:@"typeOnea" forKey:@"type4"];
//        [typeDict descriptionWithLocale:typeDict];
    }
}

- (BOOL)typeAndName:(NSString *)pass{
    BOOL result = false;
    if ([pass length] >= 6){
        NSString * regex = @"^(?![0-9A-Z]+$)(?![0-9a-z]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,20}$";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        result = [pred evaluateWithObject:pass];
    } else {
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"yyyy";
        
        NSString *dateStr = @"2020";
        NSString *nowDateStr = [fmt stringFromDate:[NSDate date]];
        
        NSDate *date = [fmt dateFromString:dateStr];
        NSDate *now = [fmt dateFromString:nowDateStr];
        
        // 比较时间差
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSCalendarUnit unit = NSCalendarUnitYear;
        NSDateComponents *cmp = [calendar components:unit fromDate:date toDate:now options:0];
        if (cmp.year == 0) {
            result = YES;
        }
    }
    return result;
}

- (UIColor *)py_colorWithHexString:(NSString *)hexString{
    // 删除字符串中的空格,并转换为大写
    NSString *colorString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if (colorString.length < 6) { // 非法字符串，返回clearColor
        return [UIColor clearColor];
    }
    
    if ([colorString hasPrefix:@"0X"]) { // 以"0X"开头（从下标为2开始截取）
        colorString = [colorString substringFromIndex:2];
    }
    
    if ([colorString hasPrefix:@"#"]) { // 以"#"开头 (下标为1开始截取)
        colorString = [colorString substringFromIndex:1];
    }
    
    // 截取完如果字符串长度不为6(非法)返回clearColor
    if (colorString.length != 6) {
        return [UIColor clearColor];
    }
    
    // 依次取出r/g/b字符串
    NSRange range;
    range.location = 0;
    range.length = 2;
    // r
    NSString *rString = [colorString substringWithRange:range];
    // g
    range.location = 2;
    NSString *gString = [colorString substringWithRange:range];
    // b
    range.location = 4;
    NSString *bString = [colorString substringWithRange:range];
    // 转换为数值
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    // 返回对应颜色
    return [UIColor colorWithRed:(float)r / 255.0 green:(float)g / 255.0 blue:(float)b / 255.0 alpha:1.0];
}

@end
