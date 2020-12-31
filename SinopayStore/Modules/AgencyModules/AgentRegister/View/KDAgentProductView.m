//
//  KDAgentProductView.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/12/26.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDAgentProductView.h"
#import "ZFPickerView.h"
#import "ZFDatePickerView.h"

@interface KDAgentProductView ()<ZFPickerViewDelegate, ZFDatePickerViewDelegate>

@property (nonatomic, strong)ZFPickerView *pickerView;
@property (nonatomic, strong)ZFDatePickerView *beginPicker;
@property (nonatomic, strong)ZFDatePickerView *endPicker;
@property (weak, nonatomic) IBOutlet UIView *productRateBack;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *productRateHeight;

@property (nonatomic, strong)NSDictionary *currentProductDict;

@end

@implementation KDAgentProductView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"KDAgentProductView" owner:self options:nil] firstObject];
        self.frame = CGRectMake(0, frame.origin.y, SCREEN_WIDTH, 200);
    }
    return self;
}

- (void)layoutSubviews{
//    [super layoutSubviews];
    self.frame = CGRectMake(0, self.y, SCREEN_WIDTH, _viewHeight);
    DLog(@"%.f", _viewHeight);
}

- (void)setViewHeight:(CGFloat)viewHeight{
    _viewHeight = viewHeight;
    if ([ZFGlobleManager getGlobleManager].agentAddType == 1) {
        _productRateBack.hidden = NO;
        _productRateHeight.constant = 50;
    }
}

- (void)setSuperVC:(UIViewController *)superVC{
    _superVC = superVC;
    [self createPickerView];
}

- (void)createPickerView{
    _pickerView = [[ZFPickerView alloc] init];
    _pickerView.delegate = self;
    [_superVC.view addSubview:_pickerView];
}

- (ZFDatePickerView *)beginPicker{
    if (!_beginPicker) {
        _beginPicker = [[ZFDatePickerView alloc] initWithFrame:ZFSCREEN];
        _beginPicker.delegate = self;
        _beginPicker.tag = 100;
        [_superVC.view addSubview:_beginPicker];
    }
    return _beginPicker;
}

- (ZFDatePickerView *)endPicker{
    if (!_endPicker) {
        _endPicker = [[ZFDatePickerView alloc] initWithFrame:ZFSCREEN];
        _endPicker.delegate = self;
        _endPicker.tag = 101;
        [_superVC.view addSubview:_endPicker];
    }
    return _endPicker;
}

- (IBAction)productClick:(id)sender {
    if (!_dataArray) {
        [self.delegate productViewClick];
        return;
    }
    [_superVC.view endEditing:YES];
    _pickerView.showKey = @"productName";
    _pickerView.dataArray = _dataArray;
    [_pickerView show];
}

- (IBAction)beginTime:(id)sender {
    [_superVC.view endEditing:YES];
    [self.beginPicker show];
}

- (IBAction)endTime:(id)sender {
    [_superVC.view endEditing:YES];
    [self.endPicker show];
}

- (void)selectZFPickerViewTag:(NSInteger)tag index:(NSInteger)index{
    NSDictionary *dict = _dataArray[index];
    if (_currentProductDict == dict) {
        return;
    }
    _currentProductDict = dict;
    _productTF.text = [_currentProductDict objectForKey:@"productName"];
}

- (void)datePickerViewTag:(NSInteger)tag time:(NSString *)time{
    NSInteger timeInteger = [[time stringByReplacingOccurrencesOfString:@"-" withString:@""] integerValue];
    NSInteger beginInteger = [[_beginTimeTF.text stringByReplacingOccurrencesOfString:@"-" withString:@""] integerValue];
    NSInteger endInteger = [[_endTimeTF.text stringByReplacingOccurrencesOfString:@"-" withString:@""] integerValue];
    
    if (tag == 100) {
        if (timeInteger > endInteger && endInteger > 0) {
            return;
        }
        _beginTimeTF.text = time;
        
    } else {
        if (timeInteger < beginInteger) {
//            [[MBUtils sharedInstance] showMBTipWithText:@"结束时间要大于开始时间" inView:self.view];
            return;
        }
        
        _endTimeTF.text = time;
    }
}

- (NSDictionary *)getAllValue{
    if (!_currentProductDict) {
        [[MBUtils sharedInstance] showMBTipWithText:_productTF.placeholder inView:_superVC.view];
        return nil;
    }
    NSString *rate = @"";
    if ([ZFGlobleManager getGlobleManager].agentAddType == 1) {
        if (_rateTF.text.length < 1) {
            [[MBUtils sharedInstance] showMBTipWithText:_rateTF.placeholder inView:_superVC.view];
            return nil;
        }
        rate = _rateTF.text;
        
        if ([rate doubleValue] <= [[_currentProductDict objectForKey:@"productRate"] doubleValue]) {
            [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"下级产品费率不能小于自身费率", nil) inView:_superVC.view];
            return nil;
        }
    }
    
//    if (_beginTimeTF.text.length < 1) {
//        [[MBUtils sharedInstance] showMBTipWithText:_beginTimeTF.placeholder inView:_superVC.view];
//        return nil;
//    }
//    if (_endTimeTF.text.length < 1) {
//        [[MBUtils sharedInstance] showMBTipWithText:_endTimeTF.placeholder inView:_superVC.view];
//        return nil;
//    }
    
    NSDictionary *dict = @{
                           @"productId":[_currentProductDict objectForKey:@"mainId"],
                           @"productType":[_currentProductDict objectForKey:@"productType"],
                           @"productRate":rate,
//                           @"proStartTime":_beginTimeTF.text,
//                           @"proEndTime":_endTimeTF.text,
                           @"productName":[_currentProductDict objectForKey:@"productName"],

                           };
    
    return dict;
}

@end
