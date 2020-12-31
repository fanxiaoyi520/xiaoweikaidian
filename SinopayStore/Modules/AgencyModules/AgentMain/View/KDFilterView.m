//
//  KDFilterView.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/2/14.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDFilterView.h"
#import "ZFDatePickerView.h"
#import "DateUtils.h"

@interface KDFilterView ()<ZFDatePickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *searchBV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBVHeight;
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UIButton *beginBtn;
@property (weak, nonatomic) IBOutlet UIButton *endBtn;
@property (weak, nonatomic) IBOutlet UIView *timeBV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeBVHeight;

@property (nonatomic, strong)ZFDatePickerView *beginPicker;
@property (nonatomic, strong)ZFDatePickerView *endPicker;

@property (nonatomic, strong)NSString *beginTime;
@property (nonatomic, strong)NSString *endTime;

@end

@implementation KDFilterView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"KDFilterView" owner:self options:nil] firstObject];
        [self createPickerView];
    }
    
    return self;
}

- (void)setFilterType:(NSInteger)filterType{
    _filterType = filterType;
    if (filterType == 1) {
        _searchBV.hidden = YES;
        _searchBVHeight.constant = 0;
    }
    if (filterType == 2) {
        _timeBV.hidden = YES;
        _timeBVHeight.constant = 0;
    }
}

- (void)setPlaceholder:(NSString *)placeholder{
    _searchTF.placeholder = placeholder;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.frame = _myFrame;
}

- (void)createPickerView{
    _beginPicker = [[ZFDatePickerView alloc] initWithFrame:CGRectMake(0, 0, self.width, SCREEN_HEIGHT)];
    _beginPicker.delegate = self;
    _beginPicker.tag = 100;
    [[UIApplication sharedApplication].keyWindow addSubview:_beginPicker];
    
    _endPicker = [[ZFDatePickerView alloc] initWithFrame:CGRectMake(0, 0, self.width, SCREEN_HEIGHT)];
    _endPicker.delegate = self;
    _endPicker.tag = 101;
    [[UIApplication sharedApplication].keyWindow addSubview:_endPicker];
    
    NSDate *monthAgo = [NSDate dateWithTimeInterval:-24*60*60*31 sinceDate:[NSDate date]];
    
    _beginTime = [DateUtils dateToStringWithFormatter:@"yyyy-MM-dd" date:monthAgo];
    _endTime = [DateUtils dateToStringWithFormatter:@"yyyy-MM-dd" date:[NSDate date]];
    [_beginBtn setTitle:_beginTime forState:UIControlStateNormal];
    [_endBtn setTitle:_endTime forState:UIControlStateNormal];
}

- (void)setMyFrame:(CGRect)myFrame{
    _myFrame = myFrame;
    self.frame = _myFrame;
}

- (IBAction)searchBtn:(id)sender {
    [_searchTF resignFirstResponder];
    self.block(_searchTF.text, _beginTime, _endTime);
}

- (IBAction)beginBtn:(id)sender {
    [_searchTF resignFirstResponder];
    [_beginPicker show];
}

- (IBAction)endBtn:(id)sender {
    [_searchTF resignFirstResponder];
    [_endPicker show];
}

#pragma mark - delegate
- (void)datePickerViewTag:(NSInteger)tag time:(NSString *)time{
    NSInteger timeInteger = [[time stringByReplacingOccurrencesOfString:@"-" withString:@""] integerValue];
    NSInteger beginInteger = [[_beginTime stringByReplacingOccurrencesOfString:@"-" withString:@""] integerValue];
    NSInteger endInteger = [[_endTime stringByReplacingOccurrencesOfString:@"-" withString:@""] integerValue];
    if (tag == 100) {
        if (timeInteger > endInteger) {
            [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"开始时间要小于结束时间", nil) inView:self];
            return;
        }
        [_beginBtn setTitle:time forState:UIControlStateNormal];
        _beginTime = time;
    } else {
        if (timeInteger < beginInteger) {
            [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"结束时间要大于开始时间", nil) inView:self];
            return;
        }
        [_endBtn setTitle:time forState:UIControlStateNormal];
        _endTime = time;
    }
    self.block(_searchTF.text, _beginTime, _endTime);
}

@end
