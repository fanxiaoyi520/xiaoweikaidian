//
//  KDAuthenticateViewController.m
//  SinopayStore
//
//  Created by Jellyfish on 2017/12/6.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "KDAuthenticateViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "UIImage+Extension.h"
#import "JXHIphoneTF.h"
#import "UITextField+Format.h"
#import "KDCountryModel.h"
#import "KDBankNameModel.h"
#import "KDSearchBBNViewController.h"
#import "UITextField+LimitLength.h"
#import "ZFLocationManager.h"
#import "YYModel.h"
#import "KDStoreTypeModel.h"

#define ImageViewHeight (SCREEN_HEIGHT-IPhoneXStatusBarHeight)*0.26

@interface KDAuthenticateViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,  UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

/** tableView */
@property (nonatomic, weak) UITableView *tableView;
/** 商家名称TextField */
@property(nonatomic, weak) UITextField *merShopTF;
/** 商家名称 */
@property(nonatomic, copy) NSString *merShop;
/** 店铺名称TextField */
@property(nonatomic, weak) UITextField *storeNameTF;
/** 店铺名称 */
@property(nonatomic, copy) NSString *storeName;
/** 联系人TextField */
@property(nonatomic, weak) UITextField *merNameTF;
/** 联系人 */
@property(nonatomic, copy) NSString *merName;
/** 联系电话TextField */
@property(nonatomic, weak) UITextField *merMobTF;
/** 联系电话 */
@property(nonatomic, copy) NSString *merMob;
/** 水牌IDTextField */
@property(nonatomic, weak) UITextField *waterBrandTF;
/** 水牌ID */
@property(nonatomic, copy) NSString *waterBrandID;

/** 开户姓名TextField */
@property(nonatomic, weak) UITextField *accountNameTF;
/** 开户姓名 */
@property(nonatomic, copy) NSString *accountName;
/** 银行账号TextField */
@property(nonatomic, weak) UITextField *bankNoTF;
/** 银行账号 */
@property(nonatomic, copy) NSString *bankNo;

/** 当前操作的照片 */
@property(nonatomic, strong) UIImage *scaleImage;
/** 拍照标签 */
@property(nonatomic, assign) NSInteger photoTag;

/** 身份证正面照片 */
@property(nonatomic, weak) UIImageView *idFrontIV;
/** 税务登记照片 */
@property(nonatomic, weak) UIImageView *taxIV;
/** 银行月结照片 */
@property(nonatomic, weak) UIImageView *bankIV;
/** 营业场地照片 */
@property(nonatomic, weak) UIImageView *placeIV;


/** 身份证正面照片 */
@property(nonatomic, strong) UIImage *idFrontImage;
/** 税务登记照片 */
@property(nonatomic, strong) UIImage *taxImage;
/** 银行月结照片 */
@property(nonatomic, strong) UIImage *bankImage;
/** 营业场地照片 */
@property(nonatomic, strong) UIImage *placeImage;

/** 身份证正面按钮 */
@property(nonatomic, weak) UIButton *idFrontBtn;
/** 税务登记按钮 */
@property(nonatomic, weak) UIButton *taxBtn;
/** 银行月结按钮 */
@property(nonatomic, weak) UIButton *bankBtn;
/** 营业场地按钮 */
@property(nonatomic, weak) UIButton *placeBtn;

/** 选中按钮 **/
@property(nonatomic, weak) UIButton *agreeBtn;

/** 国家遮罩 */
@property(nonatomic, weak) UIView *darkViewCountry;
/** 国家pickView底部容器视图 */
@property (nonatomic, weak) UIView *contentViewCountry;
/** 银行名称遮罩 */
@property(nonatomic, weak) UIView *darkViewBank;
/** 银行名称pickView底部容器视图 */
@property (nonatomic, weak) UIView *contentViewBank;
/** 商家类型遮罩 */
@property(nonatomic, weak) UIView *darkViewStoreType;
/** 商家类型pickView底部容器视图 */
@property (nonatomic, weak) UIView *contentViewStoreType;

/** 国家PickerView */
@property (nonatomic, weak) UIPickerView *pickerViewCountry;
/** 银行PickerView */
@property (nonatomic, weak) UIPickerView *pickerViewBank;
/** 商家类型PickerView */
@property (nonatomic, weak) UIPickerView *pickerViewStoreType;
/** PickViewType类型 */
@property (nonatomic, assign) PickViewType pickViewType;

/** 国家名称数组 */
@property(nonatomic, strong) NSArray *countryNameArray;
/** 银行名称数组 */
@property(nonatomic, strong) NSArray *bankNameArray;
///选择的国家
@property (nonatomic, strong)KDCountryModel *countryModel;
///选择的银行
@property (nonatomic, strong)KDBankNameModel *bankNameModel;
///选择的分行
@property (nonatomic, strong)KDBranchBankModel *branchBankModel;
///临时选择的国家
@property (nonatomic, assign)NSInteger countryIndex;
///临时选择的银行
@property (nonatomic, assign)NSInteger bankIndex;

/** 商家类型数组 */
@property(nonatomic, strong) NSArray *storeTypeArray;
///选择的商家类型
@property (nonatomic, strong)KDStoreTypeModel *storeTypeModel;
///临时选择的商家类型
@property (nonatomic, assign)NSInteger storeTypeIndex;

///footer底部视图
@property (nonatomic, strong)UIView *footerViewBack;


@end

@implementation KDAuthenticateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"商户认证", nil);
    
    [self setupTableView];
    
    [self setupDatePickerViewWithTitle:NSLocalizedString(@"请选择国家", nil)];
    [self setupDatePickerViewWithTitle:NSLocalizedString(@"请选择银行", nil)];
    [self setupDatePickerViewWithTitle:NSLocalizedString(@"请选择商家类型", nil)];
    
    [self getCountry];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{    
        [self getStoreType];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![ZFLocationManager sharedManager].coordinate.longitude) {
        [[ZFLocationManager sharedManager] startLocation:nil];
    }
}

#pragma mark - 初始化视图
// 设置tableView
- (void)setupTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = GrayBgColor;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.showsVerticalScrollIndicator = YES;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

#pragma mark -- UITableViewDataSourece&UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 6;
    } else {
        return 4;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AuthenticateCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.textColor = ZFAlpColor(0, 0, 0, 0.8);
    UIFont *rightFont = [UIFont systemFontOfSize:15.0];
    UIColor *rightTC = ZFAlpColor(0, 0, 0, 0.3);
    
    if (indexPath.section == 0) {
        cell.textLabel.text = NSLocalizedString(@"所在国家", nil);
        UIView *selectView = [[UIView alloc] initWithFrame:CGRectMake(100, 0, SCREEN_WIDTH-120, 44)];
        [cell addSubview:selectView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(selectView.frame)-(selectView.width-25+20), 0, selectView.width-25, 44)];
        titleLabel.text = !_countryModel ? NSLocalizedString(@"请选择", nil) : _countryModel.countryDesc;
        titleLabel.font = rightFont;
        titleLabel.textColor = rightTC;
        titleLabel.textAlignment = NSTextAlignmentRight;
        [cell addSubview:titleLabel];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_fold_grey"]];
        imageView.frame = CGRectMake(CGRectGetMaxX(titleLabel.frame)+5, 12, 20, 20);
        [cell addSubview:imageView];
        
    } else if (indexPath.section == 1) { // 基本信息
        NSArray *leftArray = [NSArray arrayWithObjects:NSLocalizedString(@"商家名称", nil), NSLocalizedString(@"店铺名称", nil), NSLocalizedString(@"商家类型", nil), NSLocalizedString(@"联系人", nil), NSLocalizedString(@"联系电话", nil),  NSLocalizedString(@"水牌ID", nil), nil];
        cell.textLabel.text = leftArray[indexPath.row];
        NSInteger index = indexPath.row;
        // 右边
        if (index == 2) {
            [cell addSubview:[self getSelectViewWith:101]];
        } else {
            
            [cell addSubview:[self setBaseInfo:index>2?index-1:index]];
        }
        
    } else if (indexPath.section == 2) { // 结算信息
        NSArray *leftArray = [NSArray arrayWithObjects:NSLocalizedString(@"受益人姓名", nil), NSLocalizedString(@"银行账号", nil), NSLocalizedString(@"银行名称", nil), NSLocalizedString(@"所属分行", nil), nil];
        cell.textLabel.text = leftArray[indexPath.row];
        if (indexPath.row < 2) {
            // 右边
            [cell addSubview:[self setSettlementInfo:indexPath.row]];
        } else {
            [cell addSubview:[self getSelectViewWith:indexPath.row]];
        }
    }
    
    return cell;
}

- (UIView *)getSelectViewWith:(NSInteger)tag{
    UIFont *rightFont = [UIFont systemFontOfSize:15.0];
    UIColor *rightTC = ZFAlpColor(0, 0, 0, 0.3);
    
    UIView *selectView = [[UIView alloc] initWithFrame:CGRectMake(120, 0, SCREEN_WIDTH-140, 44)];
    selectView.tag = tag;
    
    // 添加手势
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectViewClicked:)];
    [selectView addGestureRecognizer:tapGestureRecognizer];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, selectView.width-25, 44)];
    if (tag == 2) {
        titleLabel.text = !_bankNameModel ? NSLocalizedString(@"请选择开户银行", nil) : _bankNameModel.bankName;
    } else if (tag == 101) {
        titleLabel.text = !_storeTypeModel ? NSLocalizedString(@"请选择商家类型", nil) : _storeTypeModel.merTypeCurrent;
    } else {
        titleLabel.text = !_branchBankModel ? NSLocalizedString(@"请选择所属分行", nil) : _branchBankModel.branchName;
    }
    titleLabel.font = rightFont;
    titleLabel.textColor = rightTC;
    titleLabel.textAlignment = NSTextAlignmentRight;
    [selectView addSubview:titleLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_fold_grey"]];
    imageView.frame = CGRectMake(CGRectGetMaxX(titleLabel.frame)+5, 12, 20, 20);
    [selectView addSubview:imageView];
    
    return selectView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *contentView  = [UIView new];
    contentView.backgroundColor = [UIColor clearColor];
    contentView.frame = CGRectMake(20, 0, SCREEN_WIDTH, 44);
    
    UILabel *textLabel = [UILabel new];
    textLabel.x = 15;
    textLabel.y = 15;
    if (section == 1) {
        textLabel.text = NSLocalizedString(@"基本资料", nil);
    } else if (section == 2) {
        textLabel.text = NSLocalizedString(@"结算信息", nil);
    } else {
        return nil;
    }
    [textLabel sizeToFit];
    textLabel.textColor = [UIColor grayColor];
    textLabel.font = [UIFont systemFontOfSize:14.0];
    textLabel.textAlignment = NSTextAlignmentLeft;
    
    [contentView addSubview:textLabel];
    
    return contentView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section < 2) {
        return nil;
    }
    if (_footerViewBack) {
        return _footerViewBack;
    }
    _footerViewBack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, (SCREEN_HEIGHT*0.28+74)*4+200)];
    _footerViewBack.backgroundColor = GrayBgColor;
    
    for (int i = 0; i < 4; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
        imageView.frame = CGRectMake(35, 44+i*(ImageViewHeight+60), SCREEN_WIDTH-70, ImageViewHeight);
        // 添加手势
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)];
        [imageView addGestureRecognizer:tapGestureRecognizer];
        [_footerViewBack addSubview:imageView];
        
        UIButton *addBtn = [UIButton new];
        addBtn.tag = i;
        [addBtn setImage:[UIImage imageNamed:@"btn_add"] forState:UIControlStateNormal];
        addBtn.size = CGSizeMake(60, 60);
        addBtn.center = imageView.center;
        [addBtn addTarget:self action:@selector(addBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(imageView.frame)+20, SCREEN_WIDTH-20, 20)];
        if (i == 0) {
            titleLabel.text = NSLocalizedString(@"商业登记证/身份证件正面照片", nil);
            imageView.image = self.idFrontImage ? self.idFrontImage : [UIImage imageNamed:@"pic_shenfenzheng"];
            self.idFrontIV = imageView;
            self.idFrontBtn = addBtn;
            self.idFrontImage ? @"" : [_footerViewBack addSubview:addBtn];
        } else if (i == 1) {
            titleLabel.text = NSLocalizedString(@"税务登记证照片", nil);
            imageView.image = self.taxImage ? self.taxImage : [UIImage imageNamed:@"pic_shuiwudengji"];
            self.taxIV = imageView;
            self.taxBtn = addBtn;
            self.taxImage ? @"" : [_footerViewBack addSubview:addBtn];
        } else if (i == 2) {
            titleLabel.text = NSLocalizedString(@"银行月结单", nil);
            imageView.image = self.bankImage ? self.bankImage : [UIImage imageNamed:@"pic_yinhangyuejie"];
            self.bankIV = imageView;
            self.bankBtn = addBtn;
            self.bankImage ? @"" : [_footerViewBack addSubview:addBtn];
        } else if (i == 3) {
            titleLabel.text = NSLocalizedString(@"营业场地照片", nil);
            imageView.image = self.placeImage ? self.placeImage : [UIImage imageNamed:@"pic_yingyechangdi"];
            self.placeIV = imageView;
            self.placeBtn = addBtn;
            self.placeImage ? @"" : [_footerViewBack addSubview:addBtn];
        }
        titleLabel.font = [UIFont systemFontOfSize:14.0];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        [_footerViewBack addSubview:titleLabel];
        
        if (i == 3) {// 同意合同
            UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame)+44, SCREEN_WIDTH, 20)];
            [_footerViewBack addSubview:contentView];
            
//            UIButton *agreeBtn = [[UIButton alloc] init];
//            [agreeBtn setTitle:NSLocalizedString(@"同意", nil) forState:UIControlStateNormal];
//            agreeBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
//            [agreeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            [agreeBtn setImage:[UIImage imageNamed:@"icon_unselected"] forState:UIControlStateNormal];
//            [agreeBtn setImage:[UIImage imageNamed:@"icon_selected"] forState:UIControlStateSelected];
//            [agreeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
//            [agreeBtn addTarget:self action:@selector(agreeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//            agreeBtn.selected = YES;
//            [contentView addSubview:agreeBtn];
//            self.agreeBtn = agreeBtn;
//
//            UIButton *contractsBtn = [[UIButton alloc] init];
//            [contractsBtn setTitle:NSLocalizedString(@"《电子收单合同》", nil) forState:UIControlStateNormal];
//            contractsBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
//            [contractsBtn setTitleColor:MainFontColor forState:UIControlStateNormal];
//            [contractsBtn addTarget:self action:@selector(contractsBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//            [contentView addSubview:contractsBtn];
//
//            [contractsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.centerX.mas_equalTo(contentView.centerX).offset(30);
//                make.top.bottom.mas_equalTo(contentView);
//            }];
//
//            [agreeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.bottom.mas_equalTo(contentView);
//                make.right.mas_equalTo(contractsBtn.mas_left);
//                make.width.mas_equalTo(70);
//            }];
            
            // 提交按钮
            UIButton *commitBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(contentView.frame)+44, SCREEN_WIDTH-40, 44)];
            [commitBtn setTitle:NSLocalizedString(@"提交", nil) forState:UIControlStateNormal];
            [commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            commitBtn.layer.cornerRadius = 5.0f;
            commitBtn.backgroundColor = MainThemeColor;
            [commitBtn addTarget:self action:@selector(commitBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [_footerViewBack addSubview:commitBtn];
        }
    }
    
    return _footerViewBack;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return 44+5*(ImageViewHeight+60);
    }
    return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 20;
    }
    
    return 44;
}


#pragma mark ------- 点击方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DLog(@"点击第 %ld 行", indexPath.row + 1);
    if (indexPath.section == 0) {
        if (!_countryNameArray || _countryNameArray.count==0) {
            [self getCountry];
            return;
        }
        self.pickViewType = PickViewTypeCountry;
        self.darkViewCountry.hidden = NO;
        [UIView animateWithDuration:0.5f animations:^{
            self.contentViewCountry.y = SCREEN_HEIGHT-225;
        }];
    }
}

#pragma mark - 结算信息按钮
-(void)selectViewClicked:(UITapGestureRecognizer*)tap {
    DLog(@"%zd", tap.view.tag);
    [self.tableView endEditing:YES];
    
    if (tap.view.tag == 2) {
        self.pickViewType = PickViewTypeBank;
        self.darkViewBank.hidden = NO;
        [UIView animateWithDuration:0.5f animations:^{
            self.contentViewBank.y = SCREEN_HEIGHT-225;
        }];
    } else if (tap.view.tag == 101) {
        if (self.storeTypeArray.count < 1) {
            [self getStoreType];
            return;
        }
        self.pickViewType = PickViewTypeStoreType;
        self.darkViewStoreType.hidden = NO;
        [UIView animateWithDuration:0.5f animations:^{
            self.contentViewStoreType.y = SCREEN_HEIGHT-225;
        }];
    } else {
        if (!_bankNameModel) {
            return;
        }
        KDSearchBBNViewController *bbvc = [[KDSearchBBNViewController alloc] init];
        bbvc.bankCode = _bankNameModel.bankCode;
        bbvc.block = ^(KDBranchBankModel *model) {
            DLog(@"%@--%@", model.branchNum, model.branchName);
            _branchBankModel = model;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
        };
        [self pushViewController:bbvc];
    }
    
}

// 同意
- (void)agreeBtnClicked:(UIButton *)sender
{
    self.agreeBtn.selected = !sender.selected;
}

// 合同
- (void)contractsBtnClicked
{
    DLog(@"合同");
}

#pragma mark - 提交按钮
- (void)commitBtnClicked
{
    [self.view endEditing:YES];
    if (![ZFLocationManager sharedManager].coordinate.longitude) {
        [[ZFLocationManager sharedManager] startLocation:nil];
        return;
    }
    
    if (_countryModel && self.merShop && self.storeName && self.merName && self.merMob && self.accountName && self.bankNo && _bankNameModel) {
        if ([self.merMob stringByReplacingOccurrencesOfString:@" " withString:@""].length < 7) {
            [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"手机号码填写有误", nil) inView:self.view];
            return ;
        } else if ([self.bankNo stringByReplacingOccurrencesOfString:@" " withString:@""].length < 10) {
            [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"银行账号填写有误", nil) inView:self.view];
            return ;
        } else if (!(self.idFrontImage && self.taxImage && self.bankImage && self.placeImage)) {
            [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请上传所需照片", nil) inView:self.view];
            return ;
        }
//        else if (!self.agreeBtn.selected) {
//            [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请阅读并同意《电子收单合同》", nil) inView:self.view];
//            return ;
//        }
        
        [self commitMerchantInfo];
        
    } else {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"资料未填写完整", nil) inView:self.view];
    }
    
}


#pragma mark - 拍照相关
-(void)imageViewClicked:(UITapGestureRecognizer*)tap {
    if (!self.countryModel) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请选择开户银行", nil) inView:self.view];
        return;
    }
    if (!self.storeTypeModel) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请选择商家类型", nil) inView:self.view];
        return;
    }
    self.photoTag = tap.view.tag;
    [self presentActionSheet];
}

- (void)addBtnClicked:(UIButton *)sender
{
    if (!self.countryModel) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请选择开户银行", nil) inView:self.view];
        return;
    }
    if (!self.storeTypeModel) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请选择商家类型", nil) inView:self.view];
        return;
    }
    DLog(@"%zd", sender.tag);
    self.photoTag = sender.tag;
    [self presentActionSheet];
}

- (void)presentActionSheet {
    // 准备初始化配置参数
    NSString *photo = NSLocalizedString(@"拍照", nil);
    NSString *album = NSLocalizedString(@"从手机相册选择", nil);
    NSString *cancel = NSLocalizedString(@"取消", nil);
    
    // 初始化
    UIAlertController *alertDialog = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:photo style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // 相机拍照
        [self photograph];
    }];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:album style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // 相册
        [self openPhotoLibrary];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // 取消按键
        DLog(@"cancelAction");
    }];
    
    // 添加操作（顺序就是呈现的上下顺序）
    [alertDialog addAction:photoAction];
    [alertDialog addAction:albumAction];
    [alertDialog addAction:cancelAction];
    
    // 呈现警告视图
    [self presentViewController:alertDialog animated:YES completion:nil];
}

- (void)photograph {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // 检查打开相机的权限是否打开
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
        {
            NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
            NSString *title = [appName stringByAppendingString:NSLocalizedString(@"不能访问您的相机", nil)];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:NSLocalizedString(@"请前往“设置”打开相机访问权限", nil) preferredStyle:UIAlertControllerStyleAlert];
            // 取消
            UIAlertAction *cancle = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:0 handler:nil];
            [alert addAction:cancle];
            
            // 确定
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"打开", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
            }];
            [alert addAction:confirmAction];
            
            [self presentViewController:alert animated:YES completion:nil];
        } else { // 调用照相机
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                // 不允许编辑
                picker.allowsEditing = NO;
                // 弹出系统拍照
                [self presentViewController:picker animated:YES completion:nil];
            }
        }
    } else {
        [XLAlertController acWithMessage:NSLocalizedString(@"该设备不支持相机", nil) confirmBtnTitle:NSLocalizedString(@"确定", nil)];
    }
}

- (void)openPhotoLibrary  {
    // 判断是否有权限
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            UIImagePickerController *alubmPicker = [[UIImagePickerController alloc] init];
            alubmPicker.delegate = self;
            alubmPicker.allowsEditing = YES;
            alubmPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            [self presentViewController:alubmPicker animated:YES completion:nil];
        } else {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"请去设置中打开访问相册开关", nil) preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {

            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
            [alertC addAction:cancel];
            [alertC addAction:alertA];
            [self presentViewController:alertC animated:YES completion:nil];
        }
    }];
}

#pragma mark -- 拍照代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    // 退出拍照页面,对拍摄的照片编辑
    [picker dismissViewControllerAnimated:YES completion:^{
        self.scaleImage = [[info objectForKey:UIImagePickerControllerOriginalImage] scaleImage400];
        NSString *imageStr = [UIImageJPEGRepresentation(self.scaleImage, 0.2) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        imageStr = [self encodeToPercentEscapeString:imageStr];
        [self uploadImageWith:imageStr];
    }];
}

- (NSString *)encodeToPercentEscapeString: (NSString *) input{
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    //url编码
    NSString *outputStr = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,                   (CFStringRef)input, NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8));
    return outputStr;
}

#pragma mark - 网络请求
// 上传照片
- (void)uploadImageWith:(NSString *)imageStr {    
    NSString *imageParam = nil;
    if (self.photoTag == 0) {
        imageParam = @"picIdcard";
    } else if (self.photoTag == 1) {
        imageParam = @"picTaxreg";
    } else if (self.photoTag == 2) {
        imageParam = @"picMks";
    } else if (self.photoTag == 3) {
        imageParam = @"picBusiness";
    }
    
    NSDictionary *dict = @{@"countryCode" : [ZFGlobleManager getGlobleManager].areaNum,
                           @"mobile" : [ZFGlobleManager getGlobleManager].userPhone,
                           @"sessionID" : [ZFGlobleManager getGlobleManager].tempSessionID,
                           @"image" : imageStr,
                           @"imageParam" : imageParam,
                           @"mcc" : _storeTypeModel.mcc,
                           @"country" :  _countryModel.countryLog,
                           @"txnType":@"07",
                           };
    [[MBUtils sharedInstance] showMBWithText:NSLocalizedString(@"正在上传...", nil) inView:self.view];
    
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) { // 成功
            [[MBUtils sharedInstance] showMBSuccessdWithText:NSLocalizedString(@"上传成功", nil) inView:self.view];
            
            if (self.photoTag == 0) {
                self.idFrontImage = self.scaleImage;
                self.idFrontIV.image = self.scaleImage;
                self.idFrontBtn.hidden = YES;
            } else if (self.photoTag == 1) {
                self.taxImage = self.scaleImage;
                self.taxIV.image = self.scaleImage;
                self.taxBtn.hidden = YES;
            } else if (self.photoTag == 2) {
                self.bankImage = self.scaleImage;
                self.bankIV.image = self.scaleImage;
                self.bankBtn.hidden = YES;
            } else if (self.photoTag == 3) {
                self.placeImage = self.scaleImage;
                self.placeIV.image = self.scaleImage;
                self.placeBtn.hidden = YES;
            }
            
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

- (void)commitMerchantInfo {
    // 用临时密钥加密卡号
    NSString *key = [ZFGlobleManager getGlobleManager].tempSecurityKey;
    NSString *enCardNum = [TripleDESUtils getEncryptWithString:[self.bankNo stringByReplacingOccurrencesOfString:@" " withString:@""] keyString:key ivString:TRIPLEDES_IV];
    NSString *repertoryId = @"";
    if (_waterBrandID.length > 0) {
        repertoryId = [self.waterBrandID stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    NSString *branchNum = _branchBankModel.branchNum;
    if (!branchNum || branchNum.length < 1) {
        branchNum = @"";
    }
    
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    
    NSDictionary *dict = @{@"countryCode" : [ZFGlobleManager getGlobleManager].areaNum,
                           @"mobile" : [ZFGlobleManager getGlobleManager].userPhone,
                           @"sessionID" : [ZFGlobleManager getGlobleManager].tempSessionID,
                           @"country" :  _countryModel.countryLog,
                           @"merName" :  [self.merShop stringByTrimmingCharactersInSet:set],
                           @"merShortName" : [self.storeName stringByTrimmingCharactersInSet:set],
                           @"contact" : [self.merName stringByTrimmingCharactersInSet:set],
                           @"phoneNumber" :  [self.merMob stringByReplacingOccurrencesOfString:@" " withString:@""],
                           @"repertoryId" :  repertoryId,
                           @"accountName" :  [self.accountName stringByTrimmingCharactersInSet:set],
                           @"bankName" : [_bankNameModel.bankName stringByTrimmingCharactersInSet:set],
                           @"cardNum" :  enCardNum,
                           @"branchNum" : branchNum,
                           @"longitude" : [NSString stringWithFormat:@"%f", [ZFLocationManager sharedManager].coordinate.longitude],
                           @"latitude" : [NSString stringWithFormat:@"%f", [ZFLocationManager sharedManager].coordinate.latitude],
                           @"txnType" : @"08",
                           };
    [[MBUtils sharedInstance] showMBWithText:NSLocalizedString(@"正在提交", nil) inView:self.view];
    
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) { // 提交成功
            [[MBUtils sharedInstance] dismissMB];
            // 修改认证状态
            [ZFGlobleManager getGlobleManager].fillingStatus = @"0";
            
            [XLAlertController acWithMessage:NSLocalizedString(@"提交成功，信息正在审核中...", nil) confirmBtnTitle:NSLocalizedString(@"好的", nil) confirmAction:^(UIAlertAction *action) {
                [ZFGlobleManager getGlobleManager].merName = [self.merShop stringByTrimmingCharactersInSet:set];
                [ZFGlobleManager getGlobleManager].merShortName = [self.storeName stringByTrimmingCharactersInSet:set];
                if (_authentType == 1) {
                    self.block(YES);
                }
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark 获取进件国家或地区
- (void)getCountry{
    _bankNameModel = nil;
    _branchBankModel = nil;
    NSDictionary *dict = @{@"txnType" : @"17"};
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) { // 提交成功
            
            NSArray *countryArr = [requestResult objectForKey:@"list"];
            NSMutableArray *areaArray = [[NSMutableArray alloc] init];
            
            NSString *language = [NetworkEngine getCurrentLanguage];
            NSString *languageDesc = @"chnDesc";//简体
            if ([language isEqualToString:@"1"]) {
                languageDesc = @"engDesc";//英文
            }
            if ([language isEqualToString:@"2"]) {
                languageDesc = @"fonDesc";//繁体
            }
            
            for (NSDictionary *dict in countryArr) {
                KDCountryModel *model = [[KDCountryModel alloc] init];
                model.countryLog = [dict objectForKey:@"countryLog"];
                model.countryCode = [dict objectForKey:@"countryCode"];
                model.countryDesc = [dict objectForKey:languageDesc];
                [areaArray addObject:model];
            }
            _countryNameArray = areaArray;
            self.pickViewType = PickViewTypeCountry;
            [self.pickerViewCountry reloadAllComponents];
            
            _countryIndex = 0;
            _countryModel = _countryNameArray[0];
            [_tableView reloadData];
            [self getBankWithCountryCode:_countryModel.countryCode];
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark 获取进件银行
- (void)getBankWithCountryCode:(NSString *)countryCode{
    _bankNameModel = nil;
    _branchBankModel = nil;
    
    NSDictionary *dict = @{@"countryCode":countryCode,
                           @"txnType" : @"18"};
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] dismissMB];
            NSArray *list = [requestResult objectForKey:@"list"];
            NSMutableArray *bankArray = [[NSMutableArray alloc] init];
            
            NSString *language = [NetworkEngine getCurrentLanguage];
            NSString *languageDesc = @"bankNameInChinese";//简体
            if ([language isEqualToString:@"1"]) {
                languageDesc = @"bankNameInEnglish";//英文
            }
            if ([language isEqualToString:@"2"]) {
                languageDesc = @"bankNameInFon";//繁体
            }
            
            for (NSDictionary *dict in list) {
                KDBankNameModel *model = [[KDBankNameModel alloc] init];
                model.bankCode = [dict objectForKey:@"bankCode"];
                model.countryCode = [dict objectForKey:@"countryCode"];
                model.bankName = [dict objectForKey:languageDesc];
                [bankArray addObject:model];
            }
            _bankNameArray = bankArray;
            self.pickViewType = PickViewTypeBank;
            [self.pickerViewBank reloadAllComponents];
            [_pickerViewBank selectRow:0 inComponent:0 animated:NO];
            
            _bankIndex = 0;
            //            _bankNameModel = _bankNameArray[0];
            [_tableView reloadData];
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark 获取商家类型
- (void)getStoreType{
    NSDictionary *dict = @{@"txnType" : @"67"};
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            self.storeTypeArray = [NSArray yy_modelArrayWithClass:[KDStoreTypeModel class] json:[requestResult objectForKey:@"list"]];
            NSString *language = [NetworkEngine getCurrentLanguage];//1 英语  2 汉语繁体 3 简体中文
            for (KDStoreTypeModel *model in self.storeTypeArray) {
                if ([language isEqualToString:@"1"]) {
                    model.merTypeCurrent = model.merTypeInEnglish;
                } else if ([language isEqualToString:@"2"]) {
                    model.merTypeCurrent = model.merTypeInFon;
                } else {
                    model.merTypeCurrent = model.merTypeInChinese;
                }
            }
            
            self.pickViewType = PickViewTypeStoreType;
            [self.pickerViewStoreType reloadAllComponents];
            [_pickerViewStoreType selectRow:0 inComponent:0 animated:NO];
            
            _storeTypeIndex = 0;
            [_tableView reloadData];
            
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark - 其他方法
// 基本信息
- (UITextField *)setBaseInfo:(NSInteger)tag
{
    UIFont *rightFont = [UIFont systemFontOfSize:15.0];
    UIColor *rightTC = ZFAlpColor(0, 0, 0, 0.3);
    // 右边
    UITextField *textField = [UITextField new];
    NSString *phText = @"";
    if (tag == 0) {
        phText = NSLocalizedString(@"请设置商家名称", nil);
        self.merShopTF = textField;
        textField.keyboardType = UIKeyboardTypeASCIICapable;
        textField.text = self.merShop.length == 0 ? @"" : self.merShop;
    } else if (tag == 1) {
        phText = NSLocalizedString(@"请设置店铺名称", nil);
        self.storeNameTF = textField;
        textField.keyboardType = UIKeyboardTypeASCIICapable;
        textField.text = self.storeName.length == 0 ? @"" : self.storeName;
    } else if (tag == 2) {
        phText = NSLocalizedString(@"请填写商家联系人姓名", nil);
        self.merNameTF = textField;
        textField.text = self.merName.length == 0 ? @"" : self.merName;
    } else if (tag == 3) {
        phText = NSLocalizedString(@"请填写商家联系人电话号码", nil);
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [textField limitTextLength:11];
        textField.keyboardType = UIKeyboardTypeNumberPad;
        self.merMobTF = textField;
        textField.text = self.merMob.length == 0 ? @"" : self.merMob;
    } else if (tag == 4) {
        phText = NSLocalizedString(@"请填写商家水牌ID（可选）", nil);
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [textField limitTextLength:15];
        textField.keyboardType = UIKeyboardTypeDefault;
        self.waterBrandTF = textField;
        textField.text = self.waterBrandID.length == 0 ? @"" : self.waterBrandID;
    }
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:phText attributes:@{NSForegroundColorAttributeName: rightTC}];
    textField.textColor = rightTC;
    textField.textAlignment = NSTextAlignmentRight;
    textField.font = rightFont;
    textField.size = CGSizeMake(SCREEN_WIDTH-160, 44);
    textField.x = 120;
    textField.y = 0;
    textField.delegate = self;
    
    return textField;
}

// 结算信息
- (UITextField *)setSettlementInfo:(NSInteger)tag
{
    UIFont *rightFont = [UIFont systemFontOfSize:15.0];
    UIColor *rightTC = ZFAlpColor(0, 0, 0, 0.3);
    // 右边
    UITextField *textField = [UITextField new];
    NSString *phText = nil;
    if (tag == 0) {
        phText = NSLocalizedString(@"请输入银行开户姓名", nil);
        self.accountNameTF = textField;
        textField.text = self.accountName.length == 0 ? @"" : self.accountName;
    } else if (tag == 1) {
        phText = NSLocalizedString(@"请输入银行账号", nil);
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        self.bankNoTF = textField;
        textField.text = self.bankNo.length == 0 ? @"" : self.bankNo;
    }
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:phText attributes:@{NSForegroundColorAttributeName: rightTC}];
    textField.textColor = rightTC;
    textField.textAlignment = NSTextAlignmentRight;
    textField.font = rightFont;
    textField.size = CGSizeMake(SCREEN_WIDTH-160, 44);
    textField.x = 120;
    textField.y = 0;
    textField.delegate = self;
    
    return textField;
}

// 防止复用
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.merShopTF) {
        self.merShop = textField.text;
    } else if (textField == self.storeNameTF) {
        self.storeName = textField.text;
    } else if (textField == self.merNameTF) {
        self.merName = textField.text;
    } else if (textField == self.merMobTF) {
        self.merMob = textField.text;
    } else if (textField == self.waterBrandTF) {
        self.waterBrandID = textField.text;
    } else if (textField == self.accountNameTF) {
        self.accountName = textField.text;
    } else if (textField == self.bankNoTF) {
        self.bankNo = textField.text;
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.bankNoTF) {
        [textField formatBankCardNoWithString:string range:range];
        return NO;
    }
    
    if ([string isEqualToString:@"&"]) {//禁止输入&符号
        return NO;
    }
    
    if (textField == self.merShopTF || textField == self.storeNameTF) {
        return ![self isChinese:string];
    }
    return YES;
}

- (BOOL)isChinese:(NSString *)string {
    for(int i = 0; i < [string length]; i++){
        int a =[string characterAtIndex:i];
        if( a >0x4e00&& a <0x9fff){
            return YES;
        }
    }
    return NO;
}

#pragma mark - 选择器相关
- (void)setupDatePickerViewWithTitle:(NSString *)title {
    // 遮罩
    UIView *darkView = [[UIView alloc] init];
    darkView.alpha = 0.6;
    darkView.backgroundColor = ZFColor(46, 49, 50);
    darkView.frame = ZFSCREEN;
    darkView.hidden = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:darkView];
    
    // 容器视图
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 225)];
    contentView.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication].keyWindow addSubview:contentView];
    
    // 取消按钮
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];;
    cancelBtn.backgroundColor = [UIColor clearColor];
    [cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:cancelBtn];
    
    // 提示文字
    UILabel *tiplabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3, 0, SCREEN_WIDTH/3, 44)];
    tiplabel.text = title;
    tiplabel.textColor = UIColorFromRGB(0x313131);
    tiplabel.textAlignment = NSTextAlignmentCenter;
    tiplabel.font = [UIFont boldSystemFontOfSize:17.0];
    [contentView addSubview:tiplabel];
    
    // 确定按钮
    UIButton *ctBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-80, 0, 80, 44)];;
    ctBtn.backgroundColor = [UIColor clearColor];
    [ctBtn setTitleColor:MainThemeColor forState:UIControlStateNormal];
    [ctBtn setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    ctBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [ctBtn addTarget:self action:@selector(ctBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:ctBtn];
    
    // 分割线
    UIView *spliteView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, 1)];
    spliteView.backgroundColor = GrayBgColor;
    [contentView addSubview:spliteView];
    
    // 选择器
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 45, SCREEN_WIDTH, 200)];
    pickerView.backgroundColor = [UIColor whiteColor];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    [contentView addSubview:pickerView];
    
    if ([title isEqualToString:NSLocalizedString(@"请选择国家", nil)]) {
        self.pickViewType = PickViewTypeCountry;
        self.darkViewCountry = darkView;
        self.contentViewCountry = contentView;
        self.pickerViewCountry = pickerView;
    } else if ([title isEqualToString:NSLocalizedString(@"请选择商家类型", nil)]) {
        self.darkViewStoreType = darkView;
        self.contentViewStoreType = contentView;
        self.pickerViewStoreType = pickerView;
    } else {
        self.pickViewType = PickViewTypeBank;
        self.darkViewBank = darkView;
        self.contentViewBank = contentView;
        self.pickerViewBank = pickerView;
    }
}

#pragma mark -- UIPickerViewDataSource 选择器数据源
// 指定pickerview有几个表盘
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// 指定每个表盘上有几行数据
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.pickViewType == PickViewTypeCountry) {
        return self.countryNameArray.count;
    } else if (self.pickViewType == PickViewTypeStoreType) {
        return self.storeTypeArray.count;
    } else {
        return self.bankNameArray.count;
    }
}

#pragma mark UIPickerViewDelegate 选择器代理方法
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return SCREEN_WIDTH;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

// 选中的方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.pickViewType == PickViewTypeCountry) {
        _countryIndex = row;
    } else if (self.pickViewType == PickViewTypeStoreType) {
        _storeTypeIndex = row;
    } else {
        _bankIndex = row;
    }
    
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    //设置分割线的颜色
    for(UIView *singleLine in pickerView.subviews)
    {
        if (singleLine.frame.size.height < 1)
        {
            singleLine.backgroundColor = ZFAlpColor(0, 0, 0, 0.3);
        }
    }
    //设置文字的属性
    UILabel *genderLabel = [UILabel new];
    genderLabel.textAlignment = NSTextAlignmentCenter;
    if (self.pickViewType == PickViewTypeCountry) {
        KDCountryModel *model = self.countryNameArray[row];
        genderLabel.text = model.countryDesc;
    } else if (self.pickViewType == PickViewTypeStoreType) {
        KDStoreTypeModel *model = self.storeTypeArray[row];
        genderLabel.text = model.merTypeCurrent;
    } else {
        KDBankNameModel *model = self.bankNameArray[row];
        genderLabel.text = model.bankName;
    }
    genderLabel.font = [UIFont systemFontOfSize:22.0];
    genderLabel.adjustsFontSizeToFitWidth = YES;
    
    return genderLabel;
}

// 取消选择时间
- (void)cancelBtnClicked {
    if (self.pickViewType == PickViewTypeCountry) {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             self.contentViewCountry.y = SCREEN_HEIGHT;
                         }
                         completion:^(BOOL finished){
                             self.darkViewCountry.hidden = YES;
                         }];
    } else if (self.pickViewType == PickViewTypeStoreType) {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             self.contentViewStoreType.y = SCREEN_HEIGHT;
                         }
                         completion:^(BOOL finished){
                             self.darkViewStoreType.hidden = YES;
                         }];
    } else {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             self.contentViewBank.y = SCREEN_HEIGHT;
                         }
                         completion:^(BOOL finished){
                             self.darkViewBank.hidden = YES;
                         }];
    }
}

// 确定选择时间
- (void)ctBtnClicked {
    DLog(@"%@", self.bankNameModel.bankName);
    // 选择刷新
    if (self.pickViewType == PickViewTypeCountry) {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             self.contentViewCountry.y = SCREEN_HEIGHT;
                         }
                         completion:^(BOOL finished){
                             self.darkViewCountry.hidden = YES;
                         }];
        
        // 刷新
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        if ([_countryNameArray indexOfObject:_countryModel] != _countryIndex) {//和上次选择的不一样再重新加载
            _countryModel = _countryNameArray[_countryIndex];
            [self getBankWithCountryCode:_countryModel.countryCode];
        }
    } else if (self.pickViewType == PickViewTypeStoreType) {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             self.contentViewStoreType.y = SCREEN_HEIGHT;
                         }
                         completion:^(BOOL finished){
                             self.darkViewStoreType.hidden = YES;
                         }];
        
        // 刷新
        if ([_storeTypeArray indexOfObject:_storeTypeModel] != _storeTypeIndex) {//和上次选择的不一样再重新加载
            _storeTypeModel = _storeTypeArray[_storeTypeIndex];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
        }
    } else {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             self.contentViewBank.y = SCREEN_HEIGHT;
                         }
                         completion:^(BOOL finished){
                             self.darkViewBank.hidden = YES;
                         }];
        if ([_bankNameArray indexOfObject:_bankNameModel] != _bankIndex) {
            _branchBankModel = nil;
            _bankNameModel = _bankNameArray[_bankIndex];
//            [_tableView reloadData];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
        }
        // 刷新
        //        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end

