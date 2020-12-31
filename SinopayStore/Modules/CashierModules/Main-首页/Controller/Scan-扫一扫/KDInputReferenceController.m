//
//  KDInputReferenceController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/3/1.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDInputReferenceController.h"
#import "KDRewardListController.h"
#import "KDRewardListModel.h"

@interface KDInputReferenceController ()<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITextField *textField;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)UIButton *nextBtn;

@end

@implementation KDInputReferenceController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"奖励领取", nil);
    _dataArray = [[NSMutableArray alloc] init];
    [self createView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_tableView reloadData];
}

- (void)createView{
    self.view.backgroundColor = GrayBgColor;
    
    UIView *topBack = [[UIView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, 50)];
    topBack.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topBack];
    
    //输入框
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, SCREEN_WIDTH-80, 30)];
    _textField.placeholder = NSLocalizedString(@"请输入交易参考号", nil);
    _textField.font = [UIFont systemFontOfSize:12];
    _textField.layer.cornerRadius = 5;
    _textField.keyboardType = UIKeyboardTypeNumberPad;
    _textField.backgroundColor = GrayBgColor;
    _textField.delegate = self;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.returnKeyType = UIReturnKeyDone;
    [_textField limitTextLength:12];
    [topBack addSubview:_textField];
    _textField.leftViewMode = UITextFieldViewModeAlways;
    _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
    
    //添加按钮
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(_textField.right, 0, SCREEN_WIDTH-_textField.right, 50);
    addBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [addBtn setTitle:NSLocalizedString(@"添加", nil) forState:UIControlStateNormal];
    [addBtn setTitleColor:MainThemeColor forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [topBack addSubview:addBtn];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topBack.bottom+10, SCREEN_WIDTH, SCREEN_HEIGHT-topBack.bottom-60) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = GrayBgColor;
    _tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:_tableView];
    
    _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _nextBtn.frame = CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH, 50);
    _nextBtn.backgroundColor = MainThemeColor;
    [_nextBtn setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
    [_nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextBtn];
}

//添加按钮
- (void)addBtnClick{
    [self.view endEditing:YES];
    NSString *reference = [_textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (reference.length == 0) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请输入交易参考号", nil) inView:self.view];
        return;
    }
    if (reference.length != 12) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"参考号输入错误", nil) inView:self.view];
        return;
    }
    if (_dataArray.count >= 20) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"最多可添加领取20条", nil) inView:self.view];
        return;
    }
    //去重
    for (KDRewardListModel *model in _dataArray) {
        if ([model.serialNumber isEqualToString:reference]) {
            [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"参考号输入重复", nil) inView:self.view];
            return;
        }
    }
    
    NSDictionary *parameters = @{
                                 @"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                                 @"serialNumber": reference,
                                 @"txnType": @"42",
                                 };
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            KDRewardListModel *model = [[KDRewardListModel alloc] init];
            [model setValuesForKeysWithDictionary:requestResult];
            [_dataArray insertObject:model atIndex:0];
            [_tableView reloadData];
            _textField.text = @"";
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(NSError *error) {
        
    }];
}
//下一步
- (void)nextBtnClick{
    if (_dataArray.count > 0) {
        KDRewardListController *rlVC = [[KDRewardListController alloc] init];
        rlVC.dataArray = _dataArray;
        [self pushViewController:rlVC];
    } else {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请添加交易参考号", nil) inView:self.view];
    }
}
//删除所有
- (void)deleteAll{
    [self.view endEditing:YES];
    [_dataArray removeAllObjects];
    [_tableView reloadData];
}
//删除一个
- (void)deleteSingle:(UIButton *)btn{
    NSInteger tag = btn.tag-1000;
    if (tag < _dataArray.count) {
        [_dataArray removeObjectAtIndex:tag];
        [_tableView reloadData];
    }
}

#pragma mark -- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_dataArray.count>0) {
        return _dataArray.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"reference";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (_dataArray.count == 0) {//没有数据
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 100, 24)];
        label.font = [UIFont systemFontOfSize:14];
        label.text = NSLocalizedString(@"暂无", nil);
        label.alpha = 0.8;
        [cell addSubview:label];
    } else {
        KDRewardListModel *model = _dataArray[indexPath.row];
        
        UILabel *numLabel = [self getCellLabeWithSer:model.serialNumber];
        [cell addSubview:numLabel];
        
        UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        delBtn.frame = CGRectMake(SCREEN_WIDTH-50, 2, 40, 40);
        delBtn.tag = indexPath.row+1000;
        [delBtn setImage:[UIImage imageNamed:@"icon_delete_single"] forState:UIControlStateNormal];
        [delBtn setImage:[UIImage imageNamed:@"icon_delete_single"] forState:UIControlStateHighlighted];
        [delBtn addTarget:self action:@selector(deleteSingle:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:delBtn];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    headView.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, headView.height)];
    label.font = [UIFont boldSystemFontOfSize:14];
    label.alpha = 0.8;
    label.text = NSLocalizedString(@"奖励列表", nil);
    [label sizeToFit];
    label.size = CGSizeMake(label.width, headView.height);
    [headView addSubview:label];
    
    //提示信息
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(label.right+10, 0, headView.width-label.right-60, headView.height)];
    tipLabel.font = [UIFont systemFontOfSize:12];
    tipLabel.alpha = 0.6;
    tipLabel.text = NSLocalizedString(@"最多可添加领取20条", nil);
    tipLabel.adjustsFontSizeToFitWidth = YES;
    [headView addSubview:tipLabel];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake(SCREEN_WIDTH-50, 5, 40, 40);
    [deleteBtn setImage:[UIImage imageNamed:@"icon_delete_all"] forState:UIControlStateNormal];
    [deleteBtn setImage:[UIImage imageNamed:@"icon_delete_all"] forState:UIControlStateHighlighted];
    [deleteBtn addTarget:self action:@selector(deleteAll) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:deleteBtn];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, headView.height-1, headView.width, 1)];
    lineView.backgroundColor = GrayBgColor;
    [headView addSubview:lineView];
    
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
}

- (UILabel *)getCellLabeWithSer:(NSString *)serialNumber{
    NSMutableString *serStr = [[NSMutableString alloc] initWithString:serialNumber];
    if (serialNumber.length > 8) {
        [serStr insertString:@" " atIndex:8];
        [serStr insertString:@" " atIndex:4];
    }
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 100, 24)];
    numLabel.font = [UIFont systemFontOfSize:14];
    numLabel.backgroundColor = UIColorFromRGB(0xEEF4FB);
    numLabel.alpha = 0.8;
    numLabel.textAlignment = NSTextAlignmentCenter;
    numLabel.text = serStr;
    [numLabel sizeToFit];
    numLabel.size = CGSizeMake(numLabel.width+20, 24);
    numLabel.layer.cornerRadius = 10;
    numLabel.clipsToBounds = YES;
    
    return numLabel;
}

#pragma mark textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self addBtnClick];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (![@"1234567890" containsString:string] && ![string isEqualToString:@""]) {//限制数字
        return NO;
    }
    return YES;
}

@end
