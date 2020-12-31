//
//  KDAddMerBaseController.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/2/15.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDAddMerBaseController.h"
#import "ZFPickerView.h"
#import "KDAddMerImageController.h"
#import "KDFormatCheck.h"

@interface KDAddMerBaseController ()<ZFPickerViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeight;
@property (weak, nonatomic) IBOutlet UITextField *merchantNameTF;
@property (weak, nonatomic) IBOutlet UITextField *merShortNameTF;
@property (weak, nonatomic) IBOutlet UITextField *merAddressTF;
@property (weak, nonatomic) IBOutlet UITextField *merTypeTF;
@property (weak, nonatomic) IBOutlet UITextField *contactTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTF;

///商户类型
@property (nonatomic, strong)ZFPickerView *merTypePicker;
@property (nonatomic, strong)NSMutableArray *merTypeArray;
@property (nonatomic, strong)NSString *merTypeCode;

@property (nonatomic, strong)NSMutableDictionary *valuesDict;

@end

@implementation KDAddMerBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.naviTitle = NSLocalizedString(@"商户信息", nil);
    _topHeight.constant = IPhoneXTopHeight;
    _phoneNumTF.text = _phoneNum;
    _merTypeArray = [[NSMutableArray alloc] init];
    [self getMerType];
    [self createPicker];
    [self star_Sky];
}

- (void)createPicker{
    _merTypePicker = [[ZFPickerView alloc] init];
    _merTypePicker.delegate = self;
    _merTypePicker.tag = 101;
    _merTypePicker.showKey = @"mccMean";
    [self.view addSubview:_merTypePicker];
}

#pragma mark - 点击方法
#pragma mark 商户类型
- (IBAction)merchantType:(id)sender {
    [self.view endEditing:YES];
    if (_merTypeArray.count == 0) {
        [self getMerType];
        return;
    }
    _merTypePicker.dataArray = _merTypeArray;
    [_merTypePicker show];
}

#pragma mark 下一步
- (IBAction)nextStep:(id)sender {
    [self.view endEditing:YES];
    if (![self isCanNextStep]) {
        return;
    }
    
    [self uploadInfo];
}

- (BOOL)isCanNextStep{
    _valuesDict = [[NSMutableDictionary alloc] init];
    NSArray *tfArray = @[_merchantNameTF, _merShortNameTF, _merAddressTF, _merTypeTF, _contactTF, _phoneNumTF];
    NSArray *keyArray = @[@"merName", @"merShortName", @"merAddress", @"mccNo", @"contact", @"phoneNum"];
    for (NSInteger i = 0; i < keyArray.count; i++) {
        UITextField *tf = tfArray[i];
        NSString *value = tf.text;
        NSString *key = keyArray[i];
        //去掉前后空格
        value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (!value || value.length < 1) {
            [[MBUtils sharedInstance] showMBTipWithText:tf.placeholder inView:self.view];
            return NO;
        }
        if ([key isEqualToString:@"mccNo"]) {
            value = _merTypeCode;
        }
        [_valuesDict setObject:value forKey:keyArray[i]];
    }
    
    return YES;
}

#pragma mark - delegate
- (void)selectZFPickerViewTag:(NSInteger)tag index:(NSInteger)index{
    if (tag == 101) {
        NSDictionary *dict = _merTypeArray[index];
        _merTypeTF.text = [dict objectForKey:@"mccMean"];
        _merTypeCode = [dict objectForKey:@"mccNo"];
    }
}

#pragma mark textField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == _merShortNameTF) {
        NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:LimitEnglish] invertedSet];
        NSString *str = [[string componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
        return [string isEqualToString:str];
    }
    
    return YES;
}

#pragma mark - 数据
#pragma mark 获取商户类型
- (void)getMerType{
    NSString *account = [NSString stringWithFormat:@"%@%@", [ZFGlobleManager getGlobleManager].areaNum, [ZFGlobleManager getGlobleManager].userPhone];
    NSDictionary *dict = @{
                           @"agentAcct":account,
                           @"country":@"",
                           @"reqType":@"03"
                           };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine merchantPostWithParams:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"rspCode"] isEqualToString:@"00"]) {
            [[MBUtils sharedInstance] dismissMB];
            _merTypeArray = [requestResult objectForKey:@"mccList"];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"rspMsg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark 上传数据
- (void)uploadInfo{
    NSString *account = [NSString stringWithFormat:@"%@%@", [ZFGlobleManager getGlobleManager].areaNum, [ZFGlobleManager getGlobleManager].userPhone];
    
    [_valuesDict setObject:_areaNum forKey:@"countryCode"];
    [_valuesDict setObject:account forKey:@"agentAcct"];
    [_valuesDict setObject:@"15" forKey:@"reqType"];
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine merchantPostWithParams:_valuesDict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"rspCode"] isEqualToString:@"00"]) {
            [[MBUtils sharedInstance] dismissMB];
            KDAddMerImageController *addImageVC = [[KDAddMerImageController alloc] init];
            addImageVC.merTemNo = [requestResult objectForKey:@"merTemNo"];
            addImageVC.phoneNum = _phoneNum;
            addImageVC.areaNum = _areaNum;
            [self pushViewController:addImageVC];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"rspMsg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

- (void)star_Sky{
    if (![_areaNum isEqualToString:@"1230"]) {
        return;
    }
    NSMutableArray *columnArray = [[NSMutableArray alloc] init];
    NSInteger numberOfYAxisElements = 1;
    //加单位
    for (int i = 0; i < numberOfYAxisElements + 1; i++) {
        CGFloat avgValue = 10 / numberOfYAxisElements;
        [columnArray addObject:[NSString stringWithFormat:@"%.0f", avgValue]];
    }
    
    NSString * unit = [NSString stringWithFormat:@"单位(%@)", @"$"];
    [columnArray replaceObjectAtIndex:columnArray.count-1 withObject:[NSString stringWithFormat:@"%@\n%@",unit,columnArray[columnArray.count-1]]];
    
    UIBezierPath *scalePath = [UIBezierPath bezierPath];
    [scalePath moveToPoint:CGPointMake(30, 10)];
    [scalePath addLineToPoint:CGPointMake(30, self.view.frame.size.height - 1)];
    [scalePath moveToPoint:CGPointMake(30, self.view.frame.size.height - 1)];
    [scalePath addLineToPoint:CGPointMake(self.view.frame.size.width - 2, self.view.frame.size.height - 1)];
    CGFloat UP = 10;
    CGFloat LEFT = 10;
    CGFloat BELOW = 1;
    CGFloat scaleY = (self.view.frame.size.height - UP - 1) / (columnArray.count-1);
    for (int i = 0; i < columnArray.count; i++) {
        [scalePath moveToPoint:CGPointMake(LEFT, (self.view.frame.size.height - 1) - (scaleY * i))];
        [scalePath addLineToPoint:CGPointMake(LEFT + 2, (self.view.frame.size.height - 1) - (scaleY * i))];
        UILabel *yLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 40)];
        yLabel.textColor = [UIColor grayColor];
        yLabel.font = [UIFont systemFontOfSize:8];
        yLabel.textAlignment = NSTextAlignmentCenter;
        yLabel.numberOfLines = 2;
        yLabel.text = columnArray[i];
        if (i != columnArray.count-1){
            yLabel.center = CGPointMake(LEFT / 2, (self.view.frame.size.height - BELOW) - (scaleY * i));
        } else {
            yLabel.center = CGPointMake(LEFT+5, (self.view.frame.size.height - BELOW) - (scaleY * i));
            yLabel.textAlignment = NSTextAlignmentLeft;
        }
    }
    CGFloat RIGHT = 10;
    CGFloat scaleX = (self.view.frame.size.width - LEFT - RIGHT) / 20;
    for (int i = 0; i < 20; i++) {
        [scalePath moveToPoint:CGPointMake((LEFT + scaleX * i), self.view.frame.size.height - BELOW)];
        [scalePath addLineToPoint:CGPointMake((LEFT + scaleX * i), self.view.frame.size.height - BELOW - 2)];
        if (i > 0) {
            UILabel *xLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, scaleX, 20)];
            xLabel.textColor = [UIColor grayColor];
            xLabel.font = [UIFont systemFontOfSize:7];
            xLabel.textAlignment = NSTextAlignmentCenter;
            xLabel.text = @"";
            xLabel.center = CGPointMake((LEFT + scaleX * i), self.view.frame.size.height - BELOW / 2);
        }
    }
    
    CAShapeLayer *shaperLayer = [CAShapeLayer layer];
    shaperLayer.path = scalePath.CGPath;
    shaperLayer.lineWidth = 1.0;
    shaperLayer.lineCap = kCALineCapRound;
    shaperLayer.lineJoin = kCALineJoinRound;
    shaperLayer.strokeColor = [UIColor grayColor].CGColor;

    [self drawBarChart];
}

-(void)drawBarChart{
    UIBezierPath *path = [UIBezierPath bezierPath];
    //绘制折线图
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(100, 100)];
    path.lineJoinStyle = kCGLineJoinRound;
    CGFloat LEFT = 10;
    CGFloat RIGHT = 10;
    //设置layer层
    CAShapeLayer *shaperLayer = [CAShapeLayer layer];
    shaperLayer.path = path.CGPath;
    CGFloat scaleX = (self.view.frame.size.width - LEFT - RIGHT) / 20-1;
    shaperLayer.lineWidth = scaleX;
    shaperLayer.strokeColor = [UIColor whiteColor].CGColor;
    //设置动画
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
//    anim.delegate = self;
    anim.fromValue = @0;
    anim.toValue = @1;
    anim.duration = 0.1;
    
    [shaperLayer addAnimation:anim forKey:NSStringFromSelector(@selector(strokeEnd))];
    NSDictionary *send = @{NSFontAttributeName: [UIFont systemFontOfSize:10]};
    CGSize textSize = [_areaNum boundingRectWithSize:CGSizeMake(20, 0)
                                         options:NSStringDrawingTruncatesLastVisibleLine |
                       NSStringDrawingUsesLineFragmentOrigin |
                       NSStringDrawingUsesFontLeading
                                      attributes:send context:nil].size;
    DLog(@"-+-%.0f", textSize.width);
}

@end
